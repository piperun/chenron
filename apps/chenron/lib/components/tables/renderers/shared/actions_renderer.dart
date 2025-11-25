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

/// Shared renderer for displaying action buttons in tables
///
/// Used by both link and document tables to display edit/delete actions
/// and optionally type-specific custom actions.
class ActionsRenderer<T> {
  static Widget build<T>({
    required T item,
    required Key itemKey,
    required ThemeData theme,
    ValueChanged<Key>? onEdit,
    ValueChanged<Key>? onDelete,
    List<ActionButton<T>>? customActions,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => onEdit(itemKey),
            tooltip: "Edit",
          ),
        if (onDelete != null)
          IconButton(
            icon: Icon(
              Icons.delete,
              size: 18,
              color: theme.colorScheme.error,
            ),
            onPressed: () => onDelete(itemKey),
            tooltip: "Delete",
          ),
        if (customActions != null)
          ...customActions.map((action) => IconButton(
            icon: Icon(action.icon, size: 18, color: action.color),
            onPressed: () => action.onPressed(item),
            tooltip: action.tooltip,
          )),
      ],
    );
  }
}

