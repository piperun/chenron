import "package:database/schema/user_config_schema.dart";
import "package:database/src/core/initial_data/config_database.dart";
import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:basedir/directory.dart";

part "config_database.g.dart";

enum ConfigIncludes { archiveSettings, backupSettings, userThemes, userConfig }

enum ThemeType { custom, system }

enum TimeDisplayFormat { relative, absolute }

enum ItemClickAction { openItem, showDetails }

enum SeedType { none, primary, primaryAndSecondary, all }

@DriftDatabase(tables: [
  UserConfigs,
  UserThemes,
  BackupSettings,
  ThemeTypes,
  TimeDisplayFormats,
  ItemClickActions,
  SeedTypes,
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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        if (setupOnInit) {
          await setupConfigEnums();
        }
        // Create triggers for auto-updating timestamps on new databases
        await _createConfigUpdateTriggers();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Add itemClickAction column with default value 0 (Open Item)
          await migrator.addColumn(userConfigs, userConfigs.itemClickAction);
        }
        if (from < 3) {
          // Schema v3: Add timestamps and enum tables
          await migrator.addColumn(userConfigs, userConfigs.createdAt);
          await migrator.addColumn(userConfigs, userConfigs.updatedAt);
          await migrator.addColumn(userThemes, userThemes.createdAt);
          await migrator.addColumn(userThemes, userThemes.updatedAt);

          // Create enum tables
          await migrator.createTable(themeTypes);
          await migrator.createTable(timeDisplayFormats);
          await migrator.createTable(itemClickActions);
          await migrator.createTable(seedTypes);

          // Populate enum tables
          await setupConfigEnums();

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

  Future<void> setup() async {
    if (setupOnInit) {
      await setupConfigEnums();
      await setupUserConfig();
    }
  }
}
