import 'package:chenron/database/models/user_config_models.dart';
import 'package:chenron/models/metadata.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:chenron/database/models/models.dart';
import 'package:chenron/models/item.dart';
//import 'package:logging/logging.dart';

part 'database.g.dart';

enum IdType { linkId, documentId, tagId, folderId }

typedef DeleteRelationRecord = ({String id, IdType idType});

extension IdTypeExtension on IdType {
  String get dbValue {
    switch (this) {
      case IdType.linkId:
        return 'link_id';
      case IdType.documentId:
        return 'document_id';
      case IdType.tagId:
        return 'tag_id';
      case IdType.folderId:
        return 'folder_id';
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
  final String _databaseName;

  AppDatabase(
      {QueryExecutor? queryExecutor,
      String? databaseName,
      bool setupOnInit = false})
      : _databaseName = databaseName ?? "my_database",
        super(_openConnection(databaseName: databaseName ?? "my_database")) {
    if (setupOnInit) {
      setupEnumTypes();
    }
  }

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection({String databaseName = "my_database"}) {
    // `driftDatabase` from `package:drift_flutter` stores the database in
    // `getApplicationDocumentsDirectory()`.
    return driftDatabase(name: databaseName);
  }
}

@DriftDatabase(tables: [
  UserConfig,
])
class ConfigDatabase extends _$ConfigDatabase {
  ConfigDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    // `driftDatabase` from `package:drift_flutter` stores the database in
    // `getApplicationDocumentsDirectory()`.
    return driftDatabase(name: 'config');
  }
}

extension DatabaseInit on AppDatabase {
  Future<void> setupEnumTypes() async {
    await _setupTypes<FolderItemType>(itemTypes, FolderItemType.values);
    await _setupTypes<MetadataTypeEnum>(metadataTypes, MetadataTypeEnum.values);
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
      case 'item_types':
        return ItemTypesCompanion.insert(
          id: Value(type.index + 1),
          name: type.name,
        );
      case 'metadata_types':
        return MetadataTypesCompanion.insert(
          id: Value(type.index + 1),
          name: type.name,
        );
      default:
        throw ArgumentError('Unsupported table: ${table.actualTableName}');
    }
  }
}

extension FindExtensions<Table extends HasResultSet, Row>
    on ResultSetImplementation<Table, Row> {
  Selectable<Row> findById(String id) {
    return select()
      ..where((row) {
        final idColumn = columnsByName['id'];

        if (idColumn == null) {
          throw ArgumentError.value(
              this, 'this', 'Must be a table with an id column');
        }

        if (idColumn.type != DriftSqlType.string) {
          throw ArgumentError('Column `id` is not an string');
        }

        return idColumn.equals(id);
      });
  }

  Selectable<Row> findByName(String columnName, dynamic value) {
    return select()
      ..where((row) {
        final formattedColumnName = columnName.replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        );
        final column = columnsByName[formattedColumnName];

        if (column == null) {
          throw ArgumentError.value(
              this, 'this', 'Must be a table with a $columnName column');
        }

        if (column.type != DriftSqlType.string) {
          throw ArgumentError('Column $columnName is not a string');
        }

        return column.equalsNullable(value);
      });
  }
}
