import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Service for persisting user's preferred display mode
class DisplayModePreference {
  static const String _key = "display_mode_preference";

  /// Get the user's saved display mode preference
  /// Returns DisplayMode.standard if no preference is saved
  static Future<DisplayMode> getDisplayMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);

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
  static Future<void> setDisplayMode(DisplayMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = _displayModeToString(mode);
    await prefs.setString(_key, value);
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
