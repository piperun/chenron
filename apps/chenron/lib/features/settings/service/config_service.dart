import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/operations/config_file_handler.dart";
import "package:chenron/database/extensions/user_config/read.dart";
import "package:chenron/database/extensions/user_config/update.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/utils/logger.dart";
import "package:signals/signals_flutter.dart";

class ConfigService {
  // Get the database handler via locator
  final ConfigDatabase _db =
      locator.get<Signal<ConfigDatabaseFileHandler>>().value.configDatabase;

  Future<UserConfigResult?> getUserConfig() async {
    try {
      loggerGlobal.info("ConfigService", "Fetching user config...");
      final config = await _db.getUserConfig();
      loggerGlobal.info("ConfigService",
          "User config fetched successfully: ${config != null}");
      return config;
    } catch (e, s) {
      loggerGlobal.severe("ConfigService", "Error fetching user config", e, s);
      return null; // Or rethrow depending on desired error handling
    }
  }

  Future<List<UserThemeResult>> getAllUserThemes() async {
    try {
      loggerGlobal.info("ConfigService", "Fetching all user themes...");
      final themes =
          await _db.getAllUserThemes(); // Assuming this method exists
      loggerGlobal.info(
          "ConfigService", "Fetched ${themes.length} user themes.");
      return themes;
    } catch (e, s) {
      loggerGlobal.severe("ConfigService", "Error fetching user themes", e, s);
      return [];
    }
  }

  // Add methods to get predefined theme keys/names if needed for UI

  Future<void> updateUserConfig({
    required String configId,
    required bool defaultArchiveIs,
    required bool defaultArchiveOrg,
    required String? archiveOrgS3AccessKey,
    required String? archiveOrgS3SecretKey,
    required String? selectedThemeKey,
    required ThemeType selectedThemeType,
    required int timeDisplayFormat,
    required int itemClickAction,
    // Add other config fields as needed
  }) async {
    try {
      loggerGlobal.info(
          "ConfigService", "Updating user config for ID: $configId");
      await _db.updateUserConfig(
        id: configId,
        defaultArchiveIs: defaultArchiveIs,
        defaultArchiveOrg: defaultArchiveOrg,
        archiveOrgS3AccessKey: archiveOrgS3AccessKey,
        archiveOrgS3SecretKey: archiveOrgS3SecretKey,
        selectedThemeKey: selectedThemeKey,
        selectedThemeType: selectedThemeType,
        timeDisplayFormat: timeDisplayFormat,
        itemClickAction: itemClickAction,
        // Note: Theme CUD operations removed as draft logic is gone
      );
      loggerGlobal.info("ConfigService", "User config updated successfully.");
    } catch (e, s) {
      loggerGlobal.severe("ConfigService", "Error updating user config", e, s);
      rethrow; // Rethrow to let the controller handle UI feedback
    }
  }
}
