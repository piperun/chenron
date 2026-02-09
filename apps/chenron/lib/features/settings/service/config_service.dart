import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:database/main.dart";
import "package:app_logger/app_logger.dart";
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

  Future<BackupSetting?> getBackupSettings() async {
    try {
      final configResult = await _db.getUserConfig(
        includeOptions:
            const IncludeOptions({ConfigIncludes.backupSettings}),
      );
      return configResult?.backupSettings;
    } catch (e, s) {
      loggerGlobal.severe(
          "ConfigService", "Error fetching backup settings", e, s);
      return null;
    }
  }

  Future<void> updateBackupSettings({
    required String id,
    String? backupInterval,
    String? backupPath,
    bool clearInterval = false,
  }) async {
    try {
      await _db.updateBackupSettings(
        id: id,
        backupInterval: backupInterval,
        backupPath: backupPath,
        clearInterval: clearInterval,
      );
      loggerGlobal.info(
          "ConfigService", "Backup settings updated successfully.");
    } catch (e, s) {
      loggerGlobal.severe(
          "ConfigService", "Error updating backup settings", e, s);
      rethrow;
    }
  }

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
    String? cacheDirectory,
    required bool showDescription,
    required bool showImages,
    required bool showTags,
    required bool showCopyLink,
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
        cacheDirectory: cacheDirectory,
        showDescription: showDescription,
        showImages: showImages,
        showTags: showTags,
        showCopyLink: showCopyLink,
      );
      loggerGlobal.info("ConfigService", "User config updated successfully.");
    } catch (e, s) {
      loggerGlobal.severe("ConfigService", "Error updating user config", e, s);
      rethrow;
    }
  }
}
