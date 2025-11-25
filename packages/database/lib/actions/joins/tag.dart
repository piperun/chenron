import "package:database/database.dart";
import "package:database/extensions/base_query_builder.dart";
import "package:database/schema/items_schema.dart";
import "package:drift/drift.dart";

class TagJoins implements RowJoins<Tags, Tag> {
  final AppDatabase db;
  TagJoins(this.db);

  @override
  List<Join> createJoins(Expression<String> baseJoinExpression) => [
        leftOuterJoin(db.metadataRecords,
            db.metadataRecords.itemId.equalsExp(baseJoinExpression)),
        leftOuterJoin(
            db.tags, db.tags.id.equalsExp(db.metadataRecords.metadataId)),
      ];
}


