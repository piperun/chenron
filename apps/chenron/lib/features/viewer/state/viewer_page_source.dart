import "dart:async";
import "dart:collection";

import "package:database/database.dart";
import "package:database/features.dart";
import "package:signals/signals.dart";

abstract interface class ViewerPageRepository {
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  });

  Future<int> count(ViewerQuery query);

  Future<List<ViewerTagFacet>> loadTagFacets(ViewerQuery query);

  Stream<void> invalidations();

  Future<ViewerSelectionLease> createSelectionLease({
    required ViewerQuery query,
    Set<ViewerItemKey>? onlyKeys,
    Set<ViewerItemKey> excludedKeys = const <ViewerItemKey>{},
  });

  Future<List<FolderItem>> loadSelectionLeaseBatch(
    ViewerSelectionLease lease, {
    required int limit,
  });

  Future<void> consumeSelectionLeaseBatch(
    ViewerSelectionLease lease,
    Iterable<ViewerItemKey> consumed,
  );

  Future<void> releaseSelectionLease(ViewerSelectionLease lease);
}

class ViewerPageSource {
  ViewerPageSource({
    required ViewerPageRepository repository,
    this.pageSize = defaultPageSize,
    this.maxCachedPages = defaultMaxCachedPages,
  }) : _repository = repository {
    if (pageSize <= 0) {
      throw ArgumentError.value(pageSize, "pageSize", "must be positive");
    }
    if (maxCachedPages <= 0) {
      throw ArgumentError.value(
        maxCachedPages,
        "maxCachedPages",
        "must be positive",
      );
    }
    _invalidationSubscription =
        _repository.invalidations().listen((_) => _scheduleInvalidation());
  }

  static const int defaultPageSize = 100;
  static const int defaultMaxCachedPages = 5;

  final ViewerPageRepository _repository;
  final int pageSize;
  final int maxCachedPages;
  final Signal<int> revision = signal(0);
  final Signal<int> totalCount = signal(0);
  final Signal<Object?> countError = signal(null);
  final Signal<Object?> tagFacetsError = signal(null);
  final Signal<List<ViewerTagFacet>> tagFacets = signal(const []);
  final LinkedHashMap<int, List<FolderItem>> _pages = LinkedHashMap();
  final Map<int, Future<void>> _inFlight = <int, Future<void>>{};
  final Map<int, Object> _loadIdentities = <int, Object>{};
  final Map<int, Object> _pageErrors = <int, Object>{};
  Future<void>? _summaryLoad;
  Object? _summaryLoadIdentity;
  StreamSubscription<void>? _invalidationSubscription;
  Future<void>? _invalidationCancellation;
  Object? _subscriptionCancellationError;
  ViewerQuery? _query;
  Object _generation = Object();
  Timer? _invalidationTimer;
  bool _disposed = false;

  int get cachedPageCount => _pages.length;
  int get cachedRowCount =>
      _pages.values.fold(0, (total, page) => total + page.length);
  int get activeLoadCount => _inFlight.length;
  int get activeSummaryLoadCount => _summaryLoad == null ? 0 : 1;
  int get activeSubscriptionCount => _invalidationSubscription == null ? 0 : 1;

  /// Completes after invalidation-subscription cleanup settles during dispose.
  ///
  /// The future completes normally even when cancellation fails. In that case
  /// [subscriptionCancellationError] retains the single failure object for
  /// read-only lifecycle diagnostics. It is null before cancellation starts.
  Future<void>? get invalidationCancellation => _invalidationCancellation;

  /// The one bounded invalidation-subscription cancellation failure, if any.
  ///
  /// Query and page-load failures use their dedicated reactive state. This
  /// separate read-only value remains available after signals are disposed.
  Object? get subscriptionCancellationError => _subscriptionCancellationError;

  FolderItem? itemAt(int index) {
    if (_disposed || index < 0 || _query == null) return null;
    final pageIndex = index ~/ pageSize;
    final page = _pages.remove(pageIndex);
    if (page != null) {
      _pages[pageIndex] = page;
      final indexInPage = index % pageSize;
      return indexInPage < page.length ? page[indexInPage] : null;
    }
    if (!_pageErrors.containsKey(pageIndex)) {
      unawaited(_startPageLoad(pageIndex));
    }
    return null;
  }

  Object? errorAt(int index) =>
      index < 0 ? null : _pageErrors[index ~/ pageSize];

  Future<void> setQuery(ViewerQuery query) async {
    if (_disposed || _query == query) return;
    _invalidationTimer?.cancel();
    _invalidationTimer = null;
    _query = query;
    final generation = _beginGeneration();
    await _startSummaryLoad(
      query,
      generation,
      loadCount: true,
      loadTagFacets: true,
    );
  }

  Future<void> retryPage(int pageIndex) async {
    if (_disposed || _query == null || pageIndex < 0) return;
    _pageErrors.remove(pageIndex);
    revision.value++;
    await _startPageLoad(pageIndex);
  }

  Future<void> retrySummary() {
    final existing = _summaryLoad;
    if (existing != null) return existing;
    final query = _query;
    if (_disposed || query == null) return Future<void>.value();
    final retryCount = countError.value != null;
    final retryTagFacets = tagFacetsError.value != null;
    if (!retryCount && !retryTagFacets) return Future<void>.value();
    if (retryCount) countError.value = null;
    if (retryTagFacets) tagFacetsError.value = null;
    revision.value++;
    return _startSummaryLoad(
      query,
      _generation,
      loadCount: retryCount,
      loadTagFacets: retryTagFacets,
    );
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _generation = Object();
    _query = null;
    _invalidationTimer?.cancel();
    _invalidationTimer = null;
    final invalidationSubscription = _invalidationSubscription;
    if (invalidationSubscription != null) {
      _invalidationCancellation =
          _cancelInvalidationSubscription(invalidationSubscription);
    }
    _pages.clear();
    _inFlight.clear();
    _loadIdentities.clear();
    _pageErrors.clear();
    _summaryLoad = null;
    _summaryLoadIdentity = null;
    totalCount.value = 0;
    tagFacets.value = const <ViewerTagFacet>[];
    countError.value = null;
    tagFacetsError.value = null;
    revision.value++;
    revision.dispose();
    totalCount.dispose();
    countError.dispose();
    tagFacetsError.dispose();
    tagFacets.dispose();
  }

  Future<void> _cancelInvalidationSubscription(
    StreamSubscription<void> subscription,
  ) async {
    try {
      await subscription.cancel();
    } catch (caughtError) {
      _subscriptionCancellationError = caughtError;
    } finally {
      if (identical(_invalidationSubscription, subscription)) {
        _invalidationSubscription = null;
      }
    }
  }

  Object _beginGeneration() {
    final generation = Object();
    _generation = generation;
    _pages.clear();
    _inFlight.clear();
    _loadIdentities.clear();
    _pageErrors.clear();
    _summaryLoad = null;
    _summaryLoadIdentity = null;
    totalCount.value = 0;
    tagFacets.value = const <ViewerTagFacet>[];
    countError.value = null;
    tagFacetsError.value = null;
    revision.value++;
    return generation;
  }

  Future<void> _startSummaryLoad(
    ViewerQuery query,
    Object generation, {
    required bool loadCount,
    required bool loadTagFacets,
  }) {
    final existing = _summaryLoad;
    if (existing != null) return existing;
    final loadIdentity = Object();
    late final Future<void> load;
    load = Future.wait<void>(<Future<void>>[
      if (loadCount) _loadCount(query, generation),
      if (loadTagFacets) _loadTagFacets(query, generation),
    ]).whenComplete(() => _finishSummaryLoad(loadIdentity));
    _summaryLoadIdentity = loadIdentity;
    _summaryLoad = load;
    return load;
  }

  void _finishSummaryLoad(Object loadIdentity) {
    if (!identical(_summaryLoadIdentity, loadIdentity)) return;
    _summaryLoadIdentity = null;
    _summaryLoad = null;
  }

  Future<void> _loadCount(ViewerQuery query, Object generation) async {
    try {
      final count = await _repository.count(query);
      if (!_isCurrent(generation)) return;
      totalCount.value = count;
      countError.value = null;
      revision.value++;
    } catch (caughtError) {
      if (!_isCurrent(generation)) return;
      countError.value = caughtError;
      revision.value++;
    }
  }

  Future<void> _loadTagFacets(ViewerQuery query, Object generation) async {
    try {
      final facets = await _repository.loadTagFacets(query);
      if (!_isCurrent(generation)) return;
      tagFacets.value = List<ViewerTagFacet>.unmodifiable(facets);
      tagFacetsError.value = null;
      revision.value++;
    } catch (caughtError) {
      if (!_isCurrent(generation)) return;
      tagFacetsError.value = caughtError;
      revision.value++;
    }
  }

  Future<void> _startPageLoad(int pageIndex) {
    final existing = _inFlight[pageIndex];
    if (existing != null) return existing;
    final query = _query;
    if (_disposed || query == null) return Future<void>.value();
    final generation = _generation;
    final loadIdentity = Object();
    late final Future<void> load;
    load = _loadPage(pageIndex, query, generation, loadIdentity)
        .whenComplete(() => _finishPageLoad(pageIndex, loadIdentity));
    _inFlight[pageIndex] = load;
    _loadIdentities[pageIndex] = loadIdentity;
    return load;
  }

  Future<void> _loadPage(
    int pageIndex,
    ViewerQuery query,
    Object generation,
    Object loadIdentity,
  ) async {
    try {
      final loaded = await _repository.loadPage(
        query,
        limit: pageSize,
        offset: pageIndex * pageSize,
      );
      if (!_isCurrent(generation)) return;
      final boundedPage = List<FolderItem>.unmodifiable(
        loaded.length <= pageSize ? loaded : loaded.take(pageSize),
      );
      _pageErrors.remove(pageIndex);
      _pages.remove(pageIndex);
      _pages[pageIndex] = boundedPage;
      while (_pages.length > maxCachedPages) {
        _pages.remove(_pages.keys.first);
      }
      _finishPageLoad(pageIndex, loadIdentity);
      revision.value++;
    } catch (caughtError) {
      if (!_isCurrent(generation)) return;
      if (!_finishPageLoad(pageIndex, loadIdentity)) return;
      _pageErrors[pageIndex] = caughtError;
      revision.value++;
    }
  }

  bool _finishPageLoad(int pageIndex, Object loadIdentity) {
    if (!identical(_loadIdentities[pageIndex], loadIdentity)) return false;
    _loadIdentities.remove(pageIndex);
    _inFlight.removeWhere((index, _) => index == pageIndex);
    return true;
  }

  bool _isCurrent(Object generation) =>
      !_disposed && identical(_generation, generation);

  void _scheduleInvalidation() {
    if (_disposed || _invalidationTimer != null) return;
    _invalidationTimer = Timer(Duration.zero, () {
      _invalidationTimer = null;
      if (_disposed) return;
      final query = _query;
      if (query == null) return;
      final generation = _beginGeneration();
      unawaited(_startSummaryLoad(
        query,
        generation,
        loadCount: true,
        loadTagFacets: true,
      ));
    });
  }
}
