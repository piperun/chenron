import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibe/src/palette.dart';
import 'package:vibe/src/theme.dart';

/// Builds a [ThemeVariants] pair from light and dark [VibePalette]s.
///
/// Maps semantic palette roles to [FlexSchemeColor], builds via
/// FlexColorScheme, then applies a `copyWith` pass to set
/// canvas/surface/content/outline overrides.
ThemeVariants buildVariantsFromPalettes({
  required VibePalette light,
  required VibePalette dark,
  bool useMaterial3 = true,
}) {
  return (
    light: _buildTheme(light, Brightness.light, useMaterial3),
    dark: _buildTheme(dark, Brightness.dark, useMaterial3),
  );
}

ThemeData _buildTheme(
  VibePalette palette,
  Brightness brightness,
  bool useMaterial3,
) {
  final FlexSchemeColor colors = _paletteToFlexColors(palette);

  final ThemeData base = brightness == Brightness.light
      ? FlexThemeData.light(
          colors: colors,
          useMaterial3: useMaterial3,
          surfaceMode: FlexSurfaceMode.level,
          blendLevel: 8,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          cupertinoOverrideTheme:
              const CupertinoThemeData(applyThemeToAll: true),
        )
      : FlexThemeData.dark(
          colors: colors,
          useMaterial3: useMaterial3,
          surfaceMode: FlexSurfaceMode.level,
          blendLevel: 15,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          cupertinoOverrideTheme:
              const CupertinoThemeData(applyThemeToAll: true),
        );

  // Apply semantic overrides that FlexColorScheme may have blended away.
  return base.copyWith(
    scaffoldBackgroundColor: palette.canvas,
    cardTheme: base.cardTheme.copyWith(color: palette.surface),
    colorScheme: base.colorScheme.copyWith(
      surface: palette.canvas,
      surfaceContainer: palette.surface,
      surfaceContainerLow: palette.surfaceVariant ?? palette.surface,
      onSurface: palette.content,
      onSurfaceVariant: palette.contentDim,
      onPrimary: palette.onAccent,
      outline: palette.outline,
    ),
  );
}

/// Maps [VibePalette] semantic roles to [FlexSchemeColor] Material roles.
FlexSchemeColor _paletteToFlexColors(VibePalette palette) {
  return FlexSchemeColor(
    primary: palette.accent,
    secondary: palette.accentAlt ?? palette.accent,
    tertiary: palette.outline,
    error: palette.error,
  );
}
