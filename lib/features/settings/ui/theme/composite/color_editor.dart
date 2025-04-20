import "package:chenron/features/settings/ui/theme/components/color_picker.dart";
import "package:flutter/material.dart";

class ColorEditor extends StatelessWidget {
  final Color seedColor;
  final ValueChanged<Color> onColorChanged;

  const ColorEditor({
    super.key,
    required this.seedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Generate ColorScheme from seed color for the preview
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customize individual colors of your theme:",
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        ColorPickerTile(
          title: "Primary",
          pickerColor: colorScheme.primary,
          onColorChanged: onColorChanged,
        ),
        const Divider(),
        ColorPickerTile(
          title: "Secondary",
          pickerColor: colorScheme.secondary,
          onColorChanged: onColorChanged,
        ),
        const Divider(),
        ColorPickerTile(
          title: "Tertiary",
          pickerColor: colorScheme.tertiary,
          onColorChanged: onColorChanged,
        ),
        const Divider(),
        ColorPickerTile(
          title: "Error",
          pickerColor: colorScheme.error,
          onColorChanged: onColorChanged,
        ),
        const Divider(),
        ColorPickerTile(
          title: "Surface",
          pickerColor: colorScheme.surface,
          onColorChanged: onColorChanged,
        ),
        const Divider(),
        ColorPickerTile(
          title: "Background",
          pickerColor: colorScheme.surface,
          onColorChanged: onColorChanged,
        ),
      ],
    );
  }
}
