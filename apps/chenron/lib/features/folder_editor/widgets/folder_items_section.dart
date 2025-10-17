import "package:flutter/material.dart";
import "package:chenron/models/item.dart";
import "package:chenron/shared/item_editor/item_editor.dart";
import "package:chenron/models/cud.dart";

class FolderItemsSection extends StatelessWidget {
  final Set<FolderItem> items;
  final ValueChanged<CUD<FolderItem>> onItemsUpdated;
  final VoidCallback onAddLink;
  final VoidCallback onAddDocument;

  const FolderItemsSection({
    super.key,
    required this.items,
    required this.onItemsUpdated,
    required this.onAddLink,
    required this.onAddDocument,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Folder Items",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: onAddLink,
                  tooltip: "Add Link",
                ),
                IconButton(
                  icon: const Icon(Icons.note_add),
                  onPressed: onAddDocument,
                  tooltip: "Add Document",
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Manage items in this folder",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ItemEditor(
              initialItems: items.toList(),
              onUpdate: onItemsUpdated,
            ),
          ],
        ),
      ),
    );
  }
}
