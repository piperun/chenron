import "package:chenron/features/theme/model/theme_service_model.dart";

import "package:database/database.dart";
import "package:database/main.dart";
import "package:logger/logger.dart";

class ThemeServiceDB implements ThemeService {
  final ConfigDatabase _db;
  final UserConfigResult configData;

  ThemeServiceDB._({required ConfigDatabase database, required this.configData})
      : _db = database;

  static Future<ThemeServiceDB> init({required ConfigDatabase database}) async {
    UserConfigResult fetchedConfigId;
    try {
      loggerGlobal.info("ThemeService.create", "Fetching UserConfig...");

      final userConfig = await database.getUserConfig();

      if (userConfig != null) {
        fetchedConfigId = userConfig;
        loggerGlobal.info(
            "ThemeService.create", "UserConfig found, ID: $fetchedConfigId");
      } else {
        loggerGlobal.severe(
            "ThemeService.create", "UserConfig not found during creation.");
        throw StateError("UserConfig not found during ThemeService creation.");
      }
    } catch (error, stackTrace) {
      loggerGlobal.severe("ThemeService.create",
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
    try {
      return _db.removeUserTheme(id: themeId);
    } catch (error, stackTrace) {
      loggerGlobal.severe(
          "ThemeServiceDB", "Error removing theme: $error", error, stackTrace);
      rethrow;
    }
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
  Future<List<UserThemeResult>> getAllSavedThemes() async {
    try {
      return await _db.getAllUserThemes();
    } catch (error, stackTrace) {
      loggerGlobal.severe("ThemeServiceImpl", "Error getting all saved themes",
          error, stackTrace);

      return [];
    }
  }

  @override
  Future<Map<String, List<UserThemeResultIds>>> updateUserThemeSettings({
    required String configId,
    String? selectedThemeKey,
    ThemeType? selectedThemeType,
    bool? isDarkMode,
    CUD<UserTheme>? themeUpdates,
  }) async {
    Map<String, List<UserThemeResultIds>> updateResult = {};
    if (configId.isEmpty) {
      loggerGlobal.warning("ThemeServiceImpl",
          "updateUserThemeSettings called with empty configId.");
      throw ArgumentError("configId cannot be empty.");
    }

    try {
      updateResult = await _db.updateUserConfig(
        id: configId,
        selectedThemeKey: selectedThemeKey,
        selectedThemeType: selectedThemeType,
        darkMode: isDarkMode,
        themeUpdates: themeUpdates,
      );
      loggerGlobal.info("ThemeServiceImpl",
          "Updated theme settings for config ID: $configId");
    } catch (error, stackTrace) {
      loggerGlobal.severe(
          "ThemeServiceImpl",
          "Error updating theme settings for config ID: $configId",
          error,
          stackTrace);
      rethrow;
    }
    return updateResult;
  }

  /// Fetch a specific custom theme by its key.
  Future<UserThemeResult?> getThemeByKey(String themeKey) async {
    return _db.getUserTheme(themeKey: themeKey);
  }
}
