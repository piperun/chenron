import "package:flutter/material.dart";
import "package:chenron/models/item.dart";

class ItemStatsBar extends StatelessWidget {
  final int linkCount;
  final int documentCount;
  final int folderCount;
  final Set<FolderItemType> selectedTypes;
  final ValueChanged<Set<FolderItemType>> onFilterChanged;

  const ItemStatsBar({
    super.key,
    required this.linkCount,
    required this.documentCount,
    required this.folderCount,
    required this.selectedTypes,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xFFFAFAFA)
            : theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.link,
            label: "Links",
            count: linkCount,
            color: Colors.blue,
            isActive: selectedTypes.contains(FolderItemType.link),
            onTap: () {
              final newTypes = Set<FolderItemType>.from(selectedTypes);
              if (newTypes.contains(FolderItemType.link)) {
                newTypes.remove(FolderItemType.link);
              } else {
                newTypes.add(FolderItemType.link);
              }
              if (newTypes.isNotEmpty) {
                onFilterChanged(newTypes);
              }
            },
          ),
          const SizedBox(width: 24),
          _StatItem(
            icon: Icons.description,
            label: "Documents",
            count: documentCount,
            color: Colors.purple,
            isActive: selectedTypes.contains(FolderItemType.document),
            onTap: () {
              final newTypes = Set<FolderItemType>.from(selectedTypes);
              if (newTypes.contains(FolderItemType.document)) {
                newTypes.remove(FolderItemType.document);
              } else {
                newTypes.add(FolderItemType.document);
              }
              if (newTypes.isNotEmpty) {
                onFilterChanged(newTypes);
              }
            },
          ),
          const SizedBox(width: 24),
          _StatItem(
            icon: Icons.folder,
            label: "Folders",
            count: folderCount,
            color: Colors.orange,
            isActive: selectedTypes.contains(FolderItemType.folder),
            onTap: () {
              final newTypes = Set<FolderItemType>.from(selectedTypes);
              if (newTypes.contains(FolderItemType.folder)) {
                newTypes.remove(FolderItemType.folder);
              } else {
                newTypes.add(FolderItemType.folder);
              }
              if (newTypes.isNotEmpty) {
                onFilterChanged(newTypes);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? color : color.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              "$count",
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
                color: isActive
                    ? theme.textTheme.bodyLarge?.color
                    : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? theme.textTheme.bodyMedium?.color
                    : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
