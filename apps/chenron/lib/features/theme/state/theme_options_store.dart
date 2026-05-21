import "package:shared_preferences/shared_preferences.dart";
import "package:vibe/vibe.dart";

/// Persists per-theme user choices for the knobs declared via
/// [VibeTheme.settings].
///
/// Storage layout: each value lives at `theme.<themeId>.<optionKey>` so
/// themes never collide with one another. Bool settings store via
/// [SharedPreferences.setBool], enum/string settings via
/// [SharedPreferences.setString] (enums round-trip through their
/// [Enum.name]).
class ThemeOptionsStore {
  static String _keyFor(String themeId, String optionKey) =>
      "theme.$themeId.$optionKey";

  /// Loads the persisted values for [schema] under [themeId], falling
  /// back to each setting's [ThemeSetting.defaultValue] when nothing
  /// has been written yet.
  Future<Map<String, Object?>> load(
    String themeId,
    List<ThemeSetting<Object?>> schema,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, Object?> result = <String, Object?>{};
    for (final ThemeSetting<Object?> setting in schema) {
      final String storageKey = _keyFor(themeId, setting.key);
      switch (setting) {
        case BoolThemeSetting():
          result[setting.key] =
              prefs.getBool(storageKey) ?? setting.defaultValue;
        case EnumThemeSetting():
          final String? stored = prefs.getString(storageKey);
          result[setting.key] = stored ?? setting.defaultValue;
      }
    }
    return result;
  }

  /// Persists a single option under [themeId].
  ///
  /// Bools, strings, and enums (stored via [Enum.name]) are supported.
  /// Other types are ignored — callers must keep [value] in sync with
  /// the corresponding [ThemeSetting] type.
  Future<void> set(String themeId, String optionKey, Object? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String storageKey = _keyFor(themeId, optionKey);
    if (value is bool) {
      await prefs.setBool(storageKey, value);
    } else if (value is String) {
      await prefs.setString(storageKey, value);
    } else if (value is Enum) {
      await prefs.setString(storageKey, value.name);
    }
  }
}
