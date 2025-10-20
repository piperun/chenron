import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode_preference.dart";
import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/shared/item_display/item_stats_bar.dart";
import "package:chenron/shared/item_display/item_grid_view.dart";
import "package:chenron/shared/item_display/item_list_view.dart";
import "package:chenron/features/folder_viewer/ui/components/tag_filter_modal.dart";
import "package:chenron/database/database.dart" show Tag;
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/search/search_features.dart";
import "package:chenron/shared/tag_filter/tag_filter_state.dart";
import "package:chenron/shared/patterns/include_options.dart";
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

  // Deprecated: Use displayMode instead (kept for backwards compatibility)
  @Deprecated("Use displayMode.showImage instead")
  final bool? showImages;
  @Deprecated("Use displayMode.maxTags instead")
  final int? maxTags;

  final bool showTags;
  final bool showSearch;
  final bool enableTagFiltering;
  final void Function(FolderItem)? onItemTap;
  final void Function({required bool isDeleteMode, required int selectedCount})? onDeleteModeChanged;
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
    @Deprecated("Use displayMode.showImage instead") this.showImages,
    this.showTags = true,
    this.showSearch = true,
    this.enableTagFiltering = true,
    @Deprecated("Use displayMode.maxTags instead") this.maxTags,
    this.onItemTap,
    this.onDeleteModeChanged,
    this.onDeleteRequested,
  });

  @override
  State<FilterableItemDisplay> createState() => _FilterableItemDisplayState();
}

class _FilterableItemDisplayState extends State<FilterableItemDisplay> {
  late ViewMode _viewMode;
  late SortMode _sortMode;
  late Set<FolderItemType> _selectedTypes;
  late DisplayMode _displayMode;
  late final SearchFilter _searchFilter;
  late final bool _ownsSearchFilter;
  late final TagFilterState _tagFilterState;
  late final bool _ownsTagFilterState;
  bool _isLoadingDisplayMode = true;
  bool _isDeleteMode = false;
  final Map<String, FolderItem> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _viewMode = widget.initialViewMode;
    _sortMode = widget.initialSortMode;
    _selectedTypes = Set.of(widget.initialSelectedTypes);
    _displayMode = widget.displayMode; // Use provided default initially

    // Use external search filter if provided, otherwise create our own
    if (widget.externalSearchFilter != null) {
      _searchFilter = widget.externalSearchFilter!;
      _ownsSearchFilter = false;
    } else {
      _searchFilter = SearchFilter(features: widget.searchFeatures);
      _searchFilter.setup();
      _ownsSearchFilter = true;
    }

    // Use external tag filter state if provided, otherwise create our own
    if (widget.tagFilterState != null) {
      _tagFilterState = widget.tagFilterState!;
      _ownsTagFilterState = false;
    } else {
      _tagFilterState = TagFilterState();
      _ownsTagFilterState = true;
    }

    _loadDisplayMode();
  }

  Future<void> _loadDisplayMode() async {
    final savedMode = await DisplayModePreference.getDisplayMode(
      context: widget.displayModeContext,
    );
    if (mounted) {
      setState(() {
        _displayMode = savedMode;
        _isLoadingDisplayMode = false;
      });
    }
  }

  @override
  void dispose() {
    // Only dispose filter if we own it
    if (_ownsSearchFilter) {
      _searchFilter.dispose();
    }
    // Only dispose tag state if we own it
    if (_ownsTagFilterState) {
      _tagFilterState.dispose();
    }
    super.dispose();
  }

  void _onViewModeChanged(ViewMode mode) => setState(() => _viewMode = mode);
  void _onSortChanged(SortMode mode) => setState(() => _sortMode = mode);
  void _onFilterChanged(Set<FolderItemType> types) =>
      setState(() => _selectedTypes = types);

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      if (!_isDeleteMode) {
        // Clear selections when exiting delete mode
        _selectedItems.clear();
      }
    });
    widget.onDeleteModeChanged?.call(
      isDeleteMode: _isDeleteMode,
      selectedCount: _selectedItems.length,
    );
  }

  void _toggleItemSelection(FolderItem item) {
    if (!_isDeleteMode || item.id == null) return;
    
    setState(() {
      if (_selectedItems.containsKey(item.id)) {
        _selectedItems.remove(item.id);
      } else {
        _selectedItems[item.id!] = item;
      }
    });
    widget.onDeleteModeChanged?.call(
      isDeleteMode: _isDeleteMode,
      selectedCount: _selectedItems.length,
    );
  }

  void _handleDeletePressed() {
    if (_selectedItems.isEmpty) return;
    widget.onDeleteRequested?.call(_selectedItems.values.toList());
  }

  void _handleItemTap(FolderItem item) {
    if (_isDeleteMode) {
      _toggleItemSelection(item);
    } else {
      widget.onItemTap?.call(item);
    }
  }

  Future<void> _onDisplayModeChanged(DisplayMode mode) async {
    setState(() => _displayMode = mode);
    await DisplayModePreference.setDisplayMode(
      mode,
      context: widget.displayModeContext,
    );
  }

  Future<void> _openTagFilterModal() async {
    final allTags = _collectAllTags(widget.items);
    final result = await TagFilterModal.show(
      context: context,
      availableTags: allTags,
      initialIncludedTags: _tagFilterState.includedTagNames,
      initialExcludedTags: _tagFilterState.excludedTagNames,
    );
    if (result != null) {
      _tagFilterState.updateTags(
        included: result.included,
        excluded: result.excluded,
      );
    }
  }

  void _handleSearchSubmitted(String query) {
    // Parse and add tags from query to state, get clean query back
    final cleanQuery = _tagFilterState.parseAndAddFromQuery(query);

    // Update the search query to remove tag patterns
    _searchFilter.controller.value = cleanQuery;
  }

  List<FolderItem> _getFilteredAndSortedItems(String query) {
    // Use SearchFilter for all filtering and sorting logic
    return _searchFilter.filterAndSort(
      items: widget.items,
      query: query,
      types: _selectedTypes,
      includedTags:
          widget.enableTagFiltering ? _tagFilterState.includedTagNames : null,
      excludedTags:
          widget.enableTagFiltering ? _tagFilterState.excludedTagNames : null,
      sortMode: _sortMode,
    );
  }

  Map<FolderItemType, int> _getItemCounts(List<FolderItem> items) {
    final counts = <FolderItemType, int>{
      FolderItemType.link: 0,
      FolderItemType.document: 0,
      FolderItemType.folder: 0,
    };
    for (final item in items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }
    return counts;
  }

  List<Tag> _collectAllTags(List<FolderItem> items) {
    final byId = <String, Tag>{};
    for (final item in items) {
      for (final tag in item.tags) {
        byId[tag.id] = tag;
      }
    }
    final result = byId.values.toList();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while loading display mode preference
    if (_isLoadingDisplayMode) {
      return const Center(child: CircularProgressIndicator());
    }

    final counts = _getItemCounts(widget.items);

    return Column(
      children: [
        Watch((context) {
          // Rebuild when tag state changes
          final includedTags = _tagFilterState.includedTags.value;
          final excludedTags = _tagFilterState.excludedTags.value;

          return ItemToolbar(
            searchFilter: _searchFilter,
            selectedTypes: _selectedTypes,
            onFilterChanged: _onFilterChanged,
            sortMode: _sortMode,
            onSortChanged: _onSortChanged,
            viewMode: _viewMode,
            onViewModeChanged: _onViewModeChanged,
            displayMode: _displayMode,
            onDisplayModeChanged: _onDisplayModeChanged,
            showSearch: widget.showSearch,
            showTagFilterButton: widget.enableTagFiltering,
            includedTagNames: includedTags,
            excludedTagNames: excludedTags,
            onTagFilterPressed:
                widget.enableTagFiltering ? _openTagFilterModal : null,
            onSearchSubmitted:
                widget.enableTagFiltering ? _handleSearchSubmitted : null,
            isDeleteMode: _isDeleteMode,
            selectedCount: _selectedItems.length,
            onDeleteModeToggled: widget.onDeleteRequested != null ? _toggleDeleteMode : null,
            onDeletePressed: _handleDeletePressed,
          );
        }),
        ItemStatsBar(
          linkCount: counts[FolderItemType.link] ?? 0,
          documentCount: counts[FolderItemType.document] ?? 0,
          folderCount: counts[FolderItemType.folder] ?? 0,
          selectedTypes: _selectedTypes,
          onFilterChanged: _onFilterChanged,
        ),
        Expanded(
          child: Watch((context) {
            // Trigger rebuild when search query changes
            final currentQuery = _searchFilter.controller.query.value;
            final filtered = _getFilteredAndSortedItems(currentQuery);

            return _viewMode == ViewMode.grid
                ? ItemGridView(
                    items: filtered,
                    displayMode: _displayMode,
                    showImages: widget.showImages,
                    maxTags: widget.maxTags,
                    includedTagNames: _tagFilterState.includedTagNames,
                    excludedTagNames: _tagFilterState.excludedTagNames,
                    onItemTap: _handleItemTap,
                    aspectRatio: _displayMode.aspectRatio,
                    maxCrossAxisExtent: _displayMode.maxCrossAxisExtent,
                    isDeleteMode: _isDeleteMode,
                    selectedItemIds: _selectedItems.keys.toSet(),
                  )
                : ItemListView(
                    items: filtered,
                    displayMode: _displayMode,
                    showImages: widget.showImages,
                    maxTags: widget.maxTags,
                    includedTagNames: _tagFilterState.includedTagNames,
                    excludedTagNames: _tagFilterState.excludedTagNames,
                    onItemTap: _handleItemTap,
                    isDeleteMode: _isDeleteMode,
                    selectedItemIds: _selectedItems.keys.toSet(),
                  );
          }),
        ),
      ],
    );
  }
}
