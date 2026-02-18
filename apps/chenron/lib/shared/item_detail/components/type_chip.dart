import "package:flutter/material.dart";
import "package:database/database.dart";

class TypeChip extends StatelessWidget {
  final FolderItemType type;

  const TypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
