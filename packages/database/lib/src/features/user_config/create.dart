import "package:database/database.dart";
import "package:database/src/core/handlers/run_vepr.dart";
import "package:database/src/core/id.dart";
import "package:drift/drift.dart";

extension UserConfigExtensions on ConfigDatabase {
  Future<UserConfigResultIds> createUserConfig(UserConfig userConfig) {
    return runVepr<String, void, UserConfigResultIds>(
      logSource: "createUserConfig",
      execute: () async {
        final id = generateId();
        await into(userConfigs).insert(UserConfigsCompanion.insert(
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
        ));
        return id;
      },
      process: (_) async {},
      build: (id, _) => UserConfigResultIds(userConfigId: id),
    );
  }
}

extension BackupSettingsExtensions on ConfigDatabase {
  Future<BackupSettingsResultIds> createBackupSettings({
    required BackupSetting backupSetting,
    required String userConfigId,
  }) {
    return runVepr<String, void, BackupSettingsResultIds>(
      logSource: "createBackupSettings",
      validate: () {
        if (userConfigId.trim().isEmpty) {
          throw ArgumentError("userConfigId cannot be empty.");
        }
      },
      execute: () async {
        final id = generateId();
        await into(backupSettings).insert(BackupSettingsCompanion.insert(
          id: id,
          userConfigId: userConfigId,
          backupFilename: Value(backupSetting.backupFilename),
          backupPath: Value(backupSetting.backupPath),
          backupInterval: Value(backupSetting.backupInterval),
        ));
        return id;
      },
      process: (_) async {},
      build: (id, _) => BackupSettingsResultIds(
        backupSettingsId: id,
        userConfigId: userConfigId,
      ),
    );
  }
}
