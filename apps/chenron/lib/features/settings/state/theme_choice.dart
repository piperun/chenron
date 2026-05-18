import "package:flutter/material.dart";
import "package:database/database.dart";

enum ThemeSortMode { name, colorCount }

/// One selectable theme entry in the settings UI — a built-in
/// FlexScheme, a hand-coded curated theme (Nier), or a user-created
/// custom theme. The pair `(key, type)` is what gets persisted.
@immutable
class ThemeChoice {
  final String key;
  final String name;
  final ThemeType type;
  final int colorCount;
  final List<Color> swatches;

  const ThemeChoice({
    required this.key,
    required this.name,
    required this.type,
    this.colorCount = 1,
    this.swatches = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeChoice &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          type == other.type;

  @override
  int get hashCode => key.hashCode ^ type.hashCode;
}
