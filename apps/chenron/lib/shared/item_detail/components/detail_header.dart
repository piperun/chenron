import "package:flutter/material.dart";
import "package:database/database.dart";

class DetailHeader extends StatelessWidget {
  final FolderItemType itemType;
  final String? title;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final VoidCallback onClose;

  const DetailHeader({
    super.key,
    required this.itemType,
    required this.title,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _iconForType(itemType),
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title ?? "Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit_outlined),
            onPressed: onToggleEdit,
            tooltip: isEditing ? "Done editing" : "Edit",
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: "Close",
          ),
        ],
      ),
    );
  }

  static IconData _iconForType(FolderItemType type) {
    return switch (type) {
      FolderItemType.link => Icons.link,
      FolderItemType.document => Icons.description,
      FolderItemType.folder => Icons.folder,
    };
  }
}
