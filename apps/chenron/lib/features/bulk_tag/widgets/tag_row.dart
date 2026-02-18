import "package:chenron/features/bulk_tag/models/bulk_tag_result.dart";
import "package:chenron/shared/color_picker/color_dot.dart";
import "package:flutter/material.dart";

class TagRow extends StatelessWidget {
  final String tagName;
  final TagAction action;
  final int? tagColor;
  final int? coverage;
  final int? itemCount;
  final bool allHaveIt;
  final VoidCallback onToggle;
  final ValueChanged<int?> onColorChanged;

  const TagRow({
    super.key,
    required this.tagName,
    required this.action,
    required this.tagColor,
    required this.coverage,
    required this.itemCount,
    required this.allHaveIt,
    required this.onToggle,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showCoverage = coverage != null && itemCount != null;

    final (IconData icon, Color iconColor, Color bgColor, Color borderColor) =
        switch (action) {
      TagAction.add => (
          Icons.add_circle,
          colorScheme.primary,
          colorScheme.primaryContainer.withValues(alpha: 0.4),
          colorScheme.primary.withValues(alpha: 0.5),
        ),
      TagAction.remove => (
          Icons.remove_circle,
          colorScheme.error,
          colorScheme.errorContainer.withValues(alpha: 0.4),
          colorScheme.error.withValues(alpha: 0.5),
        ),
      TagAction.none => (
          Icons.check_box_outline_blank,
          colorScheme.outline,
          Colors.transparent,
          theme.dividerColor,
        ),
    };

    final isActive = action != TagAction.none;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            // Color dot — tap to pick a color
            ColorDot(
              currentColor: tagColor,
              onColorChanged: onColorChanged,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tagName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: action == TagAction.remove
                      ? colorScheme.error
                      : theme.textTheme.bodyMedium?.color,
                  decoration: action == TagAction.remove
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
            if (showCoverage)
              Text(
                allHaveIt
                    ? "all have it"
                    : "$coverage/$itemCount already",
                style: TextStyle(
                  fontSize: 12,
                  color: allHaveIt
                      ? colorScheme.outline
                      : colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
