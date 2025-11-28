import "package:database/extensions/folder/insert.dart";
import "package:database/extensions/insert_ext.dart";
import "package:drift/drift.dart";
import "package:database/database.dart";
import "package:database/actions/batch.dart";

extension FolderExtensions on AppDatabase {
  Future<
      (
        FolderResultIds,
        Map<String, List<MetadataResultIds>>,
        Map<String, List<ItemResultIds>>,
      )> updateFolder(
    String folderId, {
    String? title,
    String? description,
    Value<int?>? color,
    CUD<Metadata>? tagUpdates,
    CUD<FolderItem>? itemUpdates,
  }) async {
    FolderResultIds folderResultIds = FolderResultIds(folderId: folderId);
    Map<String, List<MetadataResultIds>> cudTagIds = {};
    Map<String, List<ItemResultIds>> cudItemIds = {};
    await batchOps((batch) async {
      if (title != null || description != null || color != null) {
        folderResultIds =
            await _updateFolderDraft(folderId, title, description, color);
      }
      if (tagUpdates != null) {
        cudTagIds = await _updateFolderTags(folderId, tagUpdates);
      }
      if (itemUpdates != null) {
        cudItemIds = await _updateFolderContent(folderId, itemUpdates);
      }
    });
    return (folderResultIds, cudTagIds, cudItemIds);
  }

  Future<FolderResultIds> _updateFolderDraft(String folderId, String? title,
      String? description, Value<int?>? color) async {
    final folderUpdate = FoldersCompanion(
      title: title == null ? const Value.absent() : Value(title),
      description:
          description == null ? const Value.absent() : Value(description),
      color: color ?? const Value.absent(),
    );
    await (folders.update()..where((t) => t.id.equals(folderId)))
        .write(folderUpdate);

    return FolderResultIds(folderId: folderId);
  }

  Future<Map<String, List<MetadataResultIds>>> _updateFolderTags(
      String folderId, CUD<Metadata> tagUpdates) async {
    final Map<String, List<MetadataResultIds>> tagUpdateResults = {
      "create": [],
      "update": [],
      "remove": []
    };
    if (tagUpdates.create.isNotEmpty) {
      await batch((batch) async {
        // First create/get tags
        final tagResults = await insertTags(
          batch: batch,
          tagMetadata: tagUpdates.create,
        );

        // Then create relations between tags and folder
        for (final TagResultIds tagResult in tagResults) {
          tagUpdateResults["create"]!.add(insertMetadataRelation(
            batch: batch,
            itemId: folderId,
            metadataId: tagResult.tagId,
            type: MetadataTypeEnum.tag,
          ));
        }
      });
    }

    // Update existing tag relations
    if (tagUpdates.update.isNotEmpty) {
      await batch((batch) async {
        for (final tagUpdate in tagUpdates.update) {
          if (tagUpdate.metadataId != null) {
            tagUpdateResults["update"]?.add(insertMetadataRelation(
              batch: batch,
              itemId: folderId,
              metadataId: tagUpdate.metadataId!,
              type: MetadataTypeEnum.tag,
              value: tagUpdate.value,
            ));
          }
        }
      });
    }

    // Remove tag relations
    if (tagUpdates.remove.isNotEmpty) {
      await batch((batch) async {
        for (final tagId in tagUpdates.remove) {
          batch.deleteWhere(
            metadataRecords,
            (tbl) =>
                tbl.metadataId.equals(tagId) &
                tbl.itemId.equals(folderId) &
                tbl.typeId.equals(MetadataTypeEnum.tag.index),
          );
        }
      });
    }
    return tagUpdateResults;
  }

  Future<Map<String, List<ItemResultIds>>> _updateFolderContent(
      String folderId, CUD<FolderItem> itemUpdates) async {
    final Map<String, List<ItemResultIds>> itemUpdateResults = {
      "create": [],
      "update": [],
      "remove": []
    };

    // Create new items
    if (itemUpdates.create.isNotEmpty) {
      await batch((batch) async {
        final List<ItemResultIds> createdItems = await insertFolderItems(
          batch: batch,
          folderId: folderId,
          itemInserts: itemUpdates.create,
        );
        itemUpdateResults["create"] = createdItems;
      });
    }

    // Update existing items
    if (itemUpdates.update.isNotEmpty) {
      await batch((batch) async {
        for (final itemUpdate in itemUpdates.update) {
          if (itemUpdate.itemId != null) {
            final ItemResultIds relation = insertItemRelation(
              batch: batch,
              entityId: itemUpdate.itemId!,
              folderId: folderId,
              type: itemUpdate.type,
            );
            itemUpdateResults["update"]?.add(relation);
          }
        }
      });
    }

    // Remove items
    if (itemUpdates.remove.isNotEmpty) {
      await batch((batch) async {
        for (final itemId in itemUpdates.remove) {
          batch.deleteWhere(
            items,
            (tbl) => tbl.itemId.equals(itemId) & tbl.folderId.equals(folderId),
          );
          itemUpdateResults["remove"]
              ?.add(ItemResultIds(itemId: itemId, folderId: folderId));
        }
      });
    }

    return itemUpdateResults;
  }
}
