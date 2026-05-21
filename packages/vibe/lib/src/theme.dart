import 'package:flutter/material.dart';
import 'package:vibe/src/flex/palette_builder.dart';
import 'package:vibe/src/flex/seed_builder.dart';
import 'package:vibe/src/palette.dart';
import 'package:vibe/src/themes/theme_setting.dart';

/// A pair of Material [ThemeData] for light and dark variants.
typedef ThemeVariants = ({ThemeData light, ThemeData dark});

/// Contract that all vibe themes must fulfill.
///
/// Three ways to create a [VibeTheme]:
/// - [VibeTheme.fromSeed] — Tier 1: 1-3 seed colors
/// - [VibeTheme.fromPalette] — Tier 2/3: 6-10 palette colors
/// - Subclass [FlexVibeTheme] — Tier 4: full FlexSchemeColor control
abstract class VibeTheme {
  /// Creates a seed-based theme (Tier 1).
  ///
  /// FlexColorScheme generates the full palette from [primary]
  /// (and optionally [secondary] / [tertiary]).
  factory VibeTheme.fromSeed({
    required String id,
    required String name,
    required Color primary,
    Color? secondary,
    Color? tertiary,
    bool useSecondary,
    bool useTertiary,
  }) = _SeedVibeTheme;

  /// Creates a palette-based theme (Tier 2 / Tier 3).
  ///
  /// Provide a [VibePalette] for each brightness mode.
  /// Compact palettes (6 required colors) use Tier 2.
  /// Full palettes (with optional overrides) use Tier 3.
  factory VibeTheme.fromPalette({
    required String id,
    required String name,
    required VibePalette light,
    required VibePalette dark,
  }) = _PaletteVibeTheme;

  /// Unique string identifier for this theme.
  String get id;

  /// Human-readable display name.
  String get name;

  /// Declarative list of user-configurable options this theme exposes.
  ///
  /// Defaults to empty so existing themes opt in only when they want a
  /// settings UI. The host app renders one tile per entry and passes
  /// chosen values back through [build].
  List<ThemeSetting<Object?>> get settings => const <ThemeSetting<Object?>>[];

  /// Build the light and dark theme variants.
  ///
  /// [options] carries user-chosen values keyed by [ThemeSetting.key].
  /// Themes that don't declare [settings] ignore the parameter.
  ThemeVariants build([Map<String, Object?> options = const <String, Object?>{}]);
}

class _SeedVibeTheme implements VibeTheme {
  _SeedVibeTheme({
    required this.id,
    required this.name,
    required this.primary,
    this.secondary,
    this.tertiary,
    this.useSecondary = false,
    this.useTertiary = false,
  });

  @override
  final String id;

  @override
  final String name;

  final Color primary;
  final Color? secondary;
  final Color? tertiary;
  final bool useSecondary;
  final bool useTertiary;

  @override
  List<ThemeSetting<Object?>> get settings => const <ThemeSetting<Object?>>[];

  @override
  ThemeVariants build([
    Map<String, Object?> options = const <String, Object?>{},
  ]) =>
      buildSeededVariants(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        useSecondary: useSecondary,
        useTertiary: useTertiary,
      );
}

class _PaletteVibeTheme implements VibeTheme {
  _PaletteVibeTheme({
    required this.id,
    required this.name,
    required this.light,
    required this.dark,
  });

  @override
  final String id;

  @override
  final String name;

  final VibePalette light;
  final VibePalette dark;

  @override
  List<ThemeSetting<Object?>> get settings => const <ThemeSetting<Object?>>[];

  @override
  ThemeVariants build([
    Map<String, Object?> options = const <String, Object?>{},
  ]) =>
      buildVariantsFromPalettes(
        light: light,
        dark: dark,
      );
}
