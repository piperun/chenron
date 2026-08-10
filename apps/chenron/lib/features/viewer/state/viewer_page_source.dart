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
  final Signal<Object?> error = signal(null);
  final Signal<List<ViewerTagFacet>> tagFacets = signal(const []);
  final LinkedHashMap<int, List<FolderItem>> _pages = LinkedHashMap();
  final Map<int, Future<void>> _inFlight = <int, Future<void>>{};
  final Map<int, Object> _pageErrors = <int, Object>{};
  StreamSubscription<void>? _invalidationSubscription;
  ViewerQuery? _query;
  Object _generation = Object();
  Timer? _invalidationTimer;
  bool _disposed = false;

  int get cachedPageCount => _pages.length;
  int get cachedRowCount =>
      _pages.values.fold(0, (total, page) => total + page.length);
  int get activeLoadCount => _inFlight.length;
  int get activeSubscriptionCount => _invalidationSubscription == null ? 0 : 1;

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
    await _loadSummary(query, generation);
  }

  Future<void> retryPage(int pageIndex) async {
    if (_disposed || _query == null || pageIndex < 0) return;
    final pageError = _pageErrors.remove(pageIndex);
    if (identical(error.value, pageError)) error.value = null;
    revision.value++;
    await _startPageLoad(pageIndex);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _generation = Object();
    _query = null;
    _invalidationTimer?.cancel();
    _invalidationTimer = null;
    final invalidationSubscription = _invalidationSubscription;
    _invalidationSubscription = null;
    unawaited(invalidationSubscription?.cancel());
    _pages.clear();
    _inFlight.clear();
    _pageErrors.clear();
    totalCount.value = 0;
    tagFacets.value = const <ViewerTagFacet>[];
    error.value = null;
    revision.value++;
    revision.dispose();
    totalCount.dispose();
    error.dispose();
    tagFacets.dispose();
  }

  Object _beginGeneration() {
    final generation = Object();
    _generation = generation;
    _pages.clear();
    _inFlight.clear();
    _pageErrors.clear();
    totalCount.value = 0;
    tagFacets.value = const <ViewerTagFacet>[];
    error.value = null;
    revision.value++;
    return generation;
  }

  Future<void> _loadSummary(ViewerQuery query, Object generation) async {
    await Future.wait<void>(<Future<void>>[
      _loadCount(query, generation),
      _loadTagFacets(query, generation),
    ]);
  }

  Future<void> _loadCount(ViewerQuery query, Object generation) async {
    try {
      final count = await _repository.count(query);
      if (!_isCurrent(generation)) return;
      totalCount.value = count;
      revision.value++;
    } catch (caughtError) {
      _recordSummaryError(caughtError, generation);
    }
  }

  Future<void> _loadTagFacets(ViewerQuery query, Object generation) async {
    try {
      final facets = await _repository.loadTagFacets(query);
      if (!_isCurrent(generation)) return;
      tagFacets.value = List<ViewerTagFacet>.unmodifiable(facets);
      revision.value++;
    } catch (caughtError) {
      _recordSummaryError(caughtError, generation);
    }
  }

  void _recordSummaryError(Object caughtError, Object generation) {
    if (!_isCurrent(generation)) return;
    error.value = caughtError;
    revision.value++;
  }

  Future<void> _startPageLoad(int pageIndex) {
    final existing = _inFlight[pageIndex];
    if (existing != null) return existing;
    final query = _query;
    if (_disposed || query == null) return Future<void>.value();
    final generation = _generation;
    late final Future<void> load;
    load = _loadPage(pageIndex, query, generation).whenComplete(() {
      _inFlight.removeWhere(
        (index, activeLoad) =>
            index == pageIndex && identical(activeLoad, load),
      );
    });
    _inFlight[pageIndex] = load;
    return load;
  }

  Future<void> _loadPage(
    int pageIndex,
    ViewerQuery query,
    Object generation,
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
      revision.value++;
    } catch (caughtError) {
      if (!_isCurrent(generation)) return;
      _pageErrors[pageIndex] = caughtError;
      error.value = caughtError;
      revision.value++;
    }
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
      unawaited(_loadSummary(query, generation));
    });
  }
}
