import "package:database/main.dart";
import "package:database/src/core/builders/base_query_builder.dart";
import "package:database/schema/app_schema.dart";
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
