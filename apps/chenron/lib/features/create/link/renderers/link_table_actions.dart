import "package:flutter/material.dart";

/// Action buttons for link table (Delete Selected, Clear All)
class LinkTableActions extends StatelessWidget {
  final bool hasSelectedRows;
  final bool hasEntries;
  final VoidCallback onDeleteSelected;
  final VoidCallback onClearAll;

  const LinkTableActions({
    super.key,
    required this.hasSelectedRows,
    required this.hasEntries,
    required this.onDeleteSelected,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          key: const Key('delete_selected_button'),
          onPressed: hasSelectedRows ? onDeleteSelected : null,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text("Delete Selected"),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          key: const Key('clear_all_button'),
          onPressed: hasEntries ? onClearAll : null,
          icon: const Icon(Icons.clear_all, size: 18),
          label: const Text("Clear All"),
        ),
      ],
    );
  }
}
