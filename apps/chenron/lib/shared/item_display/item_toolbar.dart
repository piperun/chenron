import "dart:async";
import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode_switcher.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/search/local_searchbar.dart";
import "package:chenron/shared/item_display/widgets/toolbar/toolbar_button.dart";
import "package:chenron/shared/item_display/widgets/toolbar/filter_dropdown.dart";
import "package:chenron/shared/item_display/widgets/toolbar/tag_filter_button.dart";
import "package:chenron/shared/item_display/widgets/toolbar/toolbar_actions.dart";

// Re-export SortMode from SearchFilter for convenience
export "package:chenron/shared/search/search_filter.dart";

enum ViewMode { grid, list }

class ItemToolbar extends StatelessWidget {
  final SearchFilter searchFilter;
  final Set<FolderItemType> selectedTypes;
  final ValueChanged<Set<FolderItemType>> onFilterChanged;
  final SortMode sortMode;
  final ValueChanged<SortMode> onSortChanged;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final DisplayMode displayMode;
  final ValueChanged<DisplayMode> onDisplayModeChanged;
  final bool showSearch;
  final bool showTagFilterButton;
  final Set<String> includedTagNames;
  final Set<String> excludedTagNames;
  final VoidCallback? onTagFilterPressed;
  final void Function(String)? onSearchSubmitted;
  final bool isDeleteMode;
  final VoidCallback? onDeleteModeToggled;

  const ItemToolbar({
    super.key,
    required this.searchFilter,
    required this.selectedTypes,
    required this.onFilterChanged,
    required this.sortMode,
    required this.onSortChanged,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.displayMode,
    required this.onDisplayModeChanged,
    this.showSearch = true,
    this.showTagFilterButton = true,
    this.includedTagNames = const {},
    this.excludedTagNames = const {},
    this.onTagFilterPressed,
    this.onSearchSubmitted,
    this.isDeleteMode = false,
    this.onDeleteModeToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Search box
          if (showSearch)
            LocalSearchBar(
              filter: searchFilter,
              hintText: "Search by name, URL, tags...",
              onSubmitted: onSearchSubmitted,
            ),

          if (showSearch) const SizedBox(width: 12),

          // Filter dropdown with checkboxes
          FilterDropdown(
            selectedTypes: selectedTypes,
            onFilterChanged: onFilterChanged,
          ),

          const SizedBox(width: 8),

          // Sort button
          Builder(
            builder: (context) => ToolbarButton(
              label: _getSortLabel(),
              icon: Icons.sort,
              onPressed: () => _showSortMenu(context),
            ),
          ),

          if (showTagFilterButton) ...[
            const SizedBox(width: 8),
            TagFilterButton(
              includedCount: includedTagNames.length,
              excludedCount: excludedTagNames.length,
              onPressed: onTagFilterPressed,
            ),
          ],

          // Delete mode button
          if (onDeleteModeToggled != null) ...[
            const SizedBox(width: 8),
            DeleteModeButton(
              isDeleteMode: isDeleteMode,
              onToggle: onDeleteModeToggled,
            ),
          ],

          const SizedBox(width: 8),
          const Spacer(),

          // Display mode switcher
          DisplayModeSwitcher(
            selectedMode: displayMode,
            onModeChanged: onDisplayModeChanged,
          ),

          const SizedBox(width: 8),

          // View toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ViewToggleButton(
                  icon: Icons.grid_view,
                  label: "Grid",
                  isSelected: viewMode == ViewMode.grid,
                  onPressed: () => onViewModeChanged(ViewMode.grid),
                ),
                const SizedBox(width: 4),
                ViewToggleButton(
                  icon: Icons.list,
                  label: "List",
                  isSelected: viewMode == ViewMode.list,
                  onPressed: () => onViewModeChanged(ViewMode.list),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (sortMode) {
      case SortMode.nameAsc:
        return "Sort: A-Z";
      case SortMode.nameDesc:
        return "Sort: Z-A";
      case SortMode.dateAsc:
        return "Sort: Oldest";
      case SortMode.dateDesc:
        return "Sort: Newest";
    }
  }

  void _showSortMenu(BuildContext context) {
    final button = context.findRenderObject() as RenderBox?;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;
    final Offset buttonPosition =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy + button.size.height,
      overlay.size.width - buttonPosition.dx - 200,
      0,
    );

    unawaited(showMenu<SortMode>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(
          value: SortMode.nameAsc,
          child: Text("Name: A-Z"),
        ),
        const PopupMenuItem(
          value: SortMode.nameDesc,
          child: Text("Name: Z-A"),
        ),
        const PopupMenuItem(
          value: SortMode.dateAsc,
          child: Text("Date: Oldest First"),
        ),
        const PopupMenuItem(
          value: SortMode.dateDesc,
          child: Text("Date: Newest First"),
        ),
      ],
    ).then((value) {
      if (value != null) {
        onSortChanged(value);
      }
    }));
  }
}
