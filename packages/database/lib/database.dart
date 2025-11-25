import "package:database/schema/user_config_schema.dart";
import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:database/schema/items_schema.dart";
import "package:database/extensions/intial_data/app_database.dart";
import "package:database/extensions/intial_data/config_database.dart";
import "package:basedir/directory.dart";

// Export IncludeOptions from shared patterns for backward compatibility
export "package:core/patterns/include_options.dart" show IncludeOptions;

part "database.g.dart";

enum AppDataInclude { items, tags }

enum ConfigIncludes { archiveSettings, backupSettings, userThemes, userConfig }

enum ThemeType { custom, system }

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
  MetadataTypes
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
  int get schemaVersion => 1;

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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Add itemClickAction column with default value 0 (Open Item)
          await migrator.addColumn(userConfigs, userConfigs.itemClickAction);
        }
      },
    );
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
