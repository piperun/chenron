import "package:database/schema/user_config_schema.dart";
import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:database/schema/app_schema.dart";
import "package:database/extensions/intial_data/app_database.dart";
import "package:database/extensions/intial_data/config_database.dart";
import "package:basedir/directory.dart";
import "dart:io";
import "package:path/path.dart" as path;

// Export IncludeOptions from shared patterns for backward compatibility
export "package:core/patterns/include_options.dart" show IncludeOptions;

part "database.g.dart";

enum AppDataInclude { items, tags }

enum ConfigIncludes { archiveSettings, backupSettings, userThemes, userConfig }

enum ThemeType { custom, system }

enum TimeDisplayFormat { relative, absolute }

enum ItemClickAction { openItem, showDetails }

enum SeedType { none, primary, primaryAndSecondary, all }

enum IdType { linkId, documentId, tagId, folderId }

typedef DeleteRelationRecord = ({String id, IdType idType});

@DriftDatabase(tables: [
  Folders,
  Links,
  Documents,
  Tags,
  Items,
  ItemTypes,
  MetadataRecords,
  MetadataTypes,
  Statistics,
])
class AppDatabase extends _$AppDatabase {
  static const int idLength = 30;
  final bool setupOnInit;
  final bool debugMode;
  AppDatabase({
    QueryExecutor? queryExecutor,
    String? databaseName,
    this.setupOnInit = false,
    String? customPath,
    this.debugMode = false,
  }) : super(queryExecutor ??
            _openConnection(
                databaseName: databaseName ?? "chenron",
                customPath: customPath,
                debugMode: debugMode));

  Future<void> setup() async {
    if (setupOnInit) {
      await setupEnumTypes();
    }
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        if (setupOnInit) {
          await setupEnumTypes();
        }
        // Create triggers for auto-updating timestamps on new databases
        await _createUpdateTriggers();
      },
      onUpgrade: (migrator, from, to) async {
        // Migration from v1 to v2: Add Statistics table and updatedAt columns
        if (from < 2) {
          // Add updatedAt to Folders
          // Add updatedAt to Folders
          await customStatement(
              'ALTER TABLE folders ADD COLUMN updated_at TEXT NOT NULL DEFAULT \'1970-01-01T00:00:00Z\'');
          await customStatement(
              'UPDATE folders SET updated_at = strftime(\'%Y-%m-%dT%H:%M:%SZ\', \'now\')');

          // Add updatedAt to Documents
          await customStatement(
              'ALTER TABLE documents ADD COLUMN updated_at TEXT NOT NULL DEFAULT \'1970-01-01T00:00:00Z\'');
          await customStatement(
              'UPDATE documents SET updated_at = strftime(\'%Y-%m-%dT%H:%M:%SZ\', \'now\')');

          // Create Statistics table
          await migrator.createTable(statistics);

          // Create triggers for auto-updating timestamps
          await _createUpdateTriggers();
        }

        // Migration from v2 to v3: Refactor Documents for file-based storage
        if (from < 3) {
          // Add new columns for file metadata
          await customStatement(
              'ALTER TABLE documents ADD COLUMN mime_type TEXT NOT NULL DEFAULT "text/markdown"');
          await customStatement(
              'ALTER TABLE documents ADD COLUMN file_size INTEGER');
          await customStatement(
              'ALTER TABLE documents ADD COLUMN checksum TEXT');

          // Migrate existing documents: move content from 'path' column to files
          final existingDocs = await customSelect(
            'SELECT id, title, path FROM documents',
            readsFrom: {documents},
          ).get();

          for (final row in existingDocs) {
            final docId = row.read<String>('id');
            final content = row.read<String>('path'); // Old content stored here
            final relativePath = 'documents/$docId.md';

            // Write content to file
            final file = await _getDocumentFile(relativePath);
            await file.writeAsString(content);
            final size = await file.length();

            // Update database with file path
            await customStatement(
              'UPDATE documents SET path = ?, file_size = ? WHERE id = ?',
              [relativePath, size, docId],
            );
          }

          // Rename path column to file_path
          // SQLite doesn't support RENAME COLUMN before 3.25.0, so we recreate the table
          await customStatement('''
            CREATE TABLE documents_new (
              id TEXT PRIMARY KEY NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              title TEXT NOT NULL,
              file_path TEXT UNIQUE NOT NULL,
              mime_type TEXT NOT NULL,
              file_size INTEGER,
              checksum TEXT
            )
          ''');

          await customStatement('''
            INSERT INTO documents_new (id, created_at, updated_at, title, file_path, mime_type, file_size, checksum)
            SELECT id, created_at, updated_at, title, path, mime_type, file_size, checksum
            FROM documents
          ''');

          await customStatement('DROP TABLE documents');
          await customStatement(
              'ALTER TABLE documents_new RENAME TO documents');

          // Recreate index
          await customStatement(
              'CREATE INDEX document_title ON documents(title)');
        }
      },
    );
  }

  /// Helper to get document file for migration and file operations
  Future<File> _getDocumentFile(String relativePath) async {
    final baseDir = await getDefaultApplicationDirectory();
    final fullPath = path.join(baseDir.path, 'data', relativePath);
    final file = File(fullPath);
    await file.parent.create(recursive: true);
    return file;
  }

  /// Creates SQLite triggers to automatically update the updatedAt timestamp
  Future<void> _createUpdateTriggers() async {
    // Trigger for Folders table
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS update_folders_timestamp 
      AFTER UPDATE ON folders
      FOR EACH ROW
      WHEN NEW.updated_at = OLD.updated_at
      BEGIN
        UPDATE folders 
        SET updated_at = (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
        WHERE id = NEW.id;
      END
    ''');

    // Trigger for Documents table
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS update_documents_timestamp 
      AFTER UPDATE ON documents
      FOR EACH ROW
      WHEN NEW.updated_at = OLD.updated_at
      BEGIN
        UPDATE documents 
        SET updated_at = (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
        WHERE id = NEW.id;
      END
    ''');
  }

  static QueryExecutor _openConnection(
      {String databaseName = "chenron",
      String? customPath,
      bool debugMode = false}) {
    // In production, we use the default database path.
    // `driftDatabase` from `package:drift_flutter` stores the database in
    // `getApplicationDocumentsDirectory()`.
    Future<String> Function()? dbPath;
    if (debugMode) {
      dbPath = null;
    } else if (customPath != null) {
      dbPath = () async => customPath;
    } else {
      dbPath = () async => (await getDefaultApplicationDirectory()).path;
    }

    return driftDatabase(
        name: databaseName, native: DriftNativeOptions(databasePath: dbPath));
  }
}

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
  int get schemaVersion => 3;

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
      },
    );
  }

  /// Creates SQLite triggers to automatically update the updatedAt timestamp for config tables
  Future<void> _createConfigUpdateTriggers() async {
    // Trigger for UserConfigs table
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS update_user_configs_timestamp 
      AFTER UPDATE ON user_configs
      FOR EACH ROW
      WHEN NEW.updated_at = OLD.updated_at
      BEGIN
        UPDATE user_configs 
        SET updated_at = (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
        WHERE id = NEW.id;
      END
    ''');

    // Trigger for UserThemes table
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS update_user_themes_timestamp 
      AFTER UPDATE ON user_themes
      FOR EACH ROW
      WHEN NEW.updated_at = OLD.updated_at
      BEGIN
        UPDATE user_themes 
        SET updated_at = (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
        WHERE id = NEW.id;
      END
    ''');
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
        ));
  }

  Future<void> setup() async {
    if (setupOnInit) {
      await setupConfigEnums();
      await setupUserConfig();
    }
  }
}

extension FindExtensions<Table extends HasResultSet, Row>
    on ResultSetImplementation<Table, Row> {
  Selectable<Row> findById(String id) {
    return select()
      ..where((row) {
        final idColumn = columnsByName["id"];

        if (idColumn == null) {
          throw ArgumentError.value(
              this, "this", "Must be a table with an id column");
        }

        if (idColumn.type != DriftSqlType.string) {
          throw ArgumentError("Column `id` is not an string");
        }

        return idColumn.equals(id);
      });
  }

  Selectable<Row> findByName(String columnName, dynamic value) {
    return select()
      ..where((row) {
        final formattedColumnName = columnName.replaceAllMapped(
          RegExp(r"[A-Z]"),
          (match) => "_${match.group(0)!.toLowerCase()}",
        );
        final column = columnsByName[formattedColumnName];

        if (column == null) {
          throw ArgumentError.value(
              this, "this", "Must be a table with a $columnName column");
        }

        if (column.type != DriftSqlType.string) {
          throw ArgumentError("Column $columnName is not a string");
        }

        return column.equalsNullable(value);
      });
  }
}
