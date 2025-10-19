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

class FilterableItemDisplay extends StatefulWidget {
  final List<FolderItem> items;
  final ViewMode initialViewMode;
  final SortMode initialSortMode;
  final Set<FolderItemType> initialSelectedTypes;
  final DisplayMode displayMode;

  // Deprecated: Use displayMode instead (kept for backwards compatibility)
  @Deprecated('Use displayMode.showImage instead')
  final bool? showImages;
  @Deprecated('Use displayMode.maxTags instead')
  final int? maxTags;

  final bool showTags;
  final bool enableTagFiltering;
  final void Function(FolderItem)? onItemTap;

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
    @Deprecated('Use displayMode.showImage instead') this.showImages,
    this.showTags = true,
    this.enableTagFiltering = true,
    @Deprecated('Use displayMode.maxTags instead') this.maxTags,
    this.onItemTap,
  });

  @override
  State<FilterableItemDisplay> createState() => _FilterableItemDisplayState();
}

class _FilterableItemDisplayState extends State<FilterableItemDisplay> {
  late ViewMode _viewMode;
  late SortMode _sortMode;
  late Set<FolderItemType> _selectedTypes;
  late DisplayMode _displayMode;
  String _searchQuery = "";
  Set<String> _includedTagNames = {};
  Set<String> _excludedTagNames = {};
  bool _isLoadingDisplayMode = true;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.initialViewMode;
    _sortMode = widget.initialSortMode;
    _selectedTypes = Set.of(widget.initialSelectedTypes);
    _displayMode = widget.displayMode; // Use provided default initially
    _loadDisplayMode();
  }

  Future<void> _loadDisplayMode() async {
    final savedMode = await DisplayModePreference.getDisplayMode();
    if (mounted) {
      setState(() {
        _displayMode = savedMode;
        _isLoadingDisplayMode = false;
      });
    }
  }

  void _onSearchChanged(String query) => setState(() => _searchQuery = query);
  void _onViewModeChanged(ViewMode mode) => setState(() => _viewMode = mode);
  void _onSortChanged(SortMode mode) => setState(() => _sortMode = mode);
  void _onFilterChanged(Set<FolderItemType> types) =>
      setState(() => _selectedTypes = types);

  Future<void> _onDisplayModeChanged(DisplayMode mode) async {
    setState(() => _displayMode = mode);
    await DisplayModePreference.setDisplayMode(mode);
  }

  Future<void> _openTagFilterModal() async {
    final allTags = _collectAllTags(widget.items);
    final result = await TagFilterModal.show(
      context: context,
      availableTags: allTags,
      initialIncludedTags: _includedTagNames,
      initialExcludedTags: _excludedTagNames,
    );
    if (result != null) {
      setState(() {
        _includedTagNames = result.included;
        _excludedTagNames = result.excluded;
      });
    }
  }

  List<FolderItem> _getFilteredAndSortedItems() {
    var itemsList = List<FolderItem>.from(widget.items);

    // Type filter
    itemsList =
        itemsList.where((item) => _selectedTypes.contains(item.type)).toList();

    // Tag filters
    if (widget.enableTagFiltering) {
      if (_includedTagNames.isNotEmpty) {
        itemsList = itemsList.where((item) {
          final names = item.tags.map((t) => t.name).toSet();
          return names.any(_includedTagNames.contains);
        }).toList();
      }
      if (_excludedTagNames.isNotEmpty) {
        itemsList = itemsList.where((item) {
          final names = item.tags.map((t) => t.name).toSet();
          return !names.any(_excludedTagNames.contains);
        }).toList();
      }
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      itemsList = itemsList.where((item) {
        if (item.path is StringContent) {
          final pathStr = (item.path as StringContent).value.toLowerCase();
          if (pathStr.contains(q)) return true;
        }
        if (item.tags.any((t) => t.name.toLowerCase().contains(q))) return true;
        return false;
      }).toList();
    }

    // Sort
    itemsList.sort((a, b) {
      switch (_sortMode) {
        case SortMode.nameAsc:
          return _getItemName(a).compareTo(_getItemName(b));
        case SortMode.nameDesc:
          return _getItemName(b).compareTo(_getItemName(a));
        case SortMode.dateAsc:
          return 0;
        case SortMode.dateDesc:
          return 0;
      }
    });

    return itemsList;
  }

  String _getItemName(FolderItem item) {
    if (item.path is StringContent) return (item.path as StringContent).value;
    return "";
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
    print(
        'COLLECT TAGS DEBUG: ${items.length} items, ${result.length} unique tags');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while loading display mode preference
    if (_isLoadingDisplayMode) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _getFilteredAndSortedItems();
    final counts = _getItemCounts(widget.items);

    return Column(
      children: [
        ItemToolbar(
          searchQuery: _searchQuery,
          onSearchChanged: _onSearchChanged,
          selectedTypes: _selectedTypes,
          onFilterChanged: _onFilterChanged,
          sortMode: _sortMode,
          onSortChanged: _onSortChanged,
          viewMode: _viewMode,
          onViewModeChanged: _onViewModeChanged,
          displayMode: _displayMode,
          onDisplayModeChanged: _onDisplayModeChanged,
          showSearch: true,
          showTagFilterButton: widget.enableTagFiltering,
          includedTagNames: _includedTagNames,
          excludedTagNames: _excludedTagNames,
          onTagFilterPressed:
              widget.enableTagFiltering ? _openTagFilterModal : null,
        ),
        ItemStatsBar(
          linkCount: counts[FolderItemType.link] ?? 0,
          documentCount: counts[FolderItemType.document] ?? 0,
          folderCount: counts[FolderItemType.folder] ?? 0,
          selectedTypes: _selectedTypes,
          onFilterChanged: _onFilterChanged,
        ),
        Expanded(
          child: _viewMode == ViewMode.grid
              ? ItemGridView(
                  items: filtered,
                  displayMode: _displayMode,
                  showImages: widget.showImages,
                  maxTags: widget.maxTags,
                  includedTagNames: _includedTagNames,
                  excludedTagNames: _excludedTagNames,
                  onItemTap: widget.onItemTap,
                  aspectRatio: _displayMode.aspectRatio,
                  maxCrossAxisExtent: _displayMode.maxCrossAxisExtent,
                )
              : ItemListView(
                  items: filtered,
                  displayMode: _displayMode,
                  showImages: widget.showImages,
                  maxTags: widget.maxTags,
                  includedTagNames: _includedTagNames,
                  excludedTagNames: _excludedTagNames,
                  onItemTap: widget.onItemTap,
                ),
        ),
      ],
    );
  }
}
