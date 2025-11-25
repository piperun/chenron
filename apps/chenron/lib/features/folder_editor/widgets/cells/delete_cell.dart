import "package:flutter/material.dart";

class DeleteCell extends StatelessWidget {
  final String itemId;
  final void Function(String itemId) onDelete;

  const DeleteCell({
    super.key,
    required this.itemId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
      onPressed: () => onDelete(itemId),
      tooltip: "Delete",
    );
  }
}

