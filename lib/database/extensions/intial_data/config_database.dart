import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/id.dart"; // For generateId
import "package:chenron/models/created_ids.dart";
import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart";

extension ConfigDatabaseInit on ConfigDatabase {
  Future<CreatedIds<UserConfig>> setupUserConfig() async {
    final userConfigCreatedId = await _setupUserConfigEntry();

    if (userConfigCreatedId.userConfigId != null) {
      await _setupBackupConfig(userConfigCreatedId.userConfigId!);
    }

    return userConfigCreatedId;
  }

  Future<CreatedIds<UserConfig>> _setupUserConfigEntry() async {
    try {
      final existingConfig = await (select(userConfigs)).getSingleOrNull();

      if (existingConfig == null) {
        final configId = generateId();

        await into(userConfigs).insert(UserConfigsCompanion.insert(
          id: configId,
          darkMode: const Value(false),
          copyOnImport: const Value(true),
          archiveEnabled: const Value(false),
          colorScheme: const Value(null),
          archiveOrgS3AccessKey: const Value(null),
          archiveOrgS3SecretKey: const Value(null),
        ));

        return CreatedIds<UserConfig>(primaryId: configId);
      }

      // Return existing config ID
      return CreatedIds<UserConfig>(primaryId: existingConfig.id);
    } catch (e) {
      loggerGlobal.severe(
          "SetupUpserConfigEntry", "Error in _setupUserConfigEntry: $e");
      rethrow;
    }
  }

  Future<CreatedIds<BackupSetting>> _setupBackupConfig(
      String userConfigId) async {
    try {
      final query = select(backupSettings)
        ..where((tbl) => tbl.userConfigId.equals(userConfigId));

      final existingConfig = await query.getSingleOrNull();

      if (existingConfig == null) {
        final backupId = generateId();

        await into(backupSettings).insert(BackupSettingsCompanion.insert(
          id: backupId,
          userConfigId: userConfigId,
          backupFilename: const Value(null),
          backupPath: const Value(null),
          backupInterval: const Value(null),
        ));

        return CreatedIds<BackupSetting>(primaryId: backupId);
      }

      return CreatedIds<BackupSetting>(primaryId: existingConfig.id);
    } catch (e) {
      loggerGlobal.severe(
          "SetupBackupConfig", "Error in _setupBackupConfig: $e");
      rethrow;
    }
  }
}
