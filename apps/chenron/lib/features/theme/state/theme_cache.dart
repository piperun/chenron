import "package:chenron/features/theme/state/theme_controller.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:vibe/vibe.dart";

const _keyThemeKey = "theme_key";
const _keyThemeType = "theme_type";
const _keyPrimary = "theme_primary";
const _keySecondary = "theme_secondary";
const _keyTertiary = "theme_tertiary";
const _keySeedType = "theme_seed_type";

/// Reads/writes the selected theme to SharedPreferences so the first
/// frame after launch renders with the correct colors (no flash).
///
/// Mirrors the dark-mode caching pattern in [ThemeManager].
class ThemeCache {
  ThemeCache._();

  /// Rebuilds [ThemeVariants] from cached SharedPreferences values.
  ///
  /// Returns null when no cache exists or the cached key is invalid.
  static ThemeVariants? loadCachedTheme(SharedPreferences prefs) {
    final key = prefs.getString(_keyThemeKey);
    final typeIndex = prefs.getInt(_keyThemeType);
    if (key == null || typeIndex == null) return null;

    // Custom theme (ThemeType.custom.index == 0)
    if (typeIndex == 0) {
      final primary = prefs.getInt(_keyPrimary);
      final secondary = prefs.getInt(_keySecondary);
      final seedType = prefs.getInt(_keySeedType);
      if (primary == null || secondary == null || seedType == null) return null;
      return generateSeedTheme(
        primaryColor: primary,
        secondaryColor: secondary,
        tertiaryColor: prefs.getInt(_keyTertiary),
        seedType: seedType,
      );
    }

    // Special built-in themes
    if (key == "nier") return NierTheme().build();

    // System theme — parse FlexScheme enum by name
    try {
      final scheme = FlexScheme.values.byName(key);
      return (
        light: FlexThemeData.light(scheme: scheme),
        dark: FlexThemeData.dark(scheme: scheme),
      );
    } catch (_) {
      // Key doesn't match any FlexScheme — stale cache, ignore
      return null;
    }
  }

  /// Caches a system (FlexScheme / Nier) theme selection.
  static Future<void> cacheSystemTheme(
    SharedPreferences prefs, {
    required String key,
  }) async {
    await prefs.setString(_keyThemeKey, key);
    await prefs.setInt(_keyThemeType, 1); // ThemeType.system.index
    // Clear custom-only keys
    await prefs.remove(_keyPrimary);
    await prefs.remove(_keySecondary);
    await prefs.remove(_keyTertiary);
    await prefs.remove(_keySeedType);
  }

  /// Caches a custom seed theme selection (colors + seed type).
  static Future<void> cacheCustomTheme(
    SharedPreferences prefs, {
    required String key,
    required int primaryColor,
    required int secondaryColor,
    int? tertiaryColor,
    required int seedType,
  }) async {
    await prefs.setString(_keyThemeKey, key);
    await prefs.setInt(_keyThemeType, 0); // ThemeType.custom.index
    await prefs.setInt(_keyPrimary, primaryColor);
    await prefs.setInt(_keySecondary, secondaryColor);
    if (tertiaryColor != null) {
      await prefs.setInt(_keyTertiary, tertiaryColor);
    } else {
      await prefs.remove(_keyTertiary);
    }
    await prefs.setInt(_keySeedType, seedType);
  }

  /// Removes all cached theme keys.
  static Future<void> clearCache(SharedPreferences prefs) async {
    await prefs.remove(_keyThemeKey);
    await prefs.remove(_keyThemeType);
    await prefs.remove(_keyPrimary);
    await prefs.remove(_keySecondary);
    await prefs.remove(_keyTertiary);
    await prefs.remove(_keySeedType);
  }
}
