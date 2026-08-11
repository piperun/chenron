import "dart:async";

import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/features/viewer/state/viewer_selection_state.dart";
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
  });

  final int retainedRows;
  final int activeSubscriptions;
  final bool disposed;
}

class ViewerPresenter {
  ViewerPresenter({
    ViewerPageRepository? repository,
    ViewerModel? model,
    SearchFilter? searchFilter,
    TagFilterNotifier? tagFilterState,
    ViewerSelectionState? selectionState,
    String? folderId,
  })  : searchFilter = searchFilter ?? SearchFilter(),
        tagFilterState = tagFilterState ?? TagFilterNotifier(),
        _ownsSearchFilter = searchFilter == null,
        _ownsTagFilterState = tagFilterState == null,
        _folderId = folderId,
        selectionState = selectionState ?? ViewerSelectionState(),
        pageSource = ViewerPageSource(
          repository: repository ?? model ?? ViewerModel(),
        ),
        query = signal(ViewerQuery(folderId: folderId)) {
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
  final ViewerPageSource pageSource;
  final ViewerSelectionState selectionState;
  final Signal<ViewerQuery> query;

  final bool _ownsSearchFilter;
  final bool _ownsTagFilterState;
  final String? _folderId;
  void Function()? _disposeQueryEffect;
  ViewerQuery? _lastAppliedQuery;
  Future<void>? _pendingQueryUpdate;
  bool _disposed = false;

  ViewerRetentionSnapshot get retentionSnapshot => ViewerRetentionSnapshot(
        retainedRows: pageSource.cachedRowCount,
        activeSubscriptions: pageSource.activeSubscriptionCount,
        disposed: _disposed,
      );

  Future<void> init() async {
    if (_disposed) return;
    _disposeQueryEffect ??= effect(_synchronizeQuery);
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
    pageSource.dispose();
    query.dispose();
    selectionState.dispose();
    selectedTypes.dispose();
    viewMode.dispose();
    sortMode.dispose();
    if (_ownsTagFilterState) tagFilterState.dispose();
    if (_ownsSearchFilter) searchFilter.dispose();
  }
}
