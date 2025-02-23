import "package:chenron/database/actions/relations/folder.dart";
import "package:chenron/database/actions/relations/link.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/base_query_builder.dart";
import "package:drift/drift.dart";

class RelationFactory<T> {
  final AppDatabase db;
  RelationFactory(this.db);

  RelationBuilder<T> getRelationBuilder(TableInfo table) {
    if (table == db.folders) {
      return FolderRelationBuilder(db) as RelationBuilder<T>;
    } else if (table == db.links) {
      return LinkRelationBuilder(db) as RelationBuilder<T>;
    } else {
      throw UnsupportedError("No join builder for table: ${table.entityName}");
    }
  }
}
