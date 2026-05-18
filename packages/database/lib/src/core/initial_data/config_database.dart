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
    await _repairLegacyEnumIndices();
    final result = await _setupUserConfigEntry();
    if (result.userConfigId.isNotEmpty) {
      await _setupBackupConfig(result.userConfigId);
    }
    return result;
  }

  /// The v5 migration originally did `column = column - 1` without
  /// clamping. A v3-era row whose FK was never set carried the int
  /// default 0; the migration turned that into -1 and intEnum then
  /// crashed at read with `RangeError: -1`. The migration itself is
  /// now clamped, but already-migrated databases still hold the -1.
  /// Repair them here on every startup — idempotent on healthy rows.
  Future<void> _repairLegacyEnumIndices() async {
    await customStatement(
        "UPDATE user_configs SET selected_theme_type = 0 WHERE selected_theme_type < 0");
    await customStatement(
        "UPDATE user_configs SET time_display_format = 0 WHERE time_display_format < 0");
    await customStatement(
        "UPDATE user_configs SET item_click_action = 0 WHERE item_click_action < 0");
    await customStatement(
        "UPDATE user_themes SET seed_type = 0 WHERE seed_type < 0");
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
