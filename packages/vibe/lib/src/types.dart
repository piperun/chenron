import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Identifier for a theme.
typedef ThemeId = String;

/// Preferred theme mode selection.
/// - [system]: follow platform brightness
/// - [light]: force light mode
/// - [dark]: force dark mode
enum ThemeModePref {
  /// Follow platform brightness.
  system,

  /// Force light mode.
  light,

  /// Force dark mode.
  dark,
}

/// A pair of Material ThemeData for light and dark variants.
typedef ThemeVariants = ({ThemeData light, ThemeData dark});

/// A helper describing color roles for a theme based on FlexSchemeColor.
///
/// Use [FlexSchemeColor] for color roles and derive ThemeData with
/// [FlexColorScheme.light]/[FlexColorScheme.dark].
class ThemeColors {
  /// Creates a ThemeColors container.
  const ThemeColors({required this.light, required this.dark});

  /// Light mode colors.
  final FlexSchemeColor light;

  /// Dark mode colors.
  final FlexSchemeColor dark;
}
