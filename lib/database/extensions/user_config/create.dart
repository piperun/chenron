import "package:chenron/database/database.dart";
import "package:chenron/database/schema/user_config_schema.dart";
import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart";
import "package:cuid2/cuid2.dart";

extension UserConfigExtensions on ConfigDatabase {
  Future<void> createUserConfig(UserConfig userConfig) async {
    return transaction(() async {
      try {
        final insertConfig = UserConfigsCompanion.insert(
          id: cuidSecure(30),
          darkMode: Value(userConfig.darkMode),
          colorScheme: Value(userConfig.colorScheme),
          archiveOrgS3AccessKey: Value(userConfig.archiveOrgS3AccessKey),
          archiveOrgS3SecretKey: Value(userConfig.archiveOrgS3SecretKey),
        );

        await _createUserConfigEntry(insertConfig);
        loggerGlobal.info(
          "UserConfigActionsCreate",
          "User config created successfully",
        );
      } catch (e) {
        loggerGlobal.severe(
          "UserConfigActionsCreate",
          "Error creating user config: $e",
        );
        rethrow;
      }
    });
  }

  Future<int> _createUserConfigEntry(UserConfigsCompanion userConfig) async {
    return await into(userConfigs).insert(userConfig);
  }
}

extension BackupSettingsExtensions on ConfigDatabase {
  Future<void> createBackupSettings(BackupSetting backupSetting) async {
    return transaction(() async {
      try {
        final insertBackupSetting = BackupSettingsCompanion.insert(
          id: cuidSecure(30),
          backupFilename: Value(backupSetting.backupFilename),
          backupPath: Value(backupSetting.backupPath),
        );

        await _createBackupSettingsEntry(insertBackupSetting);
        loggerGlobal.info(
          "BackupSettingsCreate",
          "Backup settings created successfully",
        );
      } catch (e) {
        loggerGlobal.severe(
          "BackupSettingsCreate",
          "Error creating backup settings: $e",
        );
        rethrow;
      }
    });
  }

  Future<int> _createBackupSettingsEntry(
      BackupSettingsCompanion backupSetting) async {
    return await into(backupSettings).insert(backupSetting);
  }
}
