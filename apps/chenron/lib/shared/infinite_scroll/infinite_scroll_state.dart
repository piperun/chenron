import "dart:math";
import "package:signals/signals.dart";

class InfiniteScrollState<T> {
  final Signal<List<T>> loadedItems = signal([]);
  final Signal<bool> hasMore = signal(true);
  final Signal<bool> isLoadingMore = signal(false);
  final Signal<int> totalCount = signal(0);
  final int pageSize;

  final Future<List<T>> Function(int limit, int offset) _loader;
  final Future<int> Function()? _countLoader;
  int _currentOffset = 0;

  InfiniteScrollState({
    required Future<List<T>> Function(int limit, int offset) loader,
    Future<int> Function()? countLoader,
    this.pageSize = 50,
  })  : _loader = loader,
        _countLoader = countLoader;

  /// Loads the total count (if countLoader provided) and the first page.
  Future<void> loadInitial() async {
    if (_countLoader != null) {
      totalCount.value = await _countLoader();
    }
    await loadNextPage();
  }

  /// Appends the next page of items. No-op if already loading or no more items.
  Future<void> loadNextPage() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;

    try {
      final newItems = await _loader(pageSize, _currentOffset);
      loadedItems.value = [...loadedItems.value, ...newItems];
      _currentOffset += newItems.length;
      hasMore.value = newItems.length >= pageSize;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Eagerly loads all remaining pages. Used when filter activates and
  /// in-memory filtering needs the complete dataset.
  Future<void> loadAll() async {
    while (hasMore.value) {
      await loadNextPage();
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
  void reset() {
    loadedItems.value = [];
    _currentOffset = 0;
    hasMore.value = true;
    isLoadingMore.value = false;
    totalCount.value = 0;
  }

  void dispose() {
    loadedItems.dispose();
    hasMore.dispose();
    isLoadingMore.dispose();
    totalCount.dispose();
  }
}
