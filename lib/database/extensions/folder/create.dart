import "package:chenron/database/extensions/id.dart";
import "package:chenron/models/folder_results.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/database/database.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/database/extensions/insert_ext.dart";
import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart";

extension FolderExtensions on AppDatabase {
  Future<FolderResults> createFolder({
    required FolderInfo folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
  }) async {
    return transaction(() async {
      FolderResults results = FolderResults();
      try {
        if (folderInfo.title != "") {
          results.folderId = await _createFolderInfo(folderInfo);
        }
        if (tags != null) {
          results.tagIds = await _createFolderTags(results.folderId!, tags);
        }
        if (items != null) {
          results.itemIds =
              await _createFolderContent(results.folderId!, items);
        }
        return results;
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

  Future<List<TagResults>> _createFolderTags(
      String folderId, List<Metadata> tagInserts) async {
    List<TagResults> tagResults = [];
    if (tagInserts.isEmpty) {
      return tagResults;
    }
    await batch((batch) async {
      tagResults = (await insertTags(batch, tagInserts, folderId));
    });
    return tagResults;
  }

  Future<List<ItemResults>> _createFolderContent(
      String folderId, List<FolderItem> itemInserts) async {
    List<ItemResults> itemResults = [];
    if (itemInserts.isEmpty) return itemResults;

    await batch((batch) async {
      itemResults = await insertFolderItems(
          batch: batch, folderId: folderId, itemInserts: itemInserts);
    });
    return itemResults;
  }
}
