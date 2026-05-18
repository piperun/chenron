import "package:app_logger/app_logger.dart";
import "package:database/config_database.dart";
import "package:database/models/created_ids.dart";
import "package:database/src/core/id.dart";
import "package:drift/drift.dart";

/// Defensive bootstrap helpers for the [ConfigDatabase].
///
/// The enum-table seeding (`setupConfigEnums()` and friends) that
/// used to live here was deleted in the v5 migration when the lookup
/// tables were replaced by `intEnum<T>()` columns.
extension ConfigDatabaseInit on ConfigDatabase {
  /// Ensure a user-config row exists. Creates one if missing; recovers
  /// from a [FormatException] by wiping and re-inserting (defensive
  /// against schema drift between launches).
  Future<UserConfigResultIds> setupUserConfig() async {
    final result = await _setupUserConfigEntry();
    if (result.userConfigId.isNotEmpty) {
      await _setupBackupConfig(result.userConfigId);
    }
    return result;
  }

  Future<UserConfigResultIds> _setupUserConfigEntry() async {
    try {
      final existing = await (select(userConfigs)).getSingleOrNull();
      if (existing != null) {
        return UserConfigResultIds(userConfigId: existing.id);
      }
      final id = generateId();
      await into(userConfigs).insert(UserConfigsCompanion.insert(
        id: id,
        darkMode: const Value(false),
        copyOnImport: const Value(true),
        archiveOrgS3AccessKey: const Value(null),
        archiveOrgS3SecretKey: const Value(null),
      ));
      return UserConfigResultIds(userConfigId: id);
    } on FormatException catch (e) {
      // Persisted row's shape doesn't match the current code; nuke and
      // recreate so the user isn't stuck with an unreadable config.
      loggerGlobal.warning(
          "ConfigDB", "Schema mismatch detected, recreating config: $e");
      await delete(userConfigs).go();
      final id = generateId();
      await into(userConfigs).insert(UserConfigsCompanion.insert(
        id: id,
        darkMode: const Value(false),
        copyOnImport: const Value(true),
        archiveOrgS3AccessKey: const Value(null),
        archiveOrgS3SecretKey: const Value(null),
      ));
      return UserConfigResultIds(userConfigId: id);
    } catch (e) {
      loggerGlobal.severe(
          "SetupUserConfigEntry", "Error in _setupUserConfigEntry: $e");
      rethrow;
    }
  }

  Future<BackupSettingsResultIds> _setupBackupConfig(
      String userConfigId) async {
    try {
      final query = select(backupSettings)
        ..where((tbl) => tbl.userConfigId.equals(userConfigId));
      final existing = await query.getSingleOrNull();
      if (existing != null) {
        return BackupSettingsResultIds(
          backupSettingsId: existing.id,
          userConfigId: existing.userConfigId,
        );
      }
      final id = generateId();
      await into(backupSettings).insert(BackupSettingsCompanion.insert(
        id: id,
        userConfigId: userConfigId,
        backupFilename: const Value(null),
        backupPath: const Value(null),
        backupInterval: const Value(null),
      ));
      return BackupSettingsResultIds(
          backupSettingsId: id, userConfigId: userConfigId);
    } catch (e) {
      loggerGlobal.severe(
          "SetupBackupConfig", "Error in _setupBackupConfig: $e");
      rethrow;
    }
  }
}
