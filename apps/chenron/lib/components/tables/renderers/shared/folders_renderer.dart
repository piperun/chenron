import "package:flutter/material.dart";

/// Shared renderer for displaying folders in tables
///
/// Used by both link and document tables to display folder assignments consistently.
class FoldersRenderer {
  static Widget build({
    required List<String> folderIds,
    required Map<String, String> folderNames,
    required ThemeData theme,
  }) {
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

