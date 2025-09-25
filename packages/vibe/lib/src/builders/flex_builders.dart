import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:vibe/src/types.dart';

/// Builds ThemeData light/dark from FlexSchemeColor pairs.
ThemeVariants buildVariantsFromFlexSchemeColors({
  required FlexSchemeColor light,
  required FlexSchemeColor dark,
  FlexSubThemesData? subThemes,
  bool useMaterial3 = true,
}) {
  final FlexColorScheme lightScheme = FlexColorScheme.light(
    colors: light,
    subThemesData: subThemes,
    useMaterial3: useMaterial3,
  );
  final FlexColorScheme darkScheme = FlexColorScheme.dark(
    colors: dark,
    subThemesData: subThemes,
    useMaterial3: useMaterial3,
  );
  return (
    light: lightScheme.toTheme,
    dark: darkScheme.toTheme,
  );
}

/// Builds ThemeData light/dark from a FlexSchemeData (which contains
/// FlexSchemeColor for light and dark).
ThemeVariants buildVariantsFromFlexSchemeData(
  FlexSchemeData data, {
  FlexSubThemesData? subThemes,
  bool useMaterial3 = true,
}) {
  return buildVariantsFromFlexSchemeColors(
    light: data.light,
    dark: data.dark,
    subThemes: subThemes,
    useMaterial3: useMaterial3,
  );
}

/// Builds ThemeData light/dark purely from seed colors using FlexColorScheme's
/// key color seeding options.
///
/// If [useSecondary] or [useTertiary] are enabled, those colors will be used
/// as additional key colors in the seeding algorithm.
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
