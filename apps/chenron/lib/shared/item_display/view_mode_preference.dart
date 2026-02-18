import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Service for persisting user's preferred view mode (grid / list)
class ViewModePreference {
  static const String _baseKey = "view_mode_preference";

  static String _getKey(String? context) {
    return context != null ? "${_baseKey}_$context" : _baseKey;
  }

  /// Get the user's saved view mode preference.
  ///
  /// [context] allows different view modes for different screens.
  /// Returns ViewMode.grid if no preference is saved.
  static Future<ViewMode> getViewMode({String? context}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(context);
    final value = prefs.getString(key);

    switch (value) {
      case "list":
        return ViewMode.list;
      case "grid":
      default:
        return ViewMode.grid;
    }
  }

  /// Save the user's view mode preference.
  static Future<void> setViewMode(ViewMode mode, {String? context}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(context);
    await prefs.setString(key, mode.name);
  }
}
