import "package:flutter/material.dart";

class SelectModeActionBar extends StatelessWidget {
  final int selectedCount;
  final int linkCount;
  final VoidCallback onSelectAll;
  final VoidCallback onTag;
  final VoidCallback onRefreshMetadata;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const SelectModeActionBar({
    super.key,
    required this.selectedCount,
    required this.linkCount,
    required this.onSelectAll,
    required this.onTag,
    required this.onRefreshMetadata,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final outlinedStyle = OutlinedButton.styleFrom(
      foregroundColor: colorScheme.onSurfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide(color: theme.dividerColor),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            selectedCount > 0
                ? "$selectedCount selected"
                : "None selected",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onSelectAll,
            icon: const Icon(Icons.select_all, size: 16),
            label: const Text("Select All"),
            style: outlinedStyle,
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: selectedCount > 0 ? onTag : null,
            icon: const Icon(Icons.label, size: 16),
            label: const Text("Tag"),
            style: outlinedStyle,
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: linkCount > 0 ? onRefreshMetadata : null,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text("Fetch"),
            style: outlinedStyle,
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: selectedCount > 0 ? onDelete : null,
            icon: const Icon(Icons.delete, size: 16),
            label: Text("Delete ($selectedCount)"),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              disabledBackgroundColor: colorScheme.surfaceContainerHighest,
              disabledForegroundColor: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close, size: 16),
            label: const Text("Cancel"),
            style: outlinedStyle,
          ),
        ],
      ),
    );
  }
}
