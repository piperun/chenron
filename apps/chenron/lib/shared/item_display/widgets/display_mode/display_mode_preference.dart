import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Service for persisting user's preferred display mode
class DisplayModePreference {
  static const String _baseKey = "display_mode_preference";

  /// Get the storage key for a specific context
  static String _getKey(String? context) {
    return context != null ? "${_baseKey}_$context" : _baseKey;
  }

  /// Get the user's saved display mode preference
  /// 
  /// [context] allows different display modes for different screens.
  /// Example: context: 'viewer' vs context: 'folder_viewer'
  /// 
  /// Returns DisplayMode.standard if no preference is saved
  static Future<DisplayMode> getDisplayMode({String? context}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(context);
    final value = prefs.getString(key);

    switch (value) {
      case "compact":
        return DisplayMode.compact;
      case "extended":
        return DisplayMode.extended;
      case "standard":
      default:
        return DisplayMode.standard;
    }
  }

  /// Save the user's display mode preference
  /// 
  /// [context] allows different display modes for different screens.
  /// Example: context: 'viewer' vs context: 'folder_viewer'
  static Future<void> setDisplayMode(DisplayMode mode, {String? context}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(context);
    final value = _displayModeToString(mode);
    await prefs.setString(key, value);
  }

  /// Convert DisplayMode to string for storage
  static String _displayModeToString(DisplayMode mode) {
    switch (mode) {
      case DisplayMode.compact:
        return "compact";
      case DisplayMode.standard:
        return "standard";
      case DisplayMode.extended:
        return "extended";
    }
  }
}
