import "package:database/database.dart";
import "package:database/main.dart";

abstract class ThemeService {
  Future<void> changeThemeMode({required bool isDark});

  Future<void> changeTheme(String newThemeKey, ThemeType themeType);

  /// Fetches the UserTheme object for the currently selected theme.
  /// Returns null if no theme is selected or config is missing.
  Future<UserThemeResult?> getCurrentTheme();

  /// Fetches all saved UserThemes from the database.
  /// Returns an empty list if none exist or an error occurs.
  Future<List<UserThemeResult>> getAllSavedThemes();

  /// Updates theme-related settings in the UserConfig.
  /// Requires the [configId] of the UserConfig to update.
  /// Allows updating [selectedThemeId], [isDarkMode], and performing
  /// Create/Update/Delete operations on [UserTheme]s via [themeUpdates].
  /// Fields set to null will not be updated in the database.
  Future<void> updateUserThemeSettings({
    required String configId,
    String? selectedThemeKey,
    ThemeType? selectedThemeType,
    bool? isDarkMode,
    CUD<UserTheme>? themeUpdates,
  });

  // Future<UserThemeResult> createTheme(UserTheme themeData);
  // Future<void> updateTheme(UserTheme themeData);
  // Future<void> deleteTheme(String themeId);
}
