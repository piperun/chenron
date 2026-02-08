import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:vibe/vibe.dart";

/// Global theme registry (initialized in main)
late final VibeRegistry themeRegistry;
bool _themeRegistryInitialized = false;

/// Initialize the theme registry with all available themes
void initializeThemeRegistry() {
  // Skip if already initialized (happens in tests)
  if (_themeRegistryInitialized) {
    return;
  }

  themeRegistry = VibeRegistry();
  _themeRegistryInitialized = true;

  // Register built-in themes
  themeRegistry.register(NierTheme());

  // Register FlexColorScheme themes as simple wrappers
  for (final FlexScheme scheme in FlexScheme.values) {
    themeRegistry.register(_FlexSchemeTheme(scheme));
  }
}

/// Fetches a predefined theme based on its unique key.
///
/// Supports:
/// - "nier" (custom Nier theme via vibe)
/// - Any FlexScheme name (e.g., "greyLaw", "ebonyClay", etc.)
///
/// Returns a ThemeVariants (light/dark ThemeData) if found, else null.
ThemeVariants? getPredefinedTheme(String themeKey) {
  final VibeTheme? theme = themeRegistry.get(themeKey);
  return theme?.build();
}

/// Wrapper for FlexScheme themes to work with VibeTheme
class _FlexSchemeTheme implements VibeTheme {
  final FlexScheme scheme;

  _FlexSchemeTheme(this.scheme);

  @override
  String get id => scheme.name;

  @override
  String get name => scheme.name;

  @override
  ThemeVariants build() {
    return (
      light: FlexThemeData.light(scheme: scheme),
      dark: FlexThemeData.dark(scheme: scheme),
    );
  }
}

