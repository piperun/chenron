import "package:database/main.dart";
import "package:database/models/item.dart";
import "package:database/src/core/builders/base_query_builder.dart";
import "package:database/schema/app_schema.dart";
import "package:drift/drift.dart";

class ItemJoins implements RowJoins<Items, FolderItem> {
  final AppDatabase db;
  late final $MetadataRecordsTable linkMetadata;
  late final $TagsTable linkTags;
  late final $FoldersTable nestedFolders;

  ItemJoins(this.db) {
    linkMetadata = db.metadataRecords.createAlias("link_metadata");
    linkTags = db.tags.createAlias("link_tags");
    nestedFolders = db.folders.createAlias("nested_folders");
  }

  @override
  List<Join> createJoins(Expression<String> relationId) => [
        leftOuterJoin(db.items, db.items.folderId.equalsExp(relationId)),
        leftOuterJoin(db.links, db.links.id.equalsExp(db.items.itemId)),
        leftOuterJoin(db.documents, db.documents.id.equalsExp(db.items.itemId)),
        leftOuterJoin(
            nestedFolders, nestedFolders.id.equalsExp(db.items.itemId)),
        // Load tags from the source link/document, not from item metadata
        leftOuterJoin(
            linkMetadata, linkMetadata.itemId.equalsExp(db.items.itemId)),
        leftOuterJoin(linkTags, linkTags.id.equalsExp(linkMetadata.metadataId)),
      ];
}
