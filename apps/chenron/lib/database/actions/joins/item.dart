import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/base_query_builder.dart";
import "package:chenron/database/schema/items_schema.dart";
import "package:chenron/models/item.dart";
import "package:drift/drift.dart";

class ItemJoins implements RowJoins<Items, FolderItem> {
  final AppDatabase db;
  late final $MetadataRecordsTable itemMetadataRecords;
  late final $TagsTable itemTags;

  ItemJoins(this.db) {
    itemMetadataRecords = db.metadataRecords.createAlias('item_metadata_records');
    itemTags = db.tags.createAlias('item_tags');
  }

  @override
  List<Join> createJoins(Expression<String> relationId) => [
        leftOuterJoin(db.items, db.items.folderId.equalsExp(relationId)),
        leftOuterJoin(db.links, db.links.id.equalsExp(db.items.itemId)),
        leftOuterJoin(db.documents, db.documents.id.equalsExp(db.items.itemId)),
        leftOuterJoin(itemMetadataRecords, itemMetadataRecords.itemId.equalsExp(db.items.id)),
        leftOuterJoin(itemTags, itemTags.id.equalsExp(itemMetadataRecords.metadataId)),
      ];
}
