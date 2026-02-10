import "package:chenron/features/theme/model/theme_service_model.dart";
import "package:chenron/utils/run_logged.dart";

import "package:database/database.dart";
import "package:database/main.dart";
import "package:app_logger/app_logger.dart";

class ThemeServiceDB implements ThemeService {
  final ConfigDatabase _db;
  final UserConfigResult configData;

  ThemeServiceDB._({required ConfigDatabase database, required this.configData})
      : _db = database;

  static Future<ThemeServiceDB> init({required ConfigDatabase database}) async {
    UserConfigResult fetchedConfigId;
    try {
      loggerGlobal.info("ThemeServiceDB", "Fetching UserConfig...");

      final userConfig = await database.getUserConfig();

      if (userConfig != null) {
        fetchedConfigId = userConfig;
        loggerGlobal.info(
            "ThemeServiceDB", "UserConfig found, ID: $fetchedConfigId");
      } else {
        loggerGlobal.severe(
            "ThemeServiceDB", "UserConfig not found during creation.");
        throw StateError("UserConfig not found during ThemeService creation.");
      }
    } catch (error, stackTrace) {
      loggerGlobal.severe("ThemeServiceDB",
          "Failed to fetch configId: $error", error, stackTrace);
      rethrow;
    }

    return ThemeServiceDB._(database: database, configData: fetchedConfigId);
  }

  Future<List<UserThemeResultIds>> createTheme(
      {required List<UserTheme> themeData}) {
    return _db.createUserTheme(
        userConfigId: configData.data.id, themes: themeData);
  }

  Future<void> removeTheme(String themeId) {
    return runLogged(
      tag: "ThemeServiceDB",
      operation: "Removing theme: $themeId",
      action: () => _db.removeUserTheme(id: themeId),
    );
  }

  @override
  Future<void> changeThemeMode({required bool isDark}) async {
    await _db.updateUserConfig(
      id: configData.data.id,
      darkMode: isDark,
    );
  }

  @override
  Future<void> changeTheme(String newThemeKey, ThemeType themeType) async {
    await _db.updateUserConfig(
      id: configData.data.id,
      selectedThemeKey: newThemeKey,
      selectedThemeType: themeType,
    );
  }

  @override
  Future<UserThemeResult?> getCurrentTheme() async {
    final themeKey = configData.data.selectedThemeKey;
    if (themeKey == null) return null;
    return _db.getUserTheme(themeKey: themeKey);
  }

  @override
  Future<List<UserThemeResult>> getAllSavedThemes() {
    return runLoggedOr(
      tag: "ThemeServiceDB",
      operation: "Fetching all saved themes",
      action: _db.getAllUserThemes,
      fallback: [],
    );
  }

  @override
  Future<Map<String, List<UserThemeResultIds>>> updateUserThemeSettings({
    required String configId,
    String? selectedThemeKey,
    ThemeType? selectedThemeType,
    bool? isDarkMode,
    CUD<UserTheme>? themeUpdates,
  }) {
    if (configId.isEmpty) {
      loggerGlobal.warning("ThemeServiceDB",
          "updateUserThemeSettings called with empty configId.");
      throw ArgumentError("configId cannot be empty.");
    }

    return runLogged(
      tag: "ThemeServiceDB",
      operation: "Updating theme settings for config ID: $configId",
      action: () => _db.updateUserConfig(
        id: configId,
        selectedThemeKey: selectedThemeKey,
        selectedThemeType: selectedThemeType,
        darkMode: isDarkMode,
        themeUpdates: themeUpdates,
      ),
    );
  }

  /// Fetch a specific custom theme by its key.
  Future<UserThemeResult?> getThemeByKey(String themeKey) async {
    return _db.getUserTheme(themeKey: themeKey);
  }
}
