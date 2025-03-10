import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/id.dart";
import "package:chenron/database/extensions/insert_ext.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/models/created_ids.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart";

extension FolderExtensions on AppDatabase {
  Future<CreatedIds<Folder>> createFolder({
    required FolderInfo folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
  }) async {
    return transaction(() async {
      String? folderId;
      List<CreatedIds<Tag>>? createdTagIds;
      List<CreatedIds<Item>>? createdItemIds;
      try {
        if (folderInfo.title != "") {
          folderId = await _createFolderInfo(folderInfo);
        }
        if (tags != null) {
          createdTagIds = await _createFolderTags(folderId!, tags);
        }
        if (items != null) {
          createdItemIds = await _createFolderContent(folderId!, items);
        }
        return CreatedIds.folder(
          folderId: folderId,
          tags: createdTagIds,
          items: createdItemIds,
        );
      } catch (e) {
        loggerGlobal.severe("FolderActionsCreate", "Error adding folder: $e");
        rethrow;
      }
    });
  }

  Future<String> _createFolderInfo(FolderInfo folderInfo) async {
    String id = generateId();
    final newFolder = FoldersCompanion.insert(
      id: id,
      title: folderInfo.title,
      description: folderInfo.description,
    );
    await folders.insertOne(newFolder);
    return id;
  }

  Future<List<CreatedIds<Tag>>> _createFolderTags(
      String folderId, List<Metadata> tagInserts) async {
    List<CreatedIds<Tag>> tagResults = [];
    if (tagInserts.isEmpty) {
      return tagResults;
    }
    await batch((batch) async {
      tagResults = (await insertTags(batch, tagInserts, folderId));
    });
    return tagResults;
  }

  Future<List<CreatedIds<Item>>> _createFolderContent(
      String folderId, List<FolderItem> itemInserts) async {
    List<CreatedIds<Item>> itemResults = [];
    if (itemInserts.isEmpty) return itemResults;

    await batch((batch) async {
      itemResults = await insertFolderItems(
          batch: batch, folderId: folderId, itemInserts: itemInserts);
    });
    return itemResults;
  }
}
