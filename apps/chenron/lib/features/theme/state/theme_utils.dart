import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/material.dart";
import "package:vibe/vibe.dart";

/// Global theme registry. Always non-null so unit tests that bypass
/// `initializeThemeRegistry` can still query it (they get an empty
/// registry and `getPredefinedTheme` returns null, which calling code
/// already handles).
final VibeRegistry themeRegistry = VibeRegistry();
bool _themeRegistryInitialized = false;

/// Initialize the theme registry with all available themes
void initializeThemeRegistry() {
  // Skip if already populated (happens in tests).
  if (_themeRegistryInitialized) {
    return;
  }
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
/// [options] is forwarded to the theme's `build()` so per-theme
/// settings (e.g. Nier's grid overlay toggle) reach the underlying
/// theme. Themes that don't declare settings ignore the parameter.
///
/// Returns a ThemeVariants (light/dark ThemeData) if found, else null.
ThemeVariants? getPredefinedTheme(
  String themeKey, [
  Map<String, Object?> options = const <String, Object?>{},
]) {
  final VibeTheme? theme = themeRegistry.get(themeKey);
  return theme?.build(options);
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
  List<ThemeSetting<Object?>> get settings => const <ThemeSetting<Object?>>[];

  @override
  ThemeVariants build([
    Map<String, Object?> options = const <String, Object?>{},
  ]) {
    return (
      light: FlexThemeData.light(scheme: scheme),
      dark: FlexThemeData.dark(scheme: scheme),
    );
  }
}

bool _isSameHue(Color a, Color b, {double threshold = 30.0}) {
  final hslA = HSLColor.fromColor(a);
  final hslB = HSLColor.fromColor(b);

  // Treat very desaturated colors as the same "neutral" group
  if (hslA.saturation < 0.1 && hslB.saturation < 0.1) return true;
  if (hslA.saturation < 0.1 || hslB.saturation < 0.1) return false;

  final diff = (hslA.hue - hslB.hue).abs();
  // Wrap around the 360° color wheel
  return diff <= threshold || diff >= (360 - threshold);
}

/// Returns only the visually distinct colors from [primary], [secondary],
/// [tertiary]. Deduplicates colors that share the same hue (within 30°).
List<Color> distinctSwatches(
  Color primary,
  Color secondary,
  Color tertiary,
) {
  final result = [primary];
  if (!_isSameHue(primary, secondary)) result.add(secondary);
  if (!_isSameHue(primary, tertiary) &&
      (result.length < 2 || !_isSameHue(secondary, tertiary))) {
    result.add(tertiary);
  }
  return result;
}

/// Counts how many visually distinct hues exist among up to 3 colors.
int countDistinctHues(
  Color primary,
  Color secondary,
  Color tertiary,
) {
  return distinctSwatches(primary, secondary, tertiary).length;
}

