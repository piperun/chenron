import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode_switcher.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/search/local_searchbar.dart";

// Re-export SortMode from SearchFilter for convenience
export "package:chenron/shared/search/search_filter.dart" show SortMode;

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
  final int selectedCount;
  final VoidCallback? onDeleteModeToggled;
  final VoidCallback? onDeletePressed;

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
    this.selectedCount = 0,
    this.onDeleteModeToggled,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
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
              _FilterDropdown(
                selectedTypes: selectedTypes,
                onFilterChanged: onFilterChanged,
              ),

              const SizedBox(width: 8),

              // Sort button
              Builder(
                builder: (context) => _ToolbarButton(
                  label: _getSortLabel(),
                  icon: Icons.sort,
                  onPressed: () => _showSortMenu(context),
                ),
              ),

              if (showTagFilterButton) ...[
                const SizedBox(width: 8),
                _TagFilterButton(
                  includedCount: includedTagNames.length,
                  excludedCount: excludedTagNames.length,
                  onPressed: onTagFilterPressed,
                ),
              ],

              // Delete mode button
              if (onDeleteModeToggled != null) ...[
                const SizedBox(width: 8),
                _DeleteModeButton(
                  isDeleteMode: isDeleteMode,
                  selectedCount: selectedCount,
                  onToggle: onDeleteModeToggled,
                  onDelete: onDeletePressed,
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
                    _ViewToggleButton(
                      icon: Icons.grid_view,
                      label: "Grid",
                      isSelected: viewMode == ViewMode.grid,
                      onPressed: () => onViewModeChanged(ViewMode.grid),
                    ),
                    const SizedBox(width: 4),
                    _ViewToggleButton(
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

    showMenu<SortMode>(
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
    });
  }
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: theme.dividerColor),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final Set<FolderItemType> selectedTypes;
  final ValueChanged<Set<FolderItemType>> onFilterChanged;

  const _FilterDropdown({
    required this.selectedTypes,
    required this.onFilterChanged,
  });

  String _getLabel() {
    if (selectedTypes.length == 3) {
      return "All Types";
    } else if (selectedTypes.length == 1) {
      final type = selectedTypes.first;
      switch (type) {
        case FolderItemType.link:
          return "Links";
        case FolderItemType.document:
          return "Documents";
        case FolderItemType.folder:
          return "Folders";
      }
    } else {
      return "${selectedTypes.length} Types";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MenuAnchor(
      builder: (context, controller, child) {
        return OutlinedButton.icon(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.filter_alt, size: 16),
          label: Text(_getLabel()),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: theme.dividerColor),
          ),
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: null,
          child: _FilterCheckbox(
            label: "Links",
            isSelected: selectedTypes.contains(FolderItemType.link),
            onChanged: (value) {
              final newTypes = Set<FolderItemType>.from(selectedTypes);
              if (value) {
                newTypes.add(FolderItemType.link);
              } else {
                newTypes.remove(FolderItemType.link);
              }
              if (newTypes.isNotEmpty) {
                onFilterChanged(newTypes);
              }
            },
          ),
        ),
        MenuItemButton(
          onPressed: null,
          child: _FilterCheckbox(
            label: "Documents",
            isSelected: selectedTypes.contains(FolderItemType.document),
            onChanged: (value) {
              final newTypes = Set<FolderItemType>.from(selectedTypes);
              if (value) {
                newTypes.add(FolderItemType.document);
              } else {
                newTypes.remove(FolderItemType.document);
              }
              if (newTypes.isNotEmpty) {
                onFilterChanged(newTypes);
              }
            },
          ),
        ),
        MenuItemButton(
          onPressed: null,
          child: _FilterCheckbox(
            label: "Folders",
            isSelected: selectedTypes.contains(FolderItemType.folder),
            onChanged: (value) {
              final newTypes = Set<FolderItemType>.from(selectedTypes);
              if (value) {
                newTypes.add(FolderItemType.folder);
              } else {
                newTypes.remove(FolderItemType.folder);
              }
              if (newTypes.isNotEmpty) {
                onFilterChanged(newTypes);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _FilterCheckbox extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _FilterCheckbox({
    required this.label,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) => onChanged(value ?? false),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _TagFilterButton extends StatelessWidget {
  final int includedCount;
  final int excludedCount;
  final VoidCallback? onPressed;

  const _TagFilterButton({
    required this.includedCount,
    required this.excludedCount,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = includedCount > 0 || excludedCount > 0;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color: hasFilters ? theme.colorScheme.primary : theme.dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 16,
            color: hasFilters ? theme.colorScheme.primary : null,
          ),
          const SizedBox(width: 8),
          Text(
            "Tags",
            style: TextStyle(
              color: hasFilters ? theme.colorScheme.primary : null,
            ),
          ),
          if (includedCount > 0 || excludedCount > 0) ...[
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (includedCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "+$includedCount",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (includedCount > 0 && excludedCount > 0)
                  const SizedBox(width: 4),
                if (excludedCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "-$excludedCount",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DeleteModeButton extends StatelessWidget {
  final bool isDeleteMode;
  final int selectedCount;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const _DeleteModeButton({
    required this.isDeleteMode,
    required this.selectedCount,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!isDeleteMode) {
      // Normal mode: Show "Select" button
      return OutlinedButton.icon(
        onPressed: onToggle,
        icon: const Icon(Icons.check_box_outlined, size: 16),
        label: const Text("Select"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(color: theme.dividerColor),
        ),
      );
    }

    // Delete mode: Show delete button with count
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cancel button
        OutlinedButton.icon(
          onPressed: onToggle,
          icon: const Icon(Icons.close, size: 16),
          label: const Text("Cancel"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: theme.dividerColor),
          ),
        ),
        const SizedBox(width: 8),
        // Delete button
        FilledButton.icon(
          onPressed: selectedCount > 0 ? onDelete : null,
          icon: const Icon(Icons.delete, size: 16),
          label: Text("Delete selected ($selectedCount)"),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            disabledBackgroundColor: colorScheme.surfaceContainerHighest,
            disabledForegroundColor: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ViewToggleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
