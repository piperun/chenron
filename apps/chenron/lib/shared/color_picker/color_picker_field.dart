import "package:chenron/shared/constants/color_palette.dart";
import "package:chenron/shared/dialogs/color_picker.dart";
import "package:flutter/material.dart";

/// A form-field-style color picker: label on top, tappable preview card below.
///
/// Shows the current color as a rounded swatch with its name and a
/// "Tap to change" hint. Tapping opens the shared [showColorPicker] popup.
class ColorPickerField extends StatelessWidget {
  final String label;
  final int? currentColor;
  final ValueChanged<int?> onColorChanged;

  const ColorPickerField({
    super.key,
    this.label = "Color",
    this.currentColor,
    required this.onColorChanged,
  });

  Future<void> _handleTap(BuildContext context) async {
    final button = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final anchor = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showColorPicker(
      context: context,
      anchor: anchor,
      currentColor: currentColor,
    );

    if (result != null) {
      onColorChanged(result.color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = currentColor != null
        ? Color(currentColor!)
        : theme.colorScheme.primary;
    final name = colorPaletteName(currentColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (ctx) => InkWell(
            onTap: () => _handleTap(ctx),
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                border:
                    Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: displayColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.colorScheme.outline
                            .withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Tap to change",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
