import 'package:cuid2/cuid2.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:chenron/database/models/models.dart';
import 'package:chenron/database/models/relation/folder.dart';
import 'package:logging/logging.dart';

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
  FolderTags,
  FolderDocuments,
  FolderLinks,
  FolderTrees
])
class AppDatabase extends _$AppDatabase {
  //final Logger _logger = Logger('AppDatabase');
  final String _databaseName;

  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/getting-started/#open
  AppDatabase([QueryExecutor? e, String? databaseName])
      : _databaseName = databaseName ?? "my_database",
        super(_openConnection(databaseName: databaseName ?? "my_database"));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection({String databaseName = "my_database"}) {
    // `driftDatabase` from `package:drift_flutter` stores the database in
    // `getApplicationDocumentsDirectory()`.
    return driftDatabase(name: databaseName);
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

extension TagExtensions on AppDatabase {
  Future<String> addTag(String tagName) async {
    final existingTag = await (this.tags.select()
          ..where((t) => t.name.equals(tagName)))
        .getSingleOrNull();

    final String tagId = existingTag?.id ?? cuidSecure(30);

    if (existingTag == null) {
      await this.tags.insertOne(
          mode: InsertMode.insertOrIgnore,
          onConflict: DoNothing(),
          TagsCompanion.insert(
            id: tagId,
            name: tagName,
          ));
    }
    return tagId;
  }
}

extension InsertExtensions<T extends Table, Row> on TableInfo<T, Row> {
  static final _logger = Logger("Insert");
  Future<void> insertOnUnique(Insertable<Row> row) async {
    try {
      await this.attachedDatabase.into(this).insert(row,
          mode: InsertMode.insertOrIgnore, onConflict: DoNothing());
    } catch (e) {
      _logger.warning('Insert failed, likely due to existing entry: $e');
      return;
    }
  }
}

extension Relation<T extends Table, Row> on TableInfo<T, Row> {
  static final _logger = Logger("Relation");

  Future<void> insertRelation(Insertable<Row> relationModel) async {
    try {
      await this.attachedDatabase.into(this).insert(relationModel);
    } catch (e) {
      _logger.severe('Error inserting relation in ${this.actualTableName}: $e');
      return;
    }
  }

  Future<int> deleteRelation(List<DeleteRelationRecord> relations) async {
    try {
      return (this.attachedDatabase.delete(this)
            ..where((row) {
              return relations.fold<Expression<bool>>(
                const Constant(true),
                (condition, relation) {
                  final idColumn = columnsByName[relation.idType.dbValue]!;
                  if (idColumn.type != DriftSqlType.string) {
                    throw ArgumentError(
                        'Column `${relation.idType.dbValue}` is not a string');
                  }
                  return condition & idColumn.equals(relation.id);
                },
              );
            }))
          .go();
    } catch (e) {
      _logger.severe('Error deleting relation in ${this.actualTableName}: $e');
      return -1;
    }
  }
}
