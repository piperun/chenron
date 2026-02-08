import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/src/core/id.dart";
import "package:app_logger/app_logger.dart";
import "package:drift/drift.dart";

extension UserConfigExtensions on ConfigDatabase {
  Future<UserConfigResultIds> createUserConfig(UserConfig userConfig) async {
    return transaction(() async {
      try {
        final String id = generateId();
        final insertConfig = UserConfigsCompanion.insert(
          id: id,
          darkMode: Value(userConfig.darkMode),
          archiveOrgS3AccessKey: Value(userConfig.archiveOrgS3AccessKey),
          archiveOrgS3SecretKey: Value(userConfig.archiveOrgS3SecretKey),
          copyOnImport: Value(userConfig.copyOnImport),
          defaultArchiveIs: Value(userConfig.defaultArchiveIs),
          defaultArchiveOrg: Value(userConfig.defaultArchiveOrg),
          selectedThemeType: Value(userConfig.selectedThemeType),
          timeDisplayFormat: Value(userConfig.timeDisplayFormat),
          itemClickAction: Value(userConfig.itemClickAction),
          selectedThemeKey: Value(userConfig.selectedThemeKey),
          cacheDirectory: Value(userConfig.cacheDirectory),
        );

        final userId = await _createUserConfigEntry(insertConfig);
        loggerGlobal.info(
          "UserConfigActionsCreate",
          "User config created successfully",
        );

        return UserConfigResultIds(userConfigId: userId.toString());
      } catch (e) {
        loggerGlobal.severe(
          "UserConfigActionsCreate",
          "Error creating user config: $e",
        );
        rethrow;
      }
    });
  }

  Future<String> _createUserConfigEntry(UserConfigsCompanion userConfig) async {
    final id = userConfig.id.value;
    await into(userConfigs).insert(userConfig);
    return id;
  }
}

extension BackupSettingsExtensions on ConfigDatabase {
  Future<BackupSettingsResultIds> createBackupSettings({
    required BackupSetting backupSetting,
    required String userConfigId,
  }) async {
    return transaction(() async {
      try {
        final backupId = generateId();
        final insertBackupSetting = BackupSettingsCompanion.insert(
          id: backupId,
          userConfigId: userConfigId,
          backupFilename: Value(backupSetting.backupFilename),
          backupPath: Value(backupSetting.backupPath),
          backupInterval: Value(backupSetting.backupInterval),
        );

        await _createBackupSettingsEntry(insertBackupSetting);
        loggerGlobal.info(
          "BackupSettingsCreate",
          "Backup settings created successfully",
        );

        return BackupSettingsResultIds(
            backupSettingsId: backupId, userConfigId: userConfigId);
      } catch (e) {
        loggerGlobal.severe(
          "BackupSettingsCreate",
          "Error creating backup settings: $e",
        );
        rethrow;
      }
    });
  }

  Future<String> _createBackupSettingsEntry(
      BackupSettingsCompanion backupSetting) async {
    final id = backupSetting.id.value;
    await into(backupSettings).insert(backupSetting);
    return id;
  }
}
