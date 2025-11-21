import "package:flutter/material.dart";
import "package:chenron/models/db_result.dart";

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
                style: const TextStyle(color: Colors.grey),
              )
            : const Icon(Icons.folder_outlined, color: Colors.grey),
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
                color: Colors.blue,
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
              // Item count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${folder.items.length}",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
