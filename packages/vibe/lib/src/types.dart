import 'package:flex_color_scheme/flex_color_scheme.dart';

// Re-export from spec module
export 'package:vibe/src/spec/theme_spec.dart' show ThemeId, ThemeVariants;

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
