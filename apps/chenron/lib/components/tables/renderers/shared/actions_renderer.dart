import "package:flutter/material.dart";

/// Configuration for a custom action button
class ActionButton<T> {
  final IconData icon;
  final String tooltip;
  final void Function(T item) onPressed;
  final Color? color;

  ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });
}

/// Shared table cell that displays action buttons.
///
/// Used by both link and document tables to render edit/delete actions
/// and optionally type-specific custom actions.
class TableActionsCell<T> extends StatelessWidget {
  final T item;
  final Key itemKey;
  final ThemeData theme;
  final ValueChanged<Key>? onEdit;
  final ValueChanged<Key>? onDelete;
  final List<ActionButton<T>>? customActions;

  const TableActionsCell({
    super.key,
    required this.item,
    required this.itemKey,
    required this.theme,
    this.onEdit,
    this.onDelete,
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => onEdit!(itemKey),
            tooltip: "Edit",
          ),
        if (onDelete != null)
          IconButton(
            icon: Icon(
              Icons.delete,
              size: 18,
              color: theme.colorScheme.error,
            ),
            onPressed: () => onDelete!(itemKey),
            tooltip: "Delete",
          ),
        if (customActions != null)
          ...customActions!.map((action) => IconButton(
                icon: Icon(action.icon, size: 18, color: action.color),
                onPressed: () => action.onPressed(item),
                tooltip: action.tooltip,
              )),
      ],
    );
  }
}
