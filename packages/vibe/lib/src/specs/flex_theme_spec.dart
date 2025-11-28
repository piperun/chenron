import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibe/src/spec/theme_spec.dart';

/// Configuration for building FlexColorScheme themes
class FlexThemeBuildConfig {
  /// Creates a FlexThemeBuildConfig with the given parameters.
  const FlexThemeBuildConfig({
    this.surfaceMode = FlexSurfaceMode.level,
    this.lightBlendLevel = 8,
    this.darkBlendLevel = 15,
    this.useMaterial3 = true,
    this.visualDensity,
  });

  /// The surface mode to use.
  final FlexSurfaceMode surfaceMode;

  /// The blend level for light mode.
  final int lightBlendLevel;

  /// The blend level for dark mode.
  final int darkBlendLevel;

  /// Whether to use Material 3.
  final bool useMaterial3;

  /// The visual density.
  final VisualDensity? visualDensity;
}

/// Base implementation for FlexColorScheme-based themes
abstract class FlexThemeSpec implements ThemeSpec {
  /// Color scheme data for light/dark modes
  FlexSchemeData get schemeData;

  /// Sub-theme configuration
  FlexSubThemesData get subThemes => const FlexSubThemesData();

  /// Build configuration
  FlexThemeBuildConfig get buildConfig => const FlexThemeBuildConfig();

  @override
  ThemeVariants build() {
    final FlexThemeBuildConfig config = buildConfig;

    final ThemeData light = FlexThemeData.light(
      colors: schemeData.light,
      surfaceMode: config.surfaceMode,
      blendLevel: config.lightBlendLevel,
      subThemesData: subThemes,
      visualDensity:
          config.visualDensity ?? FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: config.useMaterial3,
      cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    );

    final ThemeData dark = FlexThemeData.dark(
      colors: schemeData.dark,
      surfaceMode: config.surfaceMode,
      blendLevel: config.darkBlendLevel,
      subThemesData: subThemes,
      visualDensity:
          config.visualDensity ?? FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: config.useMaterial3,
      cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    );

    return (light: light, dark: dark);
  }
}
