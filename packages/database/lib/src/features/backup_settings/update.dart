import "package:database/main.dart";
import "package:drift/drift.dart";

extension BackupSettingsUpdateExtensions on ConfigDatabase {
  Future<void> updateBackupSettings({
    required String id,
    String? backupInterval,
    String? backupPath,
    DateTime? lastBackupTimestamp,
    bool clearInterval = false,
  }) async {
    final companion = BackupSettingsCompanion(
      backupInterval: clearInterval
          ? const Value(null)
          : (backupInterval != null
              ? Value(backupInterval)
              : const Value.absent()),
      backupPath: backupPath != null
          ? (backupPath.isEmpty ? const Value(null) : Value(backupPath))
          : const Value.absent(),
      lastBackupTimestamp: lastBackupTimestamp != null
          ? Value(lastBackupTimestamp)
          : const Value.absent(),
    );

    await (update(backupSettings)..where((tbl) => tbl.id.equals(id)))
        .write(companion);
  }
}
