import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:database/main.dart";
import "package:chenron/utils/run_logged.dart";
import "package:signals/signals_flutter.dart";

class ConfigService {
  // Get the database handler via locator
  final ConfigDatabase _db =
      locator.get<Signal<ConfigDatabaseLifecycle>>().value.configDatabase;

  Future<UserConfigResult?> getUserConfig() {
    return runLoggedOr(
      tag: "ConfigService",
      operation: "Fetching user config",
      action: _db.getUserConfig,
      fallback: null,
    );
  }

  Future<List<UserThemeResult>> getAllUserThemes() {
    return runLoggedOr(
      tag: "ConfigService",
      operation: "Fetching all user themes",
      action: _db.getAllUserThemes,
      fallback: [],
    );
  }

  Future<BackupSetting?> getBackupSettings() {
    return runLoggedOr(
      tag: "ConfigService",
      operation: "Fetching backup settings",
      action: () async {
        final configResult = await _db.getUserConfig(
          includeOptions:
              const IncludeOptions({ConfigIncludes.backupSettings}),
        );
        return configResult?.backupSettings;
      },
      fallback: null,
    );
  }

  Future<void> updateBackupSettings({
    required String id,
    String? backupInterval,
    String? backupPath,
    bool clearInterval = false,
  }) {
    return runLogged(
      tag: "ConfigService",
      operation: "Updating backup settings",
      action: () => _db.updateBackupSettings(
        id: id,
        backupInterval: backupInterval,
        backupPath: backupPath,
        clearInterval: clearInterval,
      ),
    );
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
  }) {
    return runLogged(
      tag: "ConfigService",
      operation: "Updating user config for ID: $configId",
      action: () => _db.updateUserConfig(
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
      ),
    );
  }

  // --- Per-section updates ---
  //
  // The underlying [ConfigDatabase.updateUserConfig] treats `null` as
  // "don't touch this column", so we can write only the fields a
  // section owns. This lets the settings coordinator save dirty
  // sections independently without clobbering unrelated columns.

  Future<void> updateArchiveSection({
    required String configId,
    required bool defaultArchiveIs,
    required bool defaultArchiveOrg,
    required String? archiveOrgS3AccessKey,
    required String? archiveOrgS3SecretKey,
  }) {
    return runLogged(
      tag: "ConfigService",
      operation: "Updating archive section for ID: $configId",
      action: () => _db.updateUserConfig(
        id: configId,
        defaultArchiveIs: defaultArchiveIs,
        defaultArchiveOrg: defaultArchiveOrg,
        archiveOrgS3AccessKey: archiveOrgS3AccessKey,
        archiveOrgS3SecretKey: archiveOrgS3SecretKey,
      ),
    );
  }

  Future<void> updateDisplaySection({
    required String configId,
    required int timeDisplayFormat,
    required int itemClickAction,
    required String? cacheDirectory,
    required bool showDescription,
    required bool showImages,
    required bool showTags,
    required bool showCopyLink,
  }) {
    return runLogged(
      tag: "ConfigService",
      operation: "Updating display section for ID: $configId",
      action: () => _db.updateUserConfig(
        id: configId,
        timeDisplayFormat: timeDisplayFormat,
        itemClickAction: itemClickAction,
        cacheDirectory: cacheDirectory,
        showDescription: showDescription,
        showImages: showImages,
        showTags: showTags,
        showCopyLink: showCopyLink,
      ),
    );
  }
}
