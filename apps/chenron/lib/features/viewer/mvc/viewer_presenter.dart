import "dart:async";

import "package:catalog/catalog.dart";
import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/shared/search/query_parser.dart";
import "package:chenron/shared/tag_filter/tag_filter_notifier.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:signals/signals_flutter.dart";

class ViewerRetentionSnapshot {
  const ViewerRetentionSnapshot({
    required this.retainedRows,
    required this.activeSubscriptions,
    required this.disposed,
    this.cachedPages = 0,
    this.activePageLoads = 0,
    this.queuedPageLoads = 0,
    this.retainedPageErrors = 0,
    this.droppedPageRequests = 0,
    this.activeSummaryLoads = 0,
    this.queuedSummaryRequests = 0,
    this.retainedSummaryRequests = 0,
    this.dirtySummaryRefresh = false,
    this.registeredInvalidationSources = 0,
    this.dirtyInvalidationSources = 0,
    this.bulkUpdateDepth = 0,
    this.settled = false,
  });

  final int retainedRows;
  final int activeSubscriptions;
  final bool disposed;
  final int cachedPages;
  final int activePageLoads;
  final int queuedPageLoads;
  final int retainedPageErrors;
  final int droppedPageRequests;
  final int activeSummaryLoads;
  final int queuedSummaryRequests;
  final int retainedSummaryRequests;
  final bool dirtySummaryRefresh;
  final int registeredInvalidationSources;
  final int dirtyInvalidationSources;
  final int bulkUpdateDepth;
  final bool settled;
}

class ViewerPresenter {
  ViewerPresenter({
    CatalogSource<FolderItem, ViewerQuery>? repository,
    ViewerModel? model,
    SearchFilter? searchFilter,
    TagFilterNotifier? tagFilterState,
    CatalogSelectionState<ViewerItemKey, ViewerQuery>? selectionState,
    String? folderId,
  })  : searchFilter = searchFilter ?? SearchFilter(),
        tagFilterState = tagFilterState ?? TagFilterNotifier(),
        _ownsSearchFilter = searchFilter == null,
        _ownsTagFilterState = tagFilterState == null,
        _folderId = folderId,
        selectionState = selectionState ??
            CatalogSelectionState<ViewerItemKey, ViewerQuery>(),
        pageSource = CatalogPager<FolderItem, ViewerQuery>(
          source: repository ?? model ?? ViewerModel(),
        ),
        query = signal(ViewerQuery(
          folderId: folderId,
          includeFolderParents: folderId != null,
        )) {
    if (_ownsSearchFilter) this.searchFilter.setup();
  }

  final Signal<Set<FolderItemType>> selectedTypes = signal(
    const <FolderItemType>{
      FolderItemType.folder,
      FolderItemType.link,
      FolderItemType.document,
    },
  );
  final Signal<ViewMode> viewMode = signal(ViewMode.grid);
  final Signal<SortMode> sortMode = signal(SortMode.nameAsc);
  final SearchFilter searchFilter;
  final TagFilterNotifier tagFilterState;
  final CatalogPager<FolderItem, ViewerQuery> pageSource;
  final CatalogSelectionState<ViewerItemKey, ViewerQuery> selectionState;
  final Signal<ViewerQuery> query;

  final bool _ownsSearchFilter;
  final bool _ownsTagFilterState;
  final String? _folderId;
  void Function()? _disposeQueryEffect;
  void Function()? _disposeSummarySelectionEffect;
  ViewerQuery? _lastAppliedQuery;
  int? _selectionSummaryGeneration;
  Future<void>? _pendingQueryUpdate;
  bool _disposed = false;

  ViewerRetentionSnapshot get retentionSnapshot => ViewerRetentionSnapshot(
        retainedRows: pageSource.cachedRowCount,
        activeSubscriptions: pageSource.activeSubscriptionCount,
        disposed: _disposed,
        cachedPages: pageSource.cachedPageCount,
        activePageLoads: pageSource.activeLoadCount,
        queuedPageLoads: pageSource.queuedLoadCount,
        retainedPageErrors: pageSource.retainedPageErrorCount,
        droppedPageRequests: pageSource.droppedPageRequestCount,
        activeSummaryLoads: pageSource.activeSummaryLoadCount,
        queuedSummaryRequests: pageSource.queuedSummaryRequestCount,
        retainedSummaryRequests: pageSource.retainedSummaryRequestCount,
        dirtySummaryRefresh: pageSource.hasDirtySummaryRefresh,
        registeredInvalidationSources:
            pageSource.invalidationCoordinator.registeredSourceCount,
        dirtyInvalidationSources:
            pageSource.invalidationCoordinator.dirtySourceCount,
        bulkUpdateDepth: pageSource.invalidationCoordinator.bulkUpdateDepth,
        settled: pageSource.isSettled,
      );

  Future<void> init() async {
    if (_disposed) return;
    _disposeQueryEffect ??= effect(_synchronizeQuery);
    _disposeSummarySelectionEffect ??= effect(_synchronizeSelectionSummary);
    await _pendingQueryUpdate;
  }

  void onTypesChanged(Set<FolderItemType> types) {
    selectedTypes.value = Set<FolderItemType>.of(types);
  }

  void onViewModeChanged(ViewMode mode) {
    viewMode.value = mode;
  }

  void onSortChanged(SortMode mode) {
    sortMode.value = mode;
  }

  void onSearchSubmitted(String rawQuery) {
    batch(() {
      final cleanQuery = tagFilterState.parseAndAddFromQuery(rawQuery);
      searchFilter.controller.value = cleanQuery;
    });
  }

  void _synchronizeQuery() {
    final parsed = QueryParser.parseTags(searchFilter.controller.query.value);
    final resolvedTags = tagFilterState.resolveMergedTags(
      included: parsed.includedTags,
      excluded: parsed.excludedTags,
    );
    final nextQuery = ViewerQuery(
      folderId: _folderId,
      includeFolderParents: _folderId != null,
      searchText: parsed.cleanQuery,
      types: Set<FolderItemType>.of(selectedTypes.value),
      includedTags: resolvedTags.included,
      excludedTags: resolvedTags.excluded,
      sort: _viewerSort(sortMode.value),
    );
    if (_lastAppliedQuery == nextQuery) return;
    _lastAppliedQuery = nextQuery;
    query.value = nextQuery;
    selectionState.synchronizeQuery(nextQuery);
    _pendingQueryUpdate = pageSource.setQuery(nextQuery);
    unawaited(_pendingQueryUpdate);
  }

  void _synchronizeSelectionSummary() {
    final generation = pageSource.summaryGeneration.value;
    final previous = _selectionSummaryGeneration;
    _selectionSummaryGeneration = generation;
    if (previous != null && previous != generation) {
      selectionState.clear();
    }
  }

  ViewerSort _viewerSort(SortMode mode) => switch (mode) {
        SortMode.nameAsc => ViewerSort.nameAsc,
        SortMode.nameDesc => ViewerSort.nameDesc,
        SortMode.dateAsc => ViewerSort.dateAsc,
        SortMode.dateDesc => ViewerSort.dateDesc,
      };

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _disposeQueryEffect?.call();
    _disposeQueryEffect = null;
    _disposeSummarySelectionEffect?.call();
    _disposeSummarySelectionEffect = null;
    pageSource.dispose();
    query.dispose();
    selectionState.dispose();
    selectedTypes.dispose();
    viewMode.dispose();
    sortMode.dispose();
    if (_ownsTagFilterState) tagFilterState.dispose();
    if (_ownsSearchFilter) searchFilter.dispose();
  }

  Future<void> disposeAndWait() {
    dispose();
    return pageSource.disposeAndWait();
  }
}
