import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/src/features/user_config/handlers/user_config_create_vepr.dart";
import "package:database/src/features/backup_settings/handlers/backup_settings_create_vepr.dart";

extension UserConfigExtensions on ConfigDatabase {
  Future<UserConfigResultIds> createUserConfig(UserConfig userConfig) async {
    final operation = UserConfigCreateVEPR(this);
    return operation.run(userConfig);
  }
}

extension BackupSettingsExtensions on ConfigDatabase {
  Future<BackupSettingsResultIds> createBackupSettings({
    required BackupSetting backupSetting,
    required String userConfigId,
  }) async {
    final operation = BackupSettingsCreateVEPR(this);

    final BackupSettingsCreateInput input = (
      backupSetting: backupSetting,
      userConfigId: userConfigId,
    );

    return operation.run(input);
  }
}
