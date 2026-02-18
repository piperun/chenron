import "package:flutter/material.dart";
import "package:database/models/item.dart";

class FilterDropdown extends StatelessWidget {
  final Set<FolderItemType> selectedTypes;
  final ValueChanged<Set<FolderItemType>> onFilterChanged;

  const FilterDropdown({
    super.key,
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
            foregroundColor: theme.colorScheme.onSurfaceVariant,
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
