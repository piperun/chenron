// 2. Theme Generator Component
import "package:chenron/features/settings/ui/theme/components/generate_theme/color_preset_selector.dart";
import "package:chenron/features/settings/ui/theme/components/color_picker.dart";
import "package:flutter/material.dart";

class ThemeGenerator extends StatelessWidget {
  final Color seedColor;
  final ValueChanged<Color> onSeedColorChanged;

  const ThemeGenerator({
    super.key,
    required this.seedColor,
    required this.onSeedColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select a seed color:",
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          color: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          ),
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ColorPickerTile(
                  title: "Custom Color",
                  pickerColor: seedColor,
                  onColorChanged: onSeedColorChanged,
                ),
                const SizedBox(height: 20),
                Text(
                  "Or choose a preset:",
                  style: textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                ColorPresetSelector(
                  selectedColor: seedColor,
                  onColorSelected: onSeedColorChanged,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
