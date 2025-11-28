import 'package:database/main.dart';
import 'package:database/models/created_ids.dart';
import 'package:database/src/core/id.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';

extension ConfigDatabaseInit on ConfigDatabase {
  Future<void> setupConfigEnums() async {
    await _setupTypes<ThemeType>(themeTypes, ThemeType.values);
    await _setupTypes<TimeDisplayFormat>(
        timeDisplayFormats, TimeDisplayFormat.values);
    await _setupTypes<ItemClickAction>(
        itemClickActions, ItemClickAction.values);
    await _setupTypes<SeedType>(seedTypes, SeedType.values);
  }

  Future<void> _setupTypes<T extends Enum>(
      TableInfo table, List<T> enumValues) async {
    for (var type in enumValues) {
      final companion = _factoryCompanion(table, type);
      await into(table).insertOnConflictUpdate(companion);
    }
  }

  Insertable _factoryCompanion(TableInfo table, Enum type) {
    switch (table.actualTableName) {
      case "theme_types":
        return ThemeTypesCompanion.insert(
          id: Value(type.index),
          name: type.name,
        );
      case "time_display_formats":
        return TimeDisplayFormatsCompanion.insert(
          id: Value(type.index),
          name: type.name,
        );
      case "item_click_actions":
        return ItemClickActionsCompanion.insert(
          id: Value(type.index),
          name: type.name,
        );
      case "seed_types":
        return SeedTypesCompanion.insert(
          id: Value(type.index),
          name: type.name,
        );
      default:
        throw ArgumentError("Unsupported table: ${table.actualTableName}");
    }
  }

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
