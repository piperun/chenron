import "package:flutter/material.dart";

/// Preset color palette shared across tags, folders, and charts.
const kColorPalette = [
  Colors.blue,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.red,
  Colors.green,
  Colors.indigo,
  Colors.amber,
  Colors.cyan,
  Colors.pink,
];

/// Human-readable name for each palette color, keyed by ARGB32 value.
final kColorPaletteNames = {
  for (final entry in {
    Colors.blue: "Blue",
    Colors.purple: "Purple",
    Colors.orange: "Orange",
    Colors.teal: "Teal",
    Colors.red: "Red",
    Colors.green: "Green",
    Colors.indigo: "Indigo",
    Colors.amber: "Amber",
    Colors.cyan: "Cyan",
    Colors.pink: "Pink",
  }.entries)
    entry.key.toARGB32(): entry.value,
};

/// Returns the palette name for [colorValue], or "Custom" if not found.
String colorPaletteName(int? colorValue) {
  if (colorValue == null) return "Default";
  return kColorPaletteNames[colorValue] ?? "Custom";
}
