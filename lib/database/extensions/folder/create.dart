import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/insert.dart";
import "package:chenron/database/extensions/id.dart";
import "package:chenron/database/extensions/insert_ext.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/models/created_ids.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart";

extension FolderExtensions on AppDatabase {
  Future<FolderResultIds> createFolder({
    required FolderDraft folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
  }) async {
    return transaction(() async {
      String? folderId;
      List<TagResultIds>? createdTagIds;
      List<ItemResultIds>? createdItemIds;
      try {
        if (folderInfo.title != "") {
          folderId = await _createFolderDraft(folderInfo);
        }
        if (tags != null) {
          createdTagIds = await _createFolderTags(folderId!, tags);
        }
        if (items != null) {
          createdItemIds = await _createFolderContent(folderId!, items);
        }
        if (folderId == null) {
          throw Exception("Folder ID is null");
        }
        return FolderResultIds(
          folderId: folderId,
          tagIds: createdTagIds,
          itemIds: createdItemIds,
        );
      } catch (e) {
        loggerGlobal.severe("FolderActionsCreate", "Error adding folder: $e");
        rethrow;
      }
    });
  }

  Future<String> _createFolderDraft(FolderDraft folderInfo) async {
    String id = generateId();
    final newFolder = FoldersCompanion.insert(
      id: id,
      title: folderInfo.title,
      description: folderInfo.description,
    );
    await folders.insertOne(newFolder);
    return id;
  }

  Future<List<TagResultIds>> _createFolderTags(
      String folderId, List<Metadata> tagInserts) async {
    if (tagInserts.isEmpty) return [];

    List<TagResultIds> tagResults = [];

    await batch((batch) async {
      tagResults = await insertTags(
        batch: batch,
        tagMetadata: tagInserts,
      );

      for (final tagResult in tagResults) {
        insertMetadataRelation(
          batch: batch,
          metadataId: tagResult.tagId,
          itemId: folderId,
          type: MetadataTypeEnum.tag,
        );
      }
    });

    return tagResults;
  }

  Future<List<ItemResultIds>> _createFolderContent(
      String folderId, List<FolderItem> itemInserts) async {
    List<ItemResultIds> itemResults = [];
    if (itemInserts.isEmpty) return itemResults;

    await batch((batch) async {
      itemResults = await insertFolderItems(
          batch: batch, folderId: folderId, itemInserts: itemInserts);
    });
    return itemResults;
  }
}
