import "package:database/database.dart";
import "package:database/src/core/id.dart";

import "package:drift/drift.dart";

extension RelationHandler on AppDatabase {
  ItemResultIds insertItemRelation({
    required Batch batch,
    required String itemId,
    required String folderId,
    required FolderItemType type,
  }) {
    final String id = generateId();

    batch.insert(
      items,
      ItemsCompanion.insert(
        id: id,
        folderId: folderId,
        itemId: itemId,
        typeId: type,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    return CreatedIds.item(
      itemId: id,
      folderId: folderId,
      linkId: type == FolderItemType.link ? itemId : null,
      documentId: type == FolderItemType.document ? itemId : null,
    ) as ItemResultIds;
  }

  MetadataResultIds insertMetadataRelation({
    required Batch batch,
    required String itemId,
    required String metadataId,
    required MetadataTypeEnum type,
    String? value,
  }) {
    final String id = generateId();

    batch.insert(
      metadataRecords,
      MetadataRecordsCompanion.insert(
        id: id,
        typeId: type,
        itemId: itemId,
        metadataId: metadataId,
        value: Value(value),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    return CreatedIds.metadata(
      metadataId: id,
      itemId: itemId,
    ) as MetadataResultIds;
  }
}
