import "package:chenron/database/schema/user_config_schema.dart";
import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:chenron/database/schema/items_schema.dart";
import "package:chenron/database/extensions/intial_data/app_database.dart";
import "package:chenron/database/extensions/intial_data/config_database.dart";
import "package:chenron/utils/directory/directory.dart";

part "database.g.dart";

enum IncludeOptions { tags, items }

enum IdType { linkId, documentId, tagId, folderId }

typedef DeleteRelationRecord = ({String id, IdType idType});

extension IdTypeExtension on IdType {
  String get dbValue {
    switch (this) {
      case IdType.linkId:
        return "link_id";
      case IdType.documentId:
        return "document_id";
      case IdType.tagId:
        return "tag_id";
      case IdType.folderId:
        return "folder_id";
    }
  }
}

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
  }) : super(_openConnection(
            databaseName: databaseName ?? "chenron",
            customPath: customPath,
            debugMode: debugMode));

  void setup() async {
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
  BackupSettings,
])
class ConfigDatabase extends _$ConfigDatabase {
  bool setupOnInit;

  ConfigDatabase({
    QueryExecutor? queryExecutor,
    String? databaseName,
    this.setupOnInit = false,
    String? customPath,
  }) : super(_openConnection(customPath: customPath));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(
      {String databaseName = "config", String? customPath}) {
    // `driftDatabase` from `package:drift_flutter` stores the database in
    // `getApplicationDocumentsDirectory()`.
    Future<String> Function()? path;
    if (customPath != null) {
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

  void setup() async {
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
