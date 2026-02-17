import "package:chenron/shared/constants/tag_colors.dart";
import "package:flutter/material.dart";

/// Shows a small color picker popup near [anchor].
///
/// Returns a record with the selected color (`null` to clear), or
/// `null` itself if the menu was dismissed without any selection.
Future<({int? color})?> showTagColorPicker({
  required BuildContext context,
  required RelativeRect anchor,
  int? currentColor,
}) async {
  // Sentinel distinguishes "clear" (pop -1) from "dismissed" (pop null).
  const clearSentinel = -1;
  final result = await showMenu<int?>(
    context: context,
    position: anchor,
    constraints: const BoxConstraints(maxWidth: 200),
    items: [
      PopupMenuItem<int?>(
        enabled: false,
        height: 0,
        padding: EdgeInsets.zero,
        child: _ColorGrid(
          currentColor: currentColor,
          clearSentinel: clearSentinel,
        ),
      ),
    ],
  );
  if (result == null) return null; // dismissed
  if (result == clearSentinel) return (color: null); // clear
  return (color: result); // color chosen
}

class _ColorGrid extends StatelessWidget {
  final int? currentColor;
  final int clearSentinel;
  const _ColorGrid({this.currentColor, required this.clearSentinel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Clear color option
          _ColorCircle(
            color: null,
            isSelected: currentColor == null,
            onTap: () => Navigator.of(context).pop(clearSentinel),
          ),
          // Palette colors
          for (final color in kTagColorPalette)
            _ColorCircle(
              color: color,
              isSelected: currentColor == color.toARGB32(),
              onTap: () => Navigator.of(context).pop(color.toARGB32()),
            ),
        ],
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 28.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: color == null
            ? Icon(
                Icons.block,
                size: 16,
                color: theme.colorScheme.outline,
              )
            : isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
      ),
    );
  }
}
