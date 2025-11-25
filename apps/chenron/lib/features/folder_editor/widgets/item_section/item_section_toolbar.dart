import "package:flutter/material.dart";

class ItemSectionToolbar extends StatelessWidget {
  final List items;
  final bool hasSelectedRows;
  final VoidCallback onAddLink;
  final VoidCallback onAddDocument;
  final VoidCallback onDeleteSelected;
  const ItemSectionToolbar({
    super.key,
    required this.items,
    required this.hasSelectedRows,
    required this.onAddLink,
    required this.onAddDocument,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          "Folder Items (${items.length})",
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
        TextButton.icon(
          onPressed: hasSelectedRows ? onDeleteSelected : null,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text("Delete Selected"),
        ),
      ],
    );
  }
}

