import "package:database/main.dart";

extension BackupSettingsReadExtensions on ConfigDatabase {
  Future<BackupSetting?> getBackupSettings({
    required String userConfigId,
  }) async {
    final query = select(backupSettings)
      ..where((tbl) => tbl.userConfigId.equals(userConfigId));
    return query.getSingleOrNull();
  }
}
