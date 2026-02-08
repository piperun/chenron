import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/src/core/id.dart";

import "package:drift/drift.dart";

extension RelationHandler on AppDatabase {
  ItemResultIds insertItemRelation({
    required Batch batch,
    required String entityId,
    required String folderId,
    required FolderItemType type,
  }) {
    final String id = generateId();

    batch.insert(
      items,
      ItemsCompanion.insert(
        id: id,
        folderId: folderId,
        itemId: entityId,
        typeId: type.dbId,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    return CreatedIds.item(
      itemId: id,
      folderId: folderId,
      linkId: type == FolderItemType.link ? entityId : null,
      documentId: type == FolderItemType.document ? entityId : null,
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
        typeId: type.dbId,
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
