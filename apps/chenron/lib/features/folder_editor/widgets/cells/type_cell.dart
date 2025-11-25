import "package:flutter/material.dart";
import "package:chenron/features/folder_editor/models/item_kind.dart";

class TypeCell extends StatelessWidget {
  final String type;

  const TypeCell({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kind = type.toItemKind();
    final color = kind.colorOf(theme);

    return TypeIcon(
      icon: kind.icon,
      color: color,
      label: kind.label ?? type,
    );
  }
}

class TypeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const TypeIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

