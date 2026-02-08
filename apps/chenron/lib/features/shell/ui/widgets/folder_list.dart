import "package:flutter/material.dart";
import "package:database/models/db_result.dart";
import "package:database/models/item.dart";

class FolderList extends StatelessWidget {
  final bool isLoading;
  final List<FolderResult> folders;
  final String filterTerm;
  final bool isExtended;
  final String? selectedFolderId;
  final ValueChanged<String> onFolderSelected;

  const FolderList({
    super.key,
    required this.isLoading,
    required this.folders,
    required this.filterTerm,
    required this.isExtended,
    required this.selectedFolderId,
    required this.onFolderSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Filter folders based on search term
    final filteredFolders = filterTerm.isEmpty
        ? folders
        : folders
            .where((folder) => folder.data.title
                .toLowerCase()
                .contains(filterTerm.toLowerCase()))
            .toList();

    if (filteredFolders.isEmpty) {
      return Center(
        child: isExtended
            ? Text(
                filterTerm.isEmpty
                    ? "No folders yet.\nCreate one to get started."
                    : "No folders match '$filterTerm'",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              )
            : Icon(Icons.folder_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      itemCount: filteredFolders.length,
      itemBuilder: (context, index) {
        final folder = filteredFolders[index];
        return _FolderRow(
          folder: folder,
          isExtended: isExtended,
          isSelected: folder.data.id == selectedFolderId,
          onTap: () => onFolderSelected(folder.data.id),
        );
      },
    );
  }
}

class _FolderRow extends StatelessWidget {
  final FolderResult folder;
  final bool isExtended;
  final bool isSelected;
  final VoidCallback onTap;

  const _FolderRow({
    required this.folder,
    required this.isExtended,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Folder indicator dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            if (isExtended) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  folder.data.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              // Item count badges by type
              ..._buildItemBadges(context),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItemBadges(BuildContext context) {
    final counts = <FolderItemType, int>{};
    for (final item in folder.items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final badgeConfig = {
      FolderItemType.link: (icon: Icons.link, color: colorScheme.primary),
      FolderItemType.document: (icon: Icons.description, color: colorScheme.tertiary),
      FolderItemType.folder: (icon: Icons.folder, color: colorScheme.secondary),
    };

    return [
      for (final type in FolderItemType.values)
        if ((counts[type] ?? 0) > 0)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: badgeConfig[type]!.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    badgeConfig[type]!.icon,
                    size: 11,
                    color: badgeConfig[type]!.color,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    "${counts[type]}",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeConfig[type]!.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
    ];
  }
}

