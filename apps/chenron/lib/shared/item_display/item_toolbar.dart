import "package:flutter/material.dart";
import "package:chenron/models/item.dart";

enum ViewMode { grid, list }

enum SortMode {
  nameAsc,
  nameDesc,
  dateAsc,
  dateDesc,
}

class ItemToolbar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final Set<FolderItemType> selectedTypes;
  final ValueChanged<Set<FolderItemType>> onFilterChanged;
  final SortMode sortMode;
  final ValueChanged<SortMode> onSortChanged;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final bool showSearch;

  const ItemToolbar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedTypes,
    required this.onFilterChanged,
    required this.sortMode,
    required this.onSortChanged,
    required this.viewMode,
    required this.onViewModeChanged,
    this.showSearch = true,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate 50% width for search bar, minimum 300px
          final searchWidth =
              (constraints.maxWidth * 0.5).clamp(300.0, double.infinity);

          return Row(
            children: [
              // Search box - 50% width
              if (showSearch)
                SizedBox(
                  width: searchWidth,
                  child: TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search by name, URL, tags...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: theme.colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
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

              const Spacer(),

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
          );
        },
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
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
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
