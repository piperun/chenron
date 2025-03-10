import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/base_query_builder.dart";
import "package:chenron/database/schema/items_schema.dart";
import "package:drift/drift.dart";

class TagJoins implements RowJoins<Tags, Tag> {
  final AppDatabase db;
  TagJoins(this.db);

  @override
  Set<TableInfo> get table => {db.tags};
  @override
  List<Join> createJoins(Expression<String> baseJoinExpression) => [
        leftOuterJoin(db.metadataRecords,
            db.metadataRecords.itemId.equalsExp(baseJoinExpression)),
        leftOuterJoin(
            db.tags, db.tags.id.equalsExp(db.metadataRecords.metadataId)),
      ];

  @override
  Tag? readJoins(TypedResult? row) {
    if (row == null) return null;
    final tag = row.readTableOrNull(db.tags);

    return tag;
  }
}
