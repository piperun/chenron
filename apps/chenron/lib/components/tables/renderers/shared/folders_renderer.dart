import "package:flutter/material.dart";

/// Shared table cell that displays folder assignments.
///
/// Used by both link and document tables to render folders consistently.
class TableFoldersCell extends StatelessWidget {
  final List<String> folderIds;
  final Map<String, String> folderNames;
  final ThemeData theme;

  const TableFoldersCell({
    super.key,
    required this.folderIds,
    required this.folderNames,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (folderIds.isEmpty) {
      return const Text("default", style: TextStyle(fontSize: 12));
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: folderIds.map((folderId) {
        final folderName = folderNames[folderId] ?? folderId;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            folderName,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }
}
