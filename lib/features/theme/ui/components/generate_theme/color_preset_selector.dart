import "package:chenron/features/theme/ui/components/generate_theme/preset_button.dart";
import "package:flutter/material.dart"
    show
        BuildContext,
        Color,
        Colors,
        StatelessWidget,
        ValueChanged,
        Widget,
        Wrap;

class ColorPresetSelector extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPresetSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        PresetColorButton(
          color: Colors.blue,
          label: "Blue",
          isSelected: selectedColor.toARGB32() == Colors.blue.toARGB32(),
          onSelected: () => onColorSelected(Colors.blue),
        ),
        PresetColorButton(
          color: Colors.red,
          label: "Red",
          isSelected: selectedColor.toARGB32() == Colors.red.toARGB32(),
          onSelected: () => onColorSelected(Colors.red),
        ),
        PresetColorButton(
          color: Colors.green,
          label: "Green",
          isSelected: selectedColor.toARGB32() == Colors.green.toARGB32(),
          onSelected: () => onColorSelected(Colors.green),
        ),
        PresetColorButton(
          color: Colors.purple,
          label: "Purple",
          isSelected: selectedColor.toARGB32() == Colors.purple.toARGB32(),
          onSelected: () => onColorSelected(Colors.purple),
        ),
        PresetColorButton(
          color: Colors.orange,
          label: "Orange",
          isSelected: selectedColor.toARGB32() == Colors.orange.toARGB32(),
          onSelected: () => onColorSelected(Colors.orange),
        ),
        PresetColorButton(
          color: Colors.teal,
          label: "Teal",
          isSelected: selectedColor.toARGB32() == Colors.teal.toARGB32(),
          onSelected: () => onColorSelected(Colors.teal),
        ),
      ],
    );
  }
}
