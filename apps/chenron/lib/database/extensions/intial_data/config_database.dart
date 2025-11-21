import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/id.dart"; // For generateId
import "package:chenron/models/created_ids.dart";
import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart";

extension ConfigDatabaseInit on ConfigDatabase {
  Future<UserConfigResultIds> setupUserConfig() async {
    final userConfigCreatedId = await _setupUserConfigEntry();

    if (userConfigCreatedId.userConfigId.isEmpty) {
      await _setupBackupConfig(userConfigCreatedId.userConfigId);
    }

    return userConfigCreatedId;
  }

  Future<UserConfigResultIds> _setupUserConfigEntry() async {
    try {
      final existingConfig = await (select(userConfigs)).getSingleOrNull();

      if (existingConfig == null) {
        final configId = generateId();

        await into(userConfigs).insert(UserConfigsCompanion.insert(
          id: configId,
          darkMode: const Value(false),
          copyOnImport: const Value(true),
          archiveOrgS3AccessKey: const Value(null),
          archiveOrgS3SecretKey: const Value(null),
        ));

        return UserConfigResultIds(userConfigId: configId);
      }

      // Return existing config ID
      return UserConfigResultIds(userConfigId: existingConfig.id);
    } on FormatException catch (e) {
      // Schema mismatch detected - likely missing column from old schema
      loggerGlobal.warning(
          "ConfigDB", "Schema mismatch detected, recreating config: $e");

      // Delete corrupted config and create a fresh one
      await delete(userConfigs).go();
      final configId = generateId();

      await into(userConfigs).insert(UserConfigsCompanion.insert(
        id: configId,
        darkMode: const Value(false),
        copyOnImport: const Value(true),
        archiveOrgS3AccessKey: const Value(null),
        archiveOrgS3SecretKey: const Value(null),
      ));

      return UserConfigResultIds(userConfigId: configId);
    } catch (e) {
      loggerGlobal.severe(
          "SetupUpserConfigEntry", "Error in _setupUserConfigEntry: $e");
      rethrow;
    }
  }

  Future<BackupSettingsResultIds> _setupBackupConfig(
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

        return BackupSettingsResultIds(
            backupSettingsId: backupId, userConfigId: userConfigId);
      }

      return BackupSettingsResultIds(
          backupSettingsId: existingConfig.id,
          userConfigId: existingConfig.userConfigId);
    } catch (e) {
      loggerGlobal.severe(
          "SetupBackupConfig", "Error in _setupBackupConfig: $e");
      rethrow;
    }
  }
}
