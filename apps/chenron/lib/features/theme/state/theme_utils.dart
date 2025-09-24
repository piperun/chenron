import "package:chenron/shared/themes/nier/nier_theme.dart";
import "package:chenron/features/theme/state/theme_controller.dart"; // For ThemeVariants typedef
import "package:flex_color_scheme/flex_color_scheme.dart";
// Add imports for any other predefined themes here

/// Fetches a predefined theme based on its unique key.
///
/// Returns a [ThemeSchemePair] containing the light and dark FlexColorSchemes
/// if a theme with the matching [themeKey] is found, otherwise returns null.
ThemeVariants? getPredefinedTheme(String themeKey) {
  switch (themeKey) {
    case "nier":
      return (
        light: NierTheme.staticLightTheme,
        dark: NierTheme.staticDarkTheme
      );

    default:
      return null;
  }
}
