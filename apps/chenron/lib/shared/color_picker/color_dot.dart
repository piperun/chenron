import "package:chenron/shared/dialogs/color_picker.dart";
import "package:flutter/material.dart";

/// A small tappable color indicator that opens [showColorPicker] on tap.
///
/// Used inline in tag rows and other compact contexts where a full
/// [ColorPickerField] would be too large.
class ColorDot extends StatelessWidget {
  final int? currentColor;
  final IconData icon;
  final double size;
  final ValueChanged<int?> onColorChanged;

  const ColorDot({
    super.key,
    this.currentColor,
    this.icon = Icons.sell,
    this.size = 18,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapUp: (details) async {
        final box = context.findRenderObject()! as RenderBox;
        final overlay =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final anchor = RelativeRect.fromRect(
          Rect.fromPoints(
            box.localToGlobal(Offset.zero, ancestor: overlay),
            box.localToGlobal(box.size.bottomRight(Offset.zero),
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
      },
      child: Icon(
        icon,
        size: size,
        color: currentColor != null
            ? Color(currentColor!)
            : theme.colorScheme.outlineVariant,
      ),
    );
  }
}
