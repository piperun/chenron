import "package:vibe/vibe.dart" hide ThemeVariants;
import "package:chenron/features/theme/state/theme_controller.dart"; // For ThemeVariants typedef

/// Fetches a predefined theme based on its unique key.
///
/// Returns a ThemeVariants (light/dark ThemeData) if found, else null.
ThemeVariants? getPredefinedTheme(String themeKey) {
  switch (themeKey) {
    case "nier":
      return buildNierTheme();
    default:
      return null;
  }
}
