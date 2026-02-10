import "dart:async";
import "package:flutter/material.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/shared/item_display/item_stats_bar.dart";
import "package:chenron/shared/item_display/item_grid_view.dart";
import "package:chenron/shared/item_display/item_list_view.dart";
import "package:chenron/shared/item_display/filterable_item_display_notifier.dart";
import "package:chenron/features/folder_viewer/ui/components/tag_filter_modal.dart";
import "package:database/database.dart";
import "package:chenron/shared/search/search_features.dart";
import "package:chenron/shared/tag_filter/tag_filter_state.dart";
import "package:signals/signals_flutter.dart";

class FilterableItemDisplay extends StatefulWidget {
  final List<FolderItem> items;
  final ViewMode initialViewMode;
  final SortMode initialSortMode;
  final Set<FolderItemType> initialSelectedTypes;
  final DisplayMode displayMode;
  final String? displayModeContext;
  final IncludeOptions<SearchFeature> searchFeatures;
  final SearchFilter? externalSearchFilter;
  final TagFilterState? tagFilterState;

  final bool showTags;
  final bool showSearch;
  final bool enableTagFiltering;
  final void Function(FolderItem)? onItemTap;
  final void Function({required bool isDeleteMode, required int selectedCount})?
      onDeleteModeChanged;
  final void Function(List<FolderItem> items)? onDeleteRequested;

  const FilterableItemDisplay({
    super.key,
    required this.items,
    this.initialViewMode = ViewMode.grid,
    this.initialSortMode = SortMode.nameAsc,
    this.initialSelectedTypes = const {
      FolderItemType.link,
      FolderItemType.document,
      FolderItemType.folder,
    },
    this.displayMode = DisplayMode.standard,
    this.displayModeContext,
    this.searchFeatures = const IncludeOptions.empty(),
    this.externalSearchFilter,
    this.tagFilterState,
    this.showTags = true,
    this.showSearch = true,
    this.enableTagFiltering = true,
    this.onItemTap,
    this.onDeleteModeChanged,
    this.onDeleteRequested,
  });

  @override
  State<FilterableItemDisplay> createState() => _FilterableItemDisplayState();
}

class _FilterableItemDisplayState extends State<FilterableItemDisplay> {
  late final FilterableItemDisplayNotifier _notifier;
  late final void Function() _disposeDeleteModeEffect;

  @override
  void initState() {
    super.initState();

    final SearchFilter searchFilter;
    final bool ownsSearchFilter;
    if (widget.externalSearchFilter != null) {
      searchFilter = widget.externalSearchFilter!;
      ownsSearchFilter = false;
    } else {
      searchFilter = SearchFilter(features: widget.searchFeatures);
      searchFilter.setup();
      ownsSearchFilter = true;
    }

    final TagFilterState tagFilterState;
    final bool ownsTagFilterState;
    if (widget.tagFilterState != null) {
      tagFilterState = widget.tagFilterState!;
      ownsTagFilterState = false;
    } else {
      tagFilterState = TagFilterState();
      ownsTagFilterState = true;
    }

    _notifier = FilterableItemDisplayNotifier(
      initialViewMode: widget.initialViewMode,
      initialSortMode: widget.initialSortMode,
      initialSelectedTypes: widget.initialSelectedTypes,
      initialDisplayMode: widget.displayMode,
      searchFilter: searchFilter,
      ownsSearchFilter: ownsSearchFilter,
      tagFilterState: tagFilterState,
      ownsTagFilterState: ownsTagFilterState,
    );

    unawaited(_notifier.loadDisplayMode(context: widget.displayModeContext));

    _disposeDeleteModeEffect = effect(() {
      final isDelete = _notifier.isDeleteMode.value;
      final count = _notifier.selectedItems.value.length;
      widget.onDeleteModeChanged?.call(
        isDeleteMode: isDelete,
        selectedCount: count,
      );
    });
  }

  @override
  void dispose() {
    _disposeDeleteModeEffect();
    _notifier.dispose();
    super.dispose();
  }

  void _handleDeletePressed() {
    final items = _notifier.selectedItems.value.values.toList();
    if (items.isEmpty) return;
    widget.onDeleteRequested?.call(items);
  }

  void _handleItemTap(FolderItem item) {
    if (_notifier.isDeleteMode.value) {
      _notifier.toggleItemSelection(item);
    } else {
      widget.onItemTap?.call(item);
    }
  }

  Future<void> _openTagFilterModal() async {
    final allTags = collectAllTags(widget.items);
    final result = await TagFilterModal.show(
      context: context,
      availableTags: allTags,
      initialIncludedTags: _notifier.tagFilterState.includedTagNames,
      initialExcludedTags: _notifier.tagFilterState.excludedTagNames,
    );
    if (result != null) {
      _notifier.tagFilterState.updateTags(
        included: result.included,
        excluded: result.excluded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (_notifier.isLoadingDisplayMode.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final itemCounts = getItemCounts(widget.items);

      return Column(
        children: [
          Watch((context) {
            final includedTags = _notifier.tagFilterState.includedTags.value;
            final excludedTags = _notifier.tagFilterState.excludedTags.value;
            final isDeleteMode = _notifier.isDeleteMode.value;
            final selectedCount = _notifier.selectedItems.value.length;

            return ItemToolbar(
              searchFilter: _notifier.searchFilter,
              selectedTypes: _notifier.selectedTypes.value,
              onFilterChanged: _notifier.setSelectedTypes,
              sortMode: _notifier.sortMode.value,
              onSortChanged: _notifier.setSortMode,
              viewMode: _notifier.viewMode.value,
              onViewModeChanged: _notifier.setViewMode,
              displayMode: _notifier.displayMode.value,
              onDisplayModeChanged: (mode) => _notifier.setDisplayMode(
                mode,
                context: widget.displayModeContext,
              ),
              showSearch: widget.showSearch,
              showTagFilterButton: widget.enableTagFiltering,
              includedTagNames: includedTags,
              excludedTagNames: excludedTags,
              onTagFilterPressed:
                  widget.enableTagFiltering ? _openTagFilterModal : null,
              onSearchSubmitted: widget.enableTagFiltering
                  ? _notifier.handleSearchSubmitted
                  : null,
              isDeleteMode: isDeleteMode,
              selectedCount: selectedCount,
              onDeleteModeToggled: widget.onDeleteRequested != null
                  ? _notifier.toggleDeleteMode
                  : null,
              onDeletePressed: _handleDeletePressed,
            );
          }),
          ItemStatsBar(
            linkCount: itemCounts[FolderItemType.link] ?? 0,
            documentCount: itemCounts[FolderItemType.document] ?? 0,
            folderCount: itemCounts[FolderItemType.folder] ?? 0,
            selectedTypes: _notifier.selectedTypes.value,
            onFilterChanged: _notifier.setSelectedTypes,
          ),
          Expanded(
            child: Watch((context) {
              final currentQuery =
                  _notifier.searchFilter.controller.query.value;
              final viewMode = _notifier.viewMode.value;
              final displayModeVal = _notifier.displayMode.value;
              final isDeleteMode = _notifier.isDeleteMode.value;
              final selectedItemIds =
                  _notifier.selectedItems.value.keys.toSet();
              final filtered = _notifier.getFilteredAndSortedItems(
                items: widget.items,
                query: currentQuery,
                enableTagFiltering: widget.enableTagFiltering,
              );

              return viewMode == ViewMode.grid
                  ? ItemGridView(
                      items: filtered,
                      displayMode: displayModeVal,
                      includedTagNames:
                          _notifier.tagFilterState.includedTagNames,
                      excludedTagNames:
                          _notifier.tagFilterState.excludedTagNames,
                      onItemTap: _handleItemTap,
                      aspectRatio: displayModeVal.aspectRatio,
                      maxCrossAxisExtent: displayModeVal.maxCrossAxisExtent,
                      isDeleteMode: isDeleteMode,
                      selectedItemIds: selectedItemIds,
                    )
                  : ItemListView(
                      items: filtered,
                      displayMode: displayModeVal,
                      includedTagNames:
                          _notifier.tagFilterState.includedTagNames,
                      excludedTagNames:
                          _notifier.tagFilterState.excludedTagNames,
                      onItemTap: _handleItemTap,
                      isDeleteMode: isDeleteMode,
                      selectedItemIds: selectedItemIds,
                    );
            }),
          ),
        ],
      );
    });
  }
}
