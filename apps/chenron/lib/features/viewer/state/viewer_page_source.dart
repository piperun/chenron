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

  Future<int> countSelectionLease(ViewerSelectionLease lease);

  Future<void> consumeSelectionLeaseBatch(
    ViewerSelectionLease lease,
    Iterable<ViewerItemKey> consumed,
  );

  Future<void> releaseSelectionLease(ViewerSelectionLease lease);
}

abstract interface class ViewerTagFacetSearchRepository {
  Future<List<ViewerTagFacet>> loadTagFacets(
    ViewerQuery query, {
    String searchText = "",
  });
}

abstract interface class ViewerInvalidationDomainRepository {
  Object get viewerInvalidationDomain;
}

final Expando<ViewerInvalidationCoordinator> _invalidationCoordinators =
    Expando<ViewerInvalidationCoordinator>("viewer invalidation coordinator");

ViewerInvalidationCoordinator _resolveInvalidationCoordinator(
  ViewerPageRepository repository,
) {
  final domain = repository is ViewerInvalidationDomainRepository
      ? (repository as ViewerInvalidationDomainRepository)
          .viewerInvalidationDomain
      : repository;
  return _invalidationCoordinators[domain] ??= ViewerInvalidationCoordinator();
}

class ViewerInvalidationCoordinator {
  final Set<ViewerPageSource> _sources = <ViewerPageSource>{};
  final Set<ViewerPageSource> _dirtySources = <ViewerPageSource>{};
  int _bulkUpdateDepth = 0;

  int get registeredSourceCount => _sources.length;
  int get dirtySourceCount => _dirtySources.length;
  int get bulkUpdateDepth => _bulkUpdateDepth;
  bool get isBulkUpdateActive => _bulkUpdateDepth > 0;

  Future<T> runBulkUpdate<T>(Future<T> Function() operation) async {
    _bulkUpdateDepth++;
    try {
      return await operation();
    } finally {
      // Async broadcast streams deliver the final committed invalidation on
      // the next event turn. Keep the outer boundary raised through that turn
      // so every registered source joins the same trailing refresh.
      if (_bulkUpdateDepth == 1) {
        await Future<void>.delayed(Duration.zero);
      }
      _bulkUpdateDepth--;
      if (_bulkUpdateDepth == 0) await _flushDirtySources();
    }
  }

  void _register(ViewerPageSource source) {
    _sources.add(source);
  }

  void _unregister(ViewerPageSource source) {
    _dirtySources.remove(source);
    _sources.remove(source);
  }

  void _markDirty(ViewerPageSource source) {
    if (_sources.contains(source) && !source.isDisposed) {
      _dirtySources.add(source);
    }
  }

  Future<void> _flushDirtySources() async {
    if (_dirtySources.isEmpty) return;
    final sources = _dirtySources
        .where((source) => _sources.contains(source) && !source.isDisposed)
        .toList(growable: false);
    _dirtySources.clear();
    await Future.wait<void>(
      sources.map((source) => source._refreshAfterInvalidation()),
    );
  }
}

abstract interface class ViewerBulkUpdateBoundary {
  Future<T> runBulkUpdate<T>(Future<T> Function() operation);
}

class ViewerPageSource implements ViewerBulkUpdateBoundary {
  ViewerPageSource({
    required ViewerPageRepository repository,
    this.pageSize = defaultPageSize,
    this.maxCachedPages = defaultMaxCachedPages,
    this.maxActivePageLoads = defaultMaxActivePageLoads,
    this.maxQueuedPageLoads = defaultMaxQueuedPageLoads,
    this.maxPageErrors = defaultMaxPageErrors,
    ViewerInvalidationCoordinator? invalidationCoordinator,
  })  : _repository = repository,
        _invalidationCoordinator = invalidationCoordinator ??
            _resolveInvalidationCoordinator(repository) {
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
    if (maxActivePageLoads <= 0 ||
        maxQueuedPageLoads <= 0 ||
        maxPageErrors <= 0) {
      throw ArgumentError("page-source bounds must be positive");
    }
    _invalidationSubscription =
        _repository.invalidations().listen((_) => _scheduleInvalidation());
    _invalidationCoordinator._register(this);
  }

  static const int defaultPageSize = 100;
  static const int defaultMaxCachedPages = 5;
  static const int defaultMaxActivePageLoads = 4;
  static const int defaultMaxQueuedPageLoads = 16;
  static const int defaultMaxPageErrors = 20;

  final ViewerPageRepository _repository;
  final ViewerInvalidationCoordinator _invalidationCoordinator;
  final int pageSize;
  final int maxCachedPages;
  final int maxActivePageLoads;
  final int maxQueuedPageLoads;
  final int maxPageErrors;
  final Signal<int> revision = signal(0);
  final Signal<int> summaryGeneration = signal(0);
  final Signal<int> totalCount = signal(0);
  final Signal<Object?> countError = signal(null);
  final Signal<Object?> tagFacetsError = signal(null);
  final Signal<List<ViewerTagFacet>> tagFacets = signal(const []);

  final LinkedHashMap<int, List<FolderItem>> _pages = LinkedHashMap();
  final Map<Object, Future<void>> _activePageLoads = <Object, Future<void>>{};
  final Map<int, Object> _currentPageLoads = <int, Object>{};
  final LinkedHashMap<int, _QueuedPageLoad> _queuedPageLoads = LinkedHashMap();
  final LinkedHashMap<int, Object> _pageErrors = LinkedHashMap();
  _ActiveSummaryLoad? _activeSummaryLoad;
  _QueuedSummarySlot? _queuedSummarySlot;
  StreamSubscription<void>? _invalidationSubscription;
  Future<void>? _invalidationCancellation;
  Future<void>? _disposalSettlement;
  Object? _subscriptionCancellationError;
  ViewerQuery? _query;
  Object _generation = Object();
  Timer? _invalidationTimer;
  int _droppedPageRequestCount = 0;
  bool _disposed = false;

  int get cachedPageCount => _pages.length;
  ViewerPageRepository get repository => _repository;
  int get cachedRowCount =>
      _pages.values.fold(0, (total, page) => total + page.length);
  int get activeLoadCount => _activePageLoads.length;
  int get queuedLoadCount => _queuedPageLoads.length;
  int get retainedPageErrorCount => _pageErrors.length;
  int get droppedPageRequestCount => _droppedPageRequestCount;
  int get activeSummaryLoadCount => _activeSummaryLoad == null ? 0 : 1;
  int get queuedSummaryRequestCount => _queuedSummarySlot == null ? 0 : 1;
  int get retainedSummaryRequestCount =>
      activeSummaryLoadCount + queuedSummaryRequestCount;
  bool get hasDirtySummaryRefresh => _queuedSummarySlot != null;
  int get activeSubscriptionCount => _invalidationSubscription == null ? 0 : 1;
  ViewerInvalidationCoordinator get invalidationCoordinator =>
      _invalidationCoordinator;
  bool get isDisposed => _disposed;
  bool get isSettled =>
      _activePageLoads.isEmpty &&
      _activeSummaryLoad == null &&
      _queuedPageLoads.isEmpty &&
      _queuedSummarySlot == null &&
      _invalidationSubscription == null;
  bool get isCountReady =>
      !_disposed &&
      _query != null &&
      !_hasPendingCountForCurrentGeneration &&
      countError.value == null;

  Future<void>? get invalidationCancellation => _invalidationCancellation;
  Future<void>? get disposalSettlement => _disposalSettlement;
  Object? get subscriptionCancellationError => _subscriptionCancellationError;

  bool get _hasPendingCountForCurrentGeneration {
    final active = _activeSummaryLoad?.request;
    if (active != null &&
        identical(active.generation, _generation) &&
        active.loadCount) {
      return true;
    }
    final queued = _queuedSummarySlot;
    return queued != null &&
        identical(queued.generation, _generation) &&
        queued.loadCount;
  }

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
      unawaited(_requestPageLoad(pageIndex));
    }
    return null;
  }

  Object? errorAt(int index) =>
      index < 0 ? null : _pageErrors[index ~/ pageSize];

  Future<void> setQuery(ViewerQuery query) {
    if (_disposed || _query == query) return Future<void>.value();
    _invalidationTimer?.cancel();
    _invalidationTimer = null;
    _query = query;
    final generation = _beginGeneration();
    return _requestSummaryLoad(
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
    await _requestPageLoad(pageIndex);
  }

  Future<void> retrySummary() {
    final query = _query;
    if (_disposed || query == null) return Future<void>.value();
    final retryCount = countError.value != null;
    final retryTagFacets = tagFacetsError.value != null;
    if (!retryCount && !retryTagFacets) return Future<void>.value();
    return _requestSummaryLoad(
      query,
      _generation,
      loadCount: retryCount,
      loadTagFacets: retryTagFacets,
    );
  }

  Future<List<ViewerTagFacet>> searchTagFacets(String searchText) {
    final query = _query;
    if (_disposed || query == null) {
      return Future<List<ViewerTagFacet>>.value(const <ViewerTagFacet>[]);
    }
    final repository = _repository;
    if (repository is ViewerTagFacetSearchRepository) {
      return (repository as ViewerTagFacetSearchRepository)
          .loadTagFacets(query, searchText: searchText);
    }
    final normalized = searchText.toLowerCase();
    return Future<List<ViewerTagFacet>>.value(
      tagFacets.value
          .where(
            (facet) => facet.tag.name.toLowerCase().contains(normalized),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<T> runBulkUpdate<T>(Future<T> Function() operation) =>
      _invalidationCoordinator.runBulkUpdate(operation);

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _generation = Object();
    _query = null;
    _invalidationTimer?.cancel();
    _invalidationTimer = null;
    _invalidationCoordinator._unregister(this);

    for (final queued in _queuedPageLoads.values) {
      queued.complete();
    }
    _queuedPageLoads.clear();
    _currentPageLoads.clear();
    final queuedSummary = _queuedSummarySlot;
    _queuedSummarySlot = null;
    queuedSummary?.complete();

    final invalidationSubscription = _invalidationSubscription;
    if (invalidationSubscription != null) {
      _invalidationCancellation =
          _cancelInvalidationSubscription(invalidationSubscription);
    }
    _pages.clear();
    _pageErrors.clear();
    batch(() {
      totalCount.value = 0;
      tagFacets.value = const <ViewerTagFacet>[];
      countError.value = null;
      tagFacetsError.value = null;
      revision.value++;
    });
    revision.dispose();
    summaryGeneration.dispose();
    totalCount.dispose();
    countError.dispose();
    tagFacetsError.dispose();
    tagFacets.dispose();

    final unsettled = <Future<void>>[
      ..._activePageLoads.values,
      if (_activeSummaryLoad case final active?) active.settlement,
      if (_invalidationCancellation case final cancellation?) cancellation,
    ];
    _disposalSettlement = Future.wait<void>(unsettled);
  }

  Future<void> disposeAndWait() {
    dispose();
    return _disposalSettlement ?? Future<void>.value();
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
    _currentPageLoads.clear();
    for (final queued in _queuedPageLoads.values) {
      queued.complete();
    }
    _queuedPageLoads.clear();
    _pageErrors.clear();
    batch(() {
      summaryGeneration.value++;
      totalCount.value = 0;
      tagFacets.value = const <ViewerTagFacet>[];
      countError.value = null;
      tagFacetsError.value = null;
      revision.value++;
    });
    return generation;
  }

  Future<void> _requestSummaryLoad(
    ViewerQuery query,
    Object generation, {
    required bool loadCount,
    required bool loadTagFacets,
  }) {
    if (!_isCurrent(generation) || (!loadCount && !loadTagFacets)) {
      return Future<void>.value();
    }

    final active = _activeSummaryLoad;
    if (active == null) {
      final request = _SummaryRequest(
        query: query,
        generation: generation,
        loadCount: loadCount,
        loadTagFacets: loadTagFacets,
      );
      _startSummaryLoad(request);
      return request.future;
    }
    if (active.request.covers(
      generation: generation,
      loadCount: loadCount,
      loadTagFacets: loadTagFacets,
    )) {
      return active.request.future;
    }

    final queued = _queuedSummarySlot;
    if (queued == null) {
      final slot = _QueuedSummarySlot(
        query: query,
        generation: generation,
        loadCount: loadCount,
        loadTagFacets: loadTagFacets,
      );
      _queuedSummarySlot = slot;
      return slot.future;
    }
    if (identical(queued.generation, generation)) {
      queued.merge(
        query: query,
        loadCount: loadCount,
        loadTagFacets: loadTagFacets,
      );
    } else {
      queued.replace(
        query: query,
        generation: generation,
        loadCount: loadCount,
        loadTagFacets: loadTagFacets,
      );
    }
    return queued.future;
  }

  void _startSummaryLoad(_SummaryRequest request) {
    final active = _ActiveSummaryLoad(request);
    _activeSummaryLoad = active;
    active.settlement = _executeSummaryLoad(request).then<void>(
      (_) => _finishSummaryLoad(active),
      onError: (Object error, StackTrace stackTrace) {
        _finishSummaryLoad(active, error, stackTrace);
      },
    );
  }

  Future<void> _executeSummaryLoad(_SummaryRequest request) async {
    await Future.wait<void>(<Future<void>>[
      if (request.loadCount)
        _loadCount(request).whenComplete(() => request.loadCount = false),
      if (request.loadTagFacets)
        _loadTagFacets(request)
            .whenComplete(() => request.loadTagFacets = false),
    ]);
  }

  Future<void> _loadCount(_SummaryRequest request) async {
    late final int count;
    try {
      count = await _repository.count(request.query);
    } catch (caughtError) {
      if (!_isCurrent(request.generation)) return;
      batch(() {
        countError.value = caughtError;
        revision.value++;
      });
      return;
    }
    if (!_isCurrent(request.generation)) return;
    batch(() {
      totalCount.value = count;
      countError.value = null;
      revision.value++;
    });
  }

  Future<void> _loadTagFacets(_SummaryRequest request) async {
    late final List<ViewerTagFacet> facets;
    try {
      facets = await _repository.loadTagFacets(request.query);
    } catch (caughtError) {
      if (!_isCurrent(request.generation)) return;
      batch(() {
        tagFacetsError.value = caughtError;
        revision.value++;
      });
      return;
    }
    if (!_isCurrent(request.generation)) return;
    batch(() {
      tagFacets.value = List<ViewerTagFacet>.unmodifiable(facets);
      tagFacetsError.value = null;
      revision.value++;
    });
  }

  void _finishSummaryLoad(
    _ActiveSummaryLoad active, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!identical(_activeSummaryLoad, active)) return;
    _activeSummaryLoad = null;
    active.request.complete(error, stackTrace);
    if (_disposed) return;
    final queued = _queuedSummarySlot;
    _queuedSummarySlot = null;
    if (queued == null) return;
    if (_isCurrent(queued.generation)) {
      _startSummaryLoad(queued.toRequest());
    } else {
      queued.complete();
    }
  }

  Future<void> _requestPageLoad(int pageIndex) {
    final currentIdentity = _currentPageLoads[pageIndex];
    if (currentIdentity != null) {
      return _activePageLoads[currentIdentity] ?? Future<void>.value();
    }
    final queued = _queuedPageLoads[pageIndex];
    if (queued != null) return queued.future;
    final query = _query;
    if (_disposed || query == null) return Future<void>.value();
    final generation = _generation;
    if (_activePageLoads.length < maxActivePageLoads) {
      return _startPageLoad(pageIndex, query, generation);
    }

    if (_queuedPageLoads.length >= maxQueuedPageLoads) {
      final droppedIndex = _queuedPageLoads.keys.first;
      final dropped = _queuedPageLoads.remove(droppedIndex)!;
      dropped.complete();
      _droppedPageRequestCount++;
      revision.value++;
    }
    final request = _QueuedPageLoad(
      pageIndex: pageIndex,
      query: query,
      generation: generation,
    );
    _queuedPageLoads[pageIndex] = request;
    return request.future;
  }

  Future<void> _startPageLoad(
    int pageIndex,
    ViewerQuery query,
    Object generation,
  ) {
    final identity = Object();
    _currentPageLoads[pageIndex] = identity;
    late final Future<void> load;
    load = _loadPage(pageIndex, query, generation, identity).whenComplete(
      () => _finishPageLoad(pageIndex, identity),
    );
    _activePageLoads[identity] = load;
    return load;
  }

  Future<void> _loadPage(
    int pageIndex,
    ViewerQuery query,
    Object generation,
    Object identity,
  ) async {
    try {
      final loaded = await _repository.loadPage(
        query,
        limit: pageSize,
        offset: pageIndex * pageSize,
      );
      if (!_isCurrentPageLoad(pageIndex, generation, identity)) return;
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
      if (!_isCurrentPageLoad(pageIndex, generation, identity)) return;
      _pageErrors.remove(pageIndex);
      _pageErrors[pageIndex] = caughtError;
      while (_pageErrors.length > maxPageErrors) {
        _pageErrors.remove(_pageErrors.keys.first);
      }
      revision.value++;
    }
  }

  void _finishPageLoad(int pageIndex, Object identity) {
    final hadActiveLoad = _activePageLoads.remove(identity) != null;
    if (!hadActiveLoad) return;
    if (identical(_currentPageLoads[pageIndex], identity)) {
      _currentPageLoads.remove(pageIndex);
    }
    _drainPageQueue();
  }

  void _drainPageQueue() {
    if (_disposed) return;
    while (_activePageLoads.length < maxActivePageLoads &&
        _queuedPageLoads.isNotEmpty) {
      final pageIndex = _queuedPageLoads.keys.first;
      final queued = _queuedPageLoads.remove(pageIndex)!;
      if (!_isCurrent(queued.generation)) {
        queued.complete();
        continue;
      }
      final load = _startPageLoad(
        queued.pageIndex,
        queued.query,
        queued.generation,
      );
      unawaited(load.whenComplete(queued.complete));
    }
  }

  bool _isCurrentPageLoad(
    int pageIndex,
    Object generation,
    Object identity,
  ) =>
      _isCurrent(generation) &&
      identical(_currentPageLoads[pageIndex], identity);

  bool _isCurrent(Object generation) =>
      !_disposed && identical(_generation, generation);

  void _scheduleInvalidation() {
    if (_disposed) return;
    if (_invalidationCoordinator.isBulkUpdateActive) {
      _invalidationCoordinator._markDirty(this);
      return;
    }
    if (_invalidationTimer != null) return;
    _invalidationTimer = Timer(Duration.zero, () {
      _invalidationTimer = null;
      if (_disposed) return;
      if (_invalidationCoordinator.isBulkUpdateActive) {
        _invalidationCoordinator._markDirty(this);
        return;
      }
      unawaited(_refreshAfterInvalidation());
    });
  }

  Future<void> _refreshAfterInvalidation() {
    final query = _query;
    if (_disposed || query == null) return Future<void>.value();
    final generation = _beginGeneration();
    return _requestSummaryLoad(
      query,
      generation,
      loadCount: true,
      loadTagFacets: true,
    );
  }
}

final class _QueuedPageLoad {
  _QueuedPageLoad({
    required this.pageIndex,
    required this.query,
    required this.generation,
  });

  final int pageIndex;
  final ViewerQuery query;
  final Object generation;
  final Completer<void> _completer = Completer<void>();

  Future<void> get future => _completer.future;
  void complete() {
    if (!_completer.isCompleted) _completer.complete();
  }
}

final class _SummaryRequest {
  _SummaryRequest({
    required this.query,
    required this.generation,
    required this.loadCount,
    required this.loadTagFacets,
    Completer<void>? completer,
  }) : _completer = completer ?? Completer<void>();

  final ViewerQuery query;
  final Object generation;
  bool loadCount;
  bool loadTagFacets;
  final Completer<void> _completer;

  Future<void> get future => _completer.future;

  bool covers({
    required Object generation,
    required bool loadCount,
    required bool loadTagFacets,
  }) =>
      identical(this.generation, generation) &&
      (!loadCount || this.loadCount) &&
      (!loadTagFacets || this.loadTagFacets);

  void complete([Object? error, StackTrace? stackTrace]) {
    if (!_completer.isCompleted) {
      if (error == null) {
        _completer.complete();
      } else {
        _completer.completeError(error, stackTrace);
      }
    }
  }
}

final class _QueuedSummarySlot {
  _QueuedSummarySlot({
    required this.query,
    required this.generation,
    required this.loadCount,
    required this.loadTagFacets,
  });

  ViewerQuery query;
  Object generation;
  bool loadCount;
  bool loadTagFacets;
  final Completer<void> _completer = Completer<void>();

  Future<void> get future => _completer.future;

  void merge({
    required ViewerQuery query,
    required bool loadCount,
    required bool loadTagFacets,
  }) {
    this.query = query;
    this.loadCount = this.loadCount || loadCount;
    this.loadTagFacets = this.loadTagFacets || loadTagFacets;
  }

  void replace({
    required ViewerQuery query,
    required Object generation,
    required bool loadCount,
    required bool loadTagFacets,
  }) {
    this.query = query;
    this.generation = generation;
    this.loadCount = loadCount;
    this.loadTagFacets = loadTagFacets;
  }

  _SummaryRequest toRequest() => _SummaryRequest(
        query: query,
        generation: generation,
        loadCount: loadCount,
        loadTagFacets: loadTagFacets,
        completer: _completer,
      );

  void complete([Object? error, StackTrace? stackTrace]) {
    if (_completer.isCompleted) return;
    if (error == null) {
      _completer.complete();
    } else {
      _completer.completeError(error, stackTrace);
    }
  }
}

final class _ActiveSummaryLoad {
  _ActiveSummaryLoad(this.request);

  final _SummaryRequest request;
  Future<void> get future => request.future;
  late Future<void> settlement;
}
