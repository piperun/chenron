import "package:database/models/enums.dart";
import "package:database/schema/user_config_schema.dart";
import "package:database/src/core/initial_data/config_database.dart";
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
  int get schemaVersion => 5;

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
      },
    );
  }

  /// Creates SQLite triggers to automatically update the updatedAt timestamp for config tables
  Future<void> _createConfigUpdateTriggers() async {
    // Trigger for UserConfigs table
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS update_user_configs_timestamp
      AFTER UPDATE ON user_configs
      FOR EACH ROW
      WHEN NEW.updated_at = OLD.updated_at
      BEGIN
        UPDATE user_configs
        SET updated_at = (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
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
        SET updated_at = (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
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
