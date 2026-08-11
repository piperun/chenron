// `TableMigration` is Drift's required schema-rebuild API for these historical
// migrations. It is intentionally marked experimental upstream.
// ignore_for_file: experimental_member_use

import "package:database/models/enums.dart";
import "package:database/schema/user_config_schema.dart";
import "package:database/src/core/initial_data/config_database.dart";
import "package:database/src/core/time.dart";
import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:basedir/directory.dart";

export "package:database/models/enums.dart"
    show ThemeType, TimeDisplayFormat, ItemClickAction, SeedType;

part "config_database.g.dart";

enum ConfigIncludes { archiveSettings, backupSettings, userThemes, userConfig }

@DriftDatabase(tables: [
  UserConfigs,
  UserThemes,
  BackupSettings,
])
class ConfigDatabase extends _$ConfigDatabase {
  static const int idLength = 30;
  bool setupOnInit;
  final bool debugMode;

  ConfigDatabase({
    QueryExecutor? queryExecutor,
    String? databaseName,
    this.setupOnInit = false,
    String? customPath,
    this.debugMode = false,
  }) : super(queryExecutor ??
            _openConnection(
                databaseName: databaseName ?? "config",
                customPath: customPath,
                debugMode: debugMode));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        // Create triggers for auto-updating timestamps on new databases
        await _createConfigUpdateTriggers();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Add itemClickAction column with default value 0 (Open Item)
          await migrator.addColumn(userConfigs, userConfigs.itemClickAction);
        }
        if (from < 3) {
          // Schema v3: Add timestamps + enum lookup tables (removed in v5)
          await migrator.addColumn(userConfigs, userConfigs.createdAt);
          await migrator.addColumn(userConfigs, userConfigs.updatedAt);
          await migrator.addColumn(userThemes, userThemes.createdAt);
          await migrator.addColumn(userThemes, userThemes.updatedAt);

          // Create triggers for auto-updating timestamps
          await _createConfigUpdateTriggers();
        }
        if (from < 4) {
          // Schema v4: Add viewer display preference columns
          await migrator.addColumn(
              userConfigs, userConfigs.showDescription);
          await migrator.addColumn(userConfigs, userConfigs.showImages);
          await migrator.addColumn(userConfigs, userConfigs.showTags);
          await migrator.addColumn(userConfigs, userConfigs.showCopyLink);
        }

        // v4 -> v5: replace enum lookup tables with intEnum<T>(). Existing
        // values were 1-based (autoincrement); intEnum is 0-based.
        if (from < 5) {
          // Be defensive: a v3+ database has the lookup tables and
          // 1-based values. A database that started at v5 (e.g. a fresh
          // install in test) doesn't need the value shift.
          final hasLegacyTables = await customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name IN ('theme_types','time_display_formats',"
            "'item_click_actions','seed_types')",
          ).get();
          if (hasLegacyTables.isNotEmpty) {
            // Clamp at 0: a v3-era row that never had its FK set kept the
            // default int value 0, which wasn't a valid lookup-table id
            // (those were 1-indexed autoincrement). Naively subtracting
            // one produces -1, which intEnum then crashes on at read.
            await customStatement(
                "UPDATE user_configs SET selected_theme_type = MAX(0, selected_theme_type - 1)");
            await customStatement(
                "UPDATE user_configs SET time_display_format = MAX(0, time_display_format - 1)");
            await customStatement(
                "UPDATE user_configs SET item_click_action = MAX(0, item_click_action - 1)");
            await customStatement(
                "UPDATE user_themes SET seed_type = MAX(0, seed_type - 1)");
            await customStatement("DROP TABLE IF EXISTS theme_types");
            await customStatement(
                "DROP TABLE IF EXISTS time_display_formats");
            await customStatement("DROP TABLE IF EXISTS item_click_actions");
            await customStatement("DROP TABLE IF EXISTS seed_types");
          }
        }

        // v5 -> v6: standardize every stored timestamp to canonical UTC
        // ISO-8601 millisecond text (`YYYY-MM-DDTHH:MM:SS.fffZ`), matching
        // the app DB. The columns defaulted to SQLite's CURRENT_TIMESTAMP
        // (space-separated, whole-second), and the update triggers stamped
        // seconds (`%S`) — both diverge from canonical.
        if (from < 6) {
          // (A) Rebuild every table whose live DDL must match the v6 schema.
          //     userConfigs/userThemes pick up the new strftime default;
          //     backupSettings is rebuilt so its DDL is regenerated from the
          //     current schema definition (rows copy verbatim in all cases).
          await migrator.alterTable(TableMigration(userConfigs));
          await migrator.alterTable(TableMigration(userThemes));
          await migrator.alterTable(TableMigration(backupSettings));

          // (B) Normalize existing values. The `<>` guard is idempotent —
          //     already-canonical rows are skipped, so re-running is a no-op.
          await _normalizeConfigTimestampColumns(const {
            "user_configs": ["created_at", "updated_at"],
            "user_themes": ["created_at", "updated_at"],
            "backup_settings": ["last_backup_timestamp"],
          });

          // (C) Rebuild the update triggers at millisecond precision.
          await customStatement(
              "DROP TRIGGER IF EXISTS update_user_configs_timestamp");
          await customStatement(
              "DROP TRIGGER IF EXISTS update_user_themes_timestamp");
          await _createConfigUpdateTriggers();
        }
      },
    );
  }

  /// Rewrites every listed DateTime column to canonical UTC ISO-8601
  /// millisecond text. The `<>` guard makes each statement idempotent.
  Future<void> _normalizeConfigTimestampColumns(
      Map<String, List<String>> tableColumns) async {
    const fmt = "strftime('%Y-%m-%dT%H:%M:%fZ', %COL%)";
    for (final entry in tableColumns.entries) {
      final table = entry.key;
      for (final col in entry.value) {
        final canonical = fmt.replaceAll("%COL%", col);
        await customStatement(
          "UPDATE $table SET $col = $canonical "
          "WHERE $col IS NOT NULL AND $col <> $canonical",
        );
      }
    }
  }

  /// Creates SQLite triggers to automatically update the updatedAt timestamp
  /// for config tables.
  ///
  /// Stamps canonical UTC ISO-8601 millisecond text (`%f`, matching the app
  /// DB triggers and column defaults). Seconds precision (`%S`) would collapse
  /// two edits to the same row within one second to an identical timestamp,
  /// which the `WHEN NEW.updated_at = OLD.updated_at` guard then suppresses.
  Future<void> _createConfigUpdateTriggers() async {
    // Trigger for UserConfigs table
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS update_user_configs_timestamp
      AFTER UPDATE ON user_configs
      FOR EACH ROW
      WHEN NEW.updated_at = OLD.updated_at
      BEGIN
        UPDATE user_configs
        SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
        WHERE id = NEW.id;
      END
    """);

    // Trigger for UserThemes table
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS update_user_themes_timestamp
      AFTER UPDATE ON user_themes
      FOR EACH ROW
      WHEN NEW.updated_at = OLD.updated_at
      BEGIN
        UPDATE user_themes
        SET updated_at = (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
        WHERE id = NEW.id;
      END
    """);
  }

  static QueryExecutor _openConnection(
      {String databaseName = "config",
      String? customPath,
      bool debugMode = false}) {
    // `driftDatabase` from `package:drift_flutter` stores the database in
    // `getApplicationDocumentsDirectory()`.
    Future<String> Function()? path;
    if (debugMode) {
      path = null;
    } else if (customPath != null) {
      path = () async => customPath;
    } else {
      path = () async => (await getDefaultApplicationDirectory()).path;
    }
    // Like AppDatabase, this runs on its own dedicated worker isolate
    // (drift_flutter default `shareAcrossIsolates: false` →
    // `NativeDatabase.createBackgroundConnection`, readPool: 0): one worker,
    // one connection, serialized single-writer access. The config DB is its
    // own SQLite file and must NOT share a connection with the app DB.
    //
    // INVARIANT: do not set `shareAcrossIsolates: true`, add a read pool, or
    // open this file from a second isolate without revisiting the
    // single-writer guarantee. Keep `setup` capture-free — it crosses the
    // isolate boundary.
    return driftDatabase(
        name: databaseName,
        native: DriftNativeOptions(
          databasePath: path,
          setup: (db) {
            db.execute("PRAGMA journal_mode=WAL;");
          },
        ));
  }

  /// Post-creation hook. Ensures a user-config row exists (creating
  /// one if missing, recovering it if the persisted schema doesn't
  /// match the current code's expectations).
  ///
  /// Enum-table seeding lives in [migration]'s `onCreate` /
  /// `onUpgrade` — it's no longer redone here on every launch.
  Future<void> setup() async {
    if (setupOnInit) {
      await setupUserConfig();
    }
  }
}
