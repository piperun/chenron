import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibe/src/theme.dart';

/// Base class for themes that need full [FlexSchemeColor] control.
///
/// Override [lightColors], [darkColors], and optionally [subThemes]
/// to customise every Material colour role. Override [build] for
/// post-processing (e.g. `copyWith` tweaks).
///
/// ```dart
/// class MyTheme extends FlexVibeTheme {
///   @override String get id => 'my_theme';
///   @override String get name => 'My Theme';
///   @override FlexSchemeColor get lightColors => FlexSchemeColor(...);
///   @override FlexSchemeColor get darkColors => FlexSchemeColor(...);
/// }
/// ```
abstract class FlexVibeTheme implements VibeTheme {
  /// [FlexSchemeColor] for light mode.
  FlexSchemeColor get lightColors;

  /// [FlexSchemeColor] for dark mode.
  FlexSchemeColor get darkColors;

  /// Sub-theme configuration for component-level styling.
  /// Defaults to empty (FlexColorScheme defaults).
  FlexSubThemesData get subThemes => const FlexSubThemesData();

  @override
  ThemeVariants build() {
    final ThemeData light = FlexThemeData.light(
      colors: lightColors,
      surfaceMode: FlexSurfaceMode.level,
      blendLevel: 8,
      subThemesData: subThemes,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      cupertinoOverrideTheme:
          const CupertinoThemeData(applyThemeToAll: true),
    );

    final ThemeData dark = FlexThemeData.dark(
      colors: darkColors,
      surfaceMode: FlexSurfaceMode.level,
      blendLevel: 15,
      subThemesData: subThemes,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      cupertinoOverrideTheme:
          const CupertinoThemeData(applyThemeToAll: true),
    );

    return (light: light, dark: dark);
  }
}
