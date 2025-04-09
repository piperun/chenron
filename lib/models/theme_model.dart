import "dart:convert";
import "package:flutter/material.dart"
    show
        Brightness,
        Color,
        ColorScheme,
        Colors,
        DynamicSchemeVariant,
        MaterialColor;

/// A model class that represents a user theme and provides easy conversion
/// between ColorScheme and database storage.
class ThemeModel {
  // User-facing properties
  final String name;
  final String? description;

  // Theme data (internal representation)
  final Map<String, dynamic> _themeData;

  ThemeModel({
    required this.name,
    this.description,
    DateTime? createdAt,
    required Map<String, dynamic> themeData,
  }) : _themeData = themeData;

  String get type {
    return _themeData["type"];
  }

  String toJson() => json.encode({
        ..._themeData,
        "name": name,
        "description": description,
      });

  factory ThemeModel.fromJson(String jsonString) {
    final data = json.decode(jsonString);

    return ThemeModel(
      name: data["name"],
      description: data["description"],
      themeData: {
        for (final entry in data.entries)
          if (!["name", "description", "isDefault", "createdAt"]
              .contains(entry.key))
            entry.key: entry.value,
      },
    );
  }

  // Create from a ColorScheme using seed color
  factory ThemeModel.fromSeed({
    required String name,
    String? description,
    bool isDefault = false,
    required Color seedColor,
    Brightness brightness = Brightness.light,
    DynamicSchemeVariant variant = DynamicSchemeVariant.tonalSpot,
    double contrastLevel = 0.0,
    Map<String, Color>? colorOverrides,
  }) {
    return ThemeModel(
      name: name,
      description: description,
      themeData: {
        "type": "seed",
        "seedColor":
            '#${seedColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
        "brightness": brightness == Brightness.light ? "light" : "dark",
        "dynamicSchemeVariant": variant.toString().split(".").last,
        "contrastLevel": contrastLevel,
        if (colorOverrides != null)
          "colorOverrides": {
            for (final entry in colorOverrides.entries)
              entry.key:
                  '#${entry.value.toARGB32().toRadixString(16).padLeft(8, '0')}',
          },
      },
    );
  }

  // Create from a ColorScheme using swatch
  factory ThemeModel.fromSwatch({
    required String name,
    String? description,
    bool isDefault = false,
    required MaterialColor primarySwatch,
    Color? accentColor,
    Color? cardColor,
    Color? backgroundColor,
    Color? errorColor,
    Brightness brightness = Brightness.light,
  }) {
    return ThemeModel(
      name: name,
      description: description,
      themeData: {
        "type": "swatch",
        "primarySwatch":
            '#${primarySwatch.toARGB32().toRadixString(16).padLeft(8, '0')}',
        "brightness": brightness == Brightness.light ? "light" : "dark",
        if (accentColor != null)
          "accentColor":
              '#${accentColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
        if (cardColor != null)
          "cardColor":
              '#${cardColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
        if (backgroundColor != null)
          "backgroundColor":
              '#${backgroundColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
        if (errorColor != null)
          "errorColor":
              '#${errorColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
      },
    );
  }

  // Convert to a Flutter ColorScheme
  ColorScheme toColorScheme() {
    switch (_themeData["type"]) {
      case "seed":
        return _toSeedColorScheme();
      case "swatch":
        return _toSwatchColorScheme();
      default:
        throw Exception('Unknown theme type: ${_themeData['type']}');
    }
  }

  // Convert a seed-based theme to ColorScheme
  ColorScheme _toSeedColorScheme() {
    final seedColor =
        Color(int.parse(_themeData["seedColor"].substring(1), radix: 16));
    final brightness =
        _themeData["brightness"] == "dark" ? Brightness.dark : Brightness.light;

    // Parse variant
    final variantStr = _themeData["dynamicSchemeVariant"];
    final variant = DynamicSchemeVariant.values.firstWhere(
      (v) => v.toString().split(".").last == variantStr,
      orElse: () => DynamicSchemeVariant.tonalSpot,
    );

    // Parse contrast level
    final contrastLevel = _themeData["contrastLevel"] ?? 0.0;

    // Parse color overrides
    final colorOverrides = <String, Color>{};
    if (_themeData.containsKey("colorOverrides")) {
      final overrides = _themeData["colorOverrides"] as Map;
      for (final entry in overrides.entries) {
        final colorStr = entry.value as String;
        colorOverrides[entry.key] =
            Color(int.parse(colorStr.substring(1), radix: 16));
      }
    }

    // Create the ColorScheme with any applicable overrides
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      dynamicSchemeVariant: variant,
      contrastLevel: contrastLevel,
      primary: colorOverrides["primary"],
      onPrimary: colorOverrides["onPrimary"],
      primaryContainer: colorOverrides["primaryContainer"],
      onPrimaryContainer: colorOverrides["onPrimaryContainer"],
      secondary: colorOverrides["secondary"],
      onSecondary: colorOverrides["onSecondary"],
    );
  }

  // Convert a swatch-based theme to ColorScheme
  ColorScheme _toSwatchColorScheme() {
    // For swatch, we need to handle it differently as MaterialColor
    // needs special handling
    final swatchValue =
        int.parse(_themeData["primarySwatch"].substring(1), radix: 16);

    // This is a simplification - in a real app you'd need to map the value
    // to an actual MaterialColor or create a custom one
    final MaterialColor primarySwatch = Colors.primaries.firstWhere(
      (color) => color.toARGB32() == swatchValue,
      orElse: () => Colors.blue,
    );

    final brightness =
        _themeData["brightness"] == "dark" ? Brightness.dark : Brightness.light;

    // Parse optional colors
    Color? accentColor, cardColor, backgroundColor, errorColor;

    if (_themeData.containsKey("accentColor")) {
      accentColor =
          Color(int.parse(_themeData["accentColor"].substring(1), radix: 16));
    }

    if (_themeData.containsKey("cardColor")) {
      cardColor =
          Color(int.parse(_themeData["cardColor"].substring(1), radix: 16));
    }

    if (_themeData.containsKey("backgroundColor")) {
      backgroundColor = Color(
          int.parse(_themeData["backgroundColor"].substring(1), radix: 16));
    }

    if (_themeData.containsKey("errorColor")) {
      errorColor =
          Color(int.parse(_themeData["errorColor"].substring(1), radix: 16));
    }

    return ColorScheme.fromSwatch(
      primarySwatch: primarySwatch,
      accentColor: accentColor,
      cardColor: cardColor,
      backgroundColor: backgroundColor,
      errorColor: errorColor,
      brightness: brightness,
    );
  }

  // Create a copy of this ThemeModel with some fields replaced
  ThemeModel copyWith({
    String? name,
    String? description,
    bool? isDefault,
    DateTime? createdAt,
    Map<String, dynamic>? themeData,
  }) {
    return ThemeModel(
      name: name ?? this.name,
      description: description ?? this.description,
      themeData: themeData ?? Map<String, dynamic>.from(_themeData),
    );
  }
}
