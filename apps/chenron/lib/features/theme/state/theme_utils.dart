import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:vibe/vibe.dart" hide ThemeVariants;
import "package:chenron/features/theme/state/theme_controller.dart"; // For ThemeVariants typedef

/// Fetches a predefined theme based on its unique key.
///
/// Supports:
/// - "nier" (custom Nier theme via vibe)
/// - Any FlexScheme name (e.g., "greyLaw", "ebonyClay", etc.)
///
/// Returns a ThemeVariants (light/dark ThemeData) if found, else null.
ThemeVariants? getPredefinedTheme(String themeKey) {
  switch (themeKey) {
    case "nier":
      return buildNierTheme();
    default:
      for (final scheme in FlexScheme.values) {
        if (scheme.name == themeKey) {
          return (
            light: FlexThemeData.light(scheme: scheme),
            dark: FlexThemeData.dark(scheme: scheme),
          );
        }
      }
      return null;
  }
}
