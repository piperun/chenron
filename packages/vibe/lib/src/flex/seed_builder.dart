import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:vibe/src/theme.dart';

/// Builds [ThemeVariants] from seed colors using FlexColorScheme's
/// key-color seeding algorithm.
///
/// [primary] is the only required color. [secondary] and [tertiary] are
/// optional and default to [primary] when absent.
///
/// Set [useSecondary] or [useTertiary] to include those colors as
/// additional key colors in the seeding algorithm.
ThemeVariants buildSeededVariants({
  required Color primary,
  Color? secondary,
  Color? tertiary,
  bool useSecondary = false,
  bool useTertiary = false,
  FlexSubThemesData? subThemes,
  bool useMaterial3 = true,
}) {
  final FlexSchemeColor custom = FlexSchemeColor(
    primary: primary,
    secondary: secondary ?? primary,
    tertiary: tertiary ?? (secondary ?? primary),
  );
  final FlexKeyColors keyColors = FlexKeyColors(
    useKeyColors: true,
    useSecondary: useSecondary,
    useTertiary: useTertiary,
  );

  final FlexColorScheme lightScheme = FlexColorScheme.light(
    colors: custom,
    keyColors: keyColors,
    subThemesData: subThemes,
    useMaterial3: useMaterial3,
  );
  final FlexColorScheme darkScheme = FlexColorScheme.dark(
    colors: custom,
    keyColors: keyColors,
    subThemesData: subThemes,
    useMaterial3: useMaterial3,
  );

  return (
    light: lightScheme.toTheme,
    dark: darkScheme.toTheme,
  );
}
