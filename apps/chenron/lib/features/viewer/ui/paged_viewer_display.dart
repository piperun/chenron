import "dart:async";
import "dart:collection";

import "package:chenron/features/folder_viewer/ui/components/tag_filter_modal.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/shared/item_display/item_grid_view.dart";
import "package:chenron/shared/item_display/item_list_view.dart";
import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/shared/item_display/item_viewport_source.dart";
import "package:chenron/shared/item_display/select_mode_action_bar.dart";
import "package:chenron/shared/item_display/view_mode_preference.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode_preference.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class PagedViewerDisplay extends StatefulWidget {
  const PagedViewerDisplay({
    super.key,
    required this.presenter,
    this.prefixItems = const <FolderItem>[],
    this.showSearch = true,
    this.displayModeContext,
    this.onItemTap,
    this.onDeleteRequested,
    this.onTagRequested,
    this.onRefreshMetadataRequested,
  });

  final ViewerPresenter presenter;
  final List<FolderItem> prefixItems;
  final bool showSearch;
  final String? displayModeContext;
  final ValueChanged<FolderItem>? onItemTap;
  final ValueChanged<List<FolderItem>>? onDeleteRequested;
  final ValueChanged<List<FolderItem>>? onTagRequested;
  final ValueChanged<List<FolderItem>>? onRefreshMetadataRequested;

  @override
  State<PagedViewerDisplay> createState() => _PagedViewerDisplayState();
}

class _PagedViewerDisplayState extends State<PagedViewerDisplay> {
  final Signal<DisplayMode> _displayMode = signal(DisplayMode.standard);
  final Signal<bool> _isSelectMode = signal(false);
  final Signal<Map<String, FolderItem>> _selectedItems = signal(
    <String, FolderItem>{},
  );
  final LinkedHashMap<String, FolderItem> _materializedItems =
      LinkedHashMap<String, FolderItem>();
  late final void Function() _disposeQuerySelectionEffect;
  ViewerQuery? _selectionQuery;
  bool _disposed = false;

  ViewerPresenter get _presenter => widget.presenter;

  @override
  void initState() {
    super.initState();
    _disposeQuerySelectionEffect = effect(() {
      final currentQuery = _presenter.query.value;
      if (_selectionQuery == currentQuery) return;
      _selectionQuery = currentQuery;
      _selectedItems.value = <String, FolderItem>{};
      _materializedItems.clear();
    });
    unawaited(_loadDisplayPreferences());
  }

  Future<void> _loadDisplayPreferences() async {
    final results = await Future.wait<Object>(<Future<Object>>[
      DisplayModePreference.getDisplayMode(
        context: widget.displayModeContext,
      ),
      ViewModePreference.getViewMode(context: widget.displayModeContext),
    ]);
    if (_disposed) return;
    _displayMode.value = results[0] as DisplayMode;
    _presenter.onViewModeChanged(results[1] as ViewMode);
  }

  @override
  void dispose() {
    _disposed = true;
    _disposeQuerySelectionEffect();
    _materializedItems.clear();
    _displayMode.dispose();
    _isSelectMode.dispose();
    _selectedItems.dispose();
    super.dispose();
  }

  Future<void> _handleViewModeChanged(ViewMode mode) async {
    _presenter.onViewModeChanged(mode);
    await ViewModePreference.setViewMode(
      mode,
      context: widget.displayModeContext,
    );
  }

  Future<void> _handleDisplayModeChanged(DisplayMode mode) async {
    _displayMode.value = mode;
    await DisplayModePreference.setDisplayMode(
      mode,
      context: widget.displayModeContext,
    );
  }

  void _toggleSelectMode() {
    final entering = !_isSelectMode.value;
    _isSelectMode.value = entering;
    if (!entering) {
      _selectedItems.value = <String, FolderItem>{};
      _presenter.clearSelectedItems();
    }
  }

  void _rememberMaterialized(FolderItem item) {
    final id = item.id;
    if (id == null) return;
    _materializedItems.remove(id);
    _materializedItems[id] = item;
    final maxRemembered =
        _presenter.pageSource.pageSize * _presenter.pageSource.maxCachedPages;
    while (_materializedItems.length > maxRemembered) {
      _materializedItems.remove(_materializedItems.keys.first);
    }
  }

  void _handleItemTap(FolderItem item) {
    final id = item.id;
    if (!_isSelectMode.value || id == null) {
      widget.onItemTap?.call(item);
      return;
    }
    final selected = Map<String, FolderItem>.of(_selectedItems.value);
    if (selected.remove(id) == null) {
      selected[id] = item;
    }
    _selectedItems.value = selected;
    _presenter.toggleItemSelection(id);
  }

  void _selectMaterializedItems() {
    if (!_isSelectMode.value) return;
    _selectedItems.value = Map<String, FolderItem>.of(_materializedItems);
    _presenter.selectedItemIds.value = _materializedItems.keys.toSet();
  }

  List<FolderItem> get _selectedValues =>
      _selectedItems.value.values.toList(growable: false);

  Future<void> _openTagFilterModal() async {
    final facets = _combinedTagFacets(
      _presenter.pageSource.tagFacets.value,
      widget.prefixItems,
      _presenter.query.value,
    );
    final result = await TagFilterModal.show(
      context: context,
      availableTags: facets.map((facet) => facet.tag).toList(growable: false),
      initialIncludedTags: _presenter.tagFilterState.includedTagNames,
      initialExcludedTags: _presenter.tagFilterState.excludedTagNames,
    );
    if (result == null) return;
    _presenter.tagFilterState.updateTags(
      included: result.included,
      excluded: result.excluded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(builder: (context) {
      final query = _presenter.query.value;
      final prefix = _filterAndSortPrefix(widget.prefixItems, query);
      final pageSource = _presenter.pageSource;
      pageSource.revision.value;
      final delegate = DelegatingItemViewportSource(
        length: () => pageSource.totalCount.value,
        itemAt: pageSource.itemAt,
        errorAt: pageSource.errorAt,
        retryAt: (index) => pageSource.retryPage(index ~/ pageSource.pageSize),
      );
      final source = PrefixedItemViewportSource(prefix, delegate);

      return Column(
        children: <Widget>[
          ItemToolbar(
            searchFilter: _presenter.searchFilter,
            selectedTypes: _presenter.selectedTypes.value,
            onFilterChanged: _presenter.onTypesChanged,
            sortMode: _presenter.sortMode.value,
            onSortChanged: _presenter.onSortChanged,
            viewMode: _presenter.viewMode.value,
            onViewModeChanged: (mode) => unawaited(
              _handleViewModeChanged(mode),
            ),
            displayMode: _displayMode.value,
            onDisplayModeChanged: (mode) => unawaited(
              _handleDisplayModeChanged(mode),
            ),
            showSearch: widget.showSearch,
            showTagFilterButton: true,
            includedTagNames: _presenter.tagFilterState.includedTagNames,
            excludedTagNames: _presenter.tagFilterState.excludedTagNames,
            onTagFilterPressed: _openTagFilterModal,
            onSearchSubmitted: _presenter.onSearchSubmitted,
            isDeleteMode: _isSelectMode.value,
            onDeleteModeToggled:
                widget.onDeleteRequested == null ? null : _toggleSelectMode,
          ),
          if (_isSelectMode.value)
            SelectModeActionBar(
              selectedCount: _selectedItems.value.length,
              linkCount: _selectedItems.value.values
                  .where((item) => item.type == FolderItemType.link)
                  .length,
              onSelectAll: _selectMaterializedItems,
              onTag: () => widget.onTagRequested?.call(_selectedValues),
              onRefreshMetadata: () =>
                  widget.onRefreshMetadataRequested?.call(_selectedValues),
              onDelete: () => widget.onDeleteRequested?.call(_selectedValues),
              onCancel: _toggleSelectMode,
            ),
          Expanded(
            child: _presenter.viewMode.value == ViewMode.grid
                ? ItemGridView(
                    source: source,
                    displayMode: _displayMode.value,
                    includedTagNames:
                        _presenter.tagFilterState.includedTagNames,
                    excludedTagNames:
                        _presenter.tagFilterState.excludedTagNames,
                    onItemTap: _handleItemTap,
                    onItemMaterialized: _rememberMaterialized,
                    onTagFilterTap: _presenter.tagFilterState.addIncluded,
                    aspectRatio: _displayMode.value.aspectRatio,
                    maxCrossAxisExtent: _displayMode.value.maxCrossAxisExtent,
                    isDeleteMode: _isSelectMode.value,
                    selectedItemIds: _presenter.selectedItemIds.value,
                  )
                : ItemListView(
                    source: source,
                    displayMode: _displayMode.value,
                    includedTagNames:
                        _presenter.tagFilterState.includedTagNames,
                    excludedTagNames:
                        _presenter.tagFilterState.excludedTagNames,
                    onItemTap: _handleItemTap,
                    onItemMaterialized: _rememberMaterialized,
                    isDeleteMode: _isSelectMode.value,
                    selectedItemIds: _presenter.selectedItemIds.value,
                  ),
          ),
        ],
      );
    });
  }
}

List<FolderItem> _filterAndSortPrefix(
  List<FolderItem> items,
  ViewerQuery query,
) {
  if (items.isEmpty) return const <FolderItem>[];
  final searchText = query.searchText.toLowerCase();
  final included = query.includedTags.map((tag) => tag.toLowerCase()).toSet();
  final excluded = query.excludedTags.map((tag) => tag.toLowerCase()).toSet();
  final filtered = items.where((item) {
    if (!query.types.contains(item.type)) return false;
    final tags = item.tags.map((tag) => tag.name.toLowerCase()).toSet();
    if (included.isNotEmpty && !tags.any(included.contains)) return false;
    if (excluded.isNotEmpty && tags.any(excluded.contains)) return false;
    if (searchText.isEmpty) return true;
    return _searchableText(item).contains(searchText) ||
        tags.any((tag) => tag.contains(searchText));
  }).toList(growable: false);
  final direction = switch (query.sort) {
    ViewerSort.nameAsc || ViewerSort.dateAsc => 1,
    ViewerSort.nameDesc || ViewerSort.dateDesc => -1,
  };
  filtered.sort((left, right) {
    final primary = switch (query.sort) {
      ViewerSort.nameAsc ||
      ViewerSort.nameDesc =>
        _displayName(left).toLowerCase().compareTo(
              _displayName(right).toLowerCase(),
            ),
      ViewerSort.dateAsc ||
      ViewerSort.dateDesc =>
        _createdAt(left).compareTo(_createdAt(right)),
    };
    if (primary != 0) return direction * primary;
    final typeOrder = left.type.index.compareTo(right.type.index);
    if (typeOrder != 0) return typeOrder;
    return (left.id ?? "").compareTo(right.id ?? "");
  });
  return filtered;
}

List<ViewerTagFacet> _combinedTagFacets(
  List<ViewerTagFacet> databaseFacets,
  List<FolderItem> prefixItems,
  ViewerQuery query,
) {
  final byId = <String, ViewerTagFacet>{
    for (final facet in databaseFacets) facet.tag.id: facet,
  };
  for (final item in _filterAndSortPrefix(
    prefixItems,
    query.withoutTagFilters(),
  )) {
    for (final tag in item.tags) {
      final existing = byId[tag.id];
      byId[tag.id] = ViewerTagFacet(
        tag: tag,
        itemCount: (existing?.itemCount ?? 0) + 1,
      );
    }
  }
  final facets = byId.values.toList(growable: false);
  facets.sort(
    (left, right) =>
        left.tag.name.toLowerCase().compareTo(right.tag.name.toLowerCase()),
  );
  return facets;
}

String _searchableText(FolderItem item) => item.map(
      link: (link) => link.url.toLowerCase(),
      document: (document) =>
          "${document.title} ${document.filePath}".toLowerCase(),
      folder: (folder) =>
          "${folder.title} ${folder.description} ${folder.folderId}"
              .toLowerCase(),
    );

String _displayName(FolderItem item) => item.map(
      link: (link) => link.url,
      document: (document) => document.title,
      folder: (folder) => folder.title,
    );

DateTime _createdAt(FolderItem item) => item.map(
      link: (link) => link.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      document: (document) =>
          document.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      folder: (folder) =>
          folder.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
