import "package:chenron/database/extensions/id.dart";
import "package:chenron/models/folder_results.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/database/extensions/insert_ext.dart";
import "package:drift/drift.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/actions/batch.dart";

extension FolderExtensions on AppDatabase {
  Future<void> updateFolder(String folderId,
      {String? title,
      String? description,
      CUD<Metadata>? tagUpdates,
      CUD<FolderItem>? itemUpdates}) {
    return batchOps((batch) async {
      if (title != null || description != null) {
        await _updateFolderInfo(folderId, title, description);
      }
      if (tagUpdates != null) {
        await _updateFolderTags(folderId, tagUpdates);
      }
      if (itemUpdates != null) {
        await _updateFolderContent(folderId, itemUpdates);
      }
    });
  }

  Future<int> _updateFolderInfo(
      String folderId, String? title, String? description) async {
    final folderUpdate = FoldersCompanion(
      title: title == null ? const Value.absent() : Value(title),
      description:
          description == null ? const Value.absent() : Value(description),
    );
    return (folders.update()..where((t) => t.id.equals(folderId)))
        .write(folderUpdate);
  }

  Future<void> _updateFolderTags(
      String folderId, CUD<Metadata> tagUpdates) async {
    if (tagUpdates.create.isNotEmpty) {
      await batch((batch) async {
        await insertTags(batch, tagUpdates.create, folderId);
      });
    }
    if (tagUpdates.update.isNotEmpty) {
      await batch((batch) async {
        for (final tagUpdate in tagUpdates.update) {
          batch.insert(
            mode: InsertMode.insertOrIgnore,
            onConflict: DoNothing(),
            metadataRecords,
            MetadataRecordsCompanion.insert(
              id: generateId(),
              typeId: tagUpdate.type.index,
              itemId: folderId,
              metadataId: tagUpdate.metadataId!,
            ),
          );
        }
      });
    }
    if (tagUpdates.remove.isNotEmpty) {
      await batch((batch) async {
        for (final tagRemove in tagUpdates.remove) {
          batch.deleteWhere(
              metadataRecords, (tbl) => tbl.metadataId.equals(tagRemove));
        }
      });
    }
  }

  Future<Map<String, List<ItemResults>>> _updateFolderContent(
      String folderId, CUD<FolderItem> itemUpdates) async {
    Map<String, List<ItemResults>> itemUpdateResults = {
      "create": [],
      "update": [],
      "remove": []
    };
    if (itemUpdates.create.isNotEmpty) {
      await batch((batch) async {
        itemUpdateResults["create"] = await insertFolderItems(
            batch: batch, folderId: folderId, itemInserts: itemUpdates.create);
      });
    }
    if (itemUpdates.update.isNotEmpty) {
      String id;
      await batch((batch) async {
        for (final itemUpdate in itemUpdates.update) {
          id = generateId();
          batch.insert(
            mode: InsertMode.insertOrIgnore,
            onConflict: DoNothing(),
            items,
            ItemsCompanion.insert(
              id: id,
              folderId: folderId,
              itemId: itemUpdate.itemId!,
              typeId: itemUpdate.type.index,
            ),
          );
          itemUpdateResults["update"]?.add(ItemResults(itemId: id));
        }
      });
    }
    if (itemUpdates.remove.isNotEmpty) {
      await batch((batch) async {
        for (final itemId in itemUpdates.remove) {
          batch.deleteWhere(
            items,
            (tbl) =>
                (tbl.itemId.equals(itemId)) & tbl.folderId.equals(folderId),
          );
          /*{ 
            final findItemId = tbl.itemId.equals(tagRemove.itemId);
            final findFolderId = tbl.folderId.equals(folderId);
            return findFolderId & findItemId;});
            */
          //(tbl) => tbl.folderId.equals(folderId));
          itemUpdateResults["update"]?.add(ItemResults(itemId: itemId));
        }
      });
    }
    return itemUpdateResults;
  }
}
