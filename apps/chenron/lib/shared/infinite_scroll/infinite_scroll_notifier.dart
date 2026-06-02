import "dart:math";
import "package:app_logger/app_logger.dart";
import "package:signals/signals.dart";

class InfiniteScrollNotifier<T> {
  final Signal<List<T>> loadedItems = signal([]);
  final Signal<bool> hasMore = signal(true);
  final Signal<bool> isLoadingMore = signal(false);
  final Signal<int> totalCount = signal(0);

  /// Non-null after a loader page failed; cleared on the next successful
  /// page. Views can render a retry affordance off this without the list
  /// ever being bricked by a raw SQLite error.
  final Signal<Object?> error = signal(null);

  /// Whether the most recent load attempt failed.
  bool get hasError => error.value != null;

  final int pageSize;

  final Future<List<T>> Function(int limit, int offset) _loader;
  final Future<int> Function()? _countLoader;
  int _currentOffset = 0;

  /// Incremented on every [reset]. A [loadNextPage] captures the epoch
  /// before awaiting the loader and discards its result if the epoch
  /// changed underneath it — so a page from a previous dataset can never
  /// append onto the freshly-cleared list or advance the offset.
  int _epoch = 0;

  static const _logTag = "InfiniteScrollNotifier";

  InfiniteScrollNotifier({
    required Future<List<T>> Function(int limit, int offset) loader,
    Future<int> Function()? countLoader,
    this.pageSize = 50,
  })  : _loader = loader,
        _countLoader = countLoader;

  /// Loads the total count (if countLoader provided) and the first
  /// page. The count and the first page are fired off in parallel —
  /// neither depends on the other, and serializing them was a
  /// noticeable contributor to first-paint latency on folder open.
  Future<void> loadInitial() async {
    final futures = <Future<void>>[
      loadNextPage(),
      if (_countLoader != null)
        _countLoader().then((value) => totalCount.value = value),
    ];
    await Future.wait(futures);
  }

  /// Appends the next page of items. No-op if already loading or no more items.
  ///
  /// A loader failure is caught, logged, and surfaced via [error] rather
  /// than propagated — the existing items stay put and [hasMore] is left
  /// intact so the caller can retry. A [reset] that lands while the loader
  /// is in flight invalidates this call: its page is dropped instead of
  /// appended onto the now-cleared list.
  Future<void> loadNextPage() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;

    final epoch = _epoch;
    final offset = _currentOffset;
    try {
      final newItems = await _loader(pageSize, offset);
      // A reset() happened while we awaited — discard this stale page.
      if (epoch != _epoch) return;
      loadedItems.value = [...loadedItems.value, ...newItems];
      _currentOffset = offset + newItems.length;
      hasMore.value = newItems.length >= pageSize;
      error.value = null;
    } catch (e, s) {
      // Never brick the list on a loader/SQLite error: log, surface via
      // [error], and keep hasMore so a retry is possible.
      if (epoch != _epoch) return;
      loggerGlobal.warning(_logTag, "Failed to load page at offset $offset", e, s);
      error.value = e;
    } finally {
      // Only the call that owns the current epoch may release the guard;
      // a stale call must not clobber a fresh load started after reset().
      if (epoch == _epoch) isLoadingMore.value = false;
    }
  }

  /// Eagerly loads all remaining pages. Used when filter activates and
  /// in-memory filtering needs the complete dataset.
  ///
  /// Stops on the first loader error. Because [loadNextPage] swallows
  /// errors and leaves [hasMore] true so a retry is possible, looping on
  /// `hasMore` alone would spin forever against a persistently failing
  /// source — so we break as soon as [hasError] is set.
  Future<void> loadAll() async {
    while (hasMore.value) {
      await loadNextPage();
      if (hasError) break;
    }
  }

  /// Whether all items have been loaded (no more pages remain).
  bool get isFullyLoaded => !hasMore.value;

  /// Number of items loaded so far.
  int get loadedCount => loadedItems.value.length;

  /// Estimated total (from countLoader, or loaded count if no countLoader).
  int get estimatedTotal =>
      _countLoader != null ? max(totalCount.value, loadedCount) : loadedCount;

  /// Clears loaded items and resets offset. Call loadInitial() again after.
  ///
  /// Bumps the load epoch so any [loadNextPage] still awaiting the loader
  /// from the previous dataset discards its result instead of appending
  /// stale rows onto the cleared list.
  void reset() {
    _epoch++;
    loadedItems.value = [];
    _currentOffset = 0;
    hasMore.value = true;
    isLoadingMore.value = false;
    totalCount.value = 0;
    error.value = null;
  }

  void dispose() {
    loadedItems.dispose();
    hasMore.dispose();
    isLoadingMore.dispose();
    totalCount.dispose();
    error.dispose();
  }
}
