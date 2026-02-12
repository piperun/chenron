import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/cud.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/src/core/id.dart";
import "package:database/src/features/folder/handlers/folder_update_vepr.dart";
import "package:database/src/features/tag/create.dart";
import "package:app_logger/app_logger.dart";
import "package:drift/drift.dart";

extension FolderUpdateExtensions on AppDatabase {
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
    final operation = FolderUpdateVEPR(this);

    final FolderUpdateInput input = (
      folderId: folderId,
      title: title,
      description: description,
      color: color,
      tagUpdates: tagUpdates,
      itemUpdates: itemUpdates,
    );

    return operation.run(input);
  }

  /// Adds tags to an existing folder.
  Future<List<String>> addTagsToFolder({
    required String folderId,
    required List<Metadata> tags,
  }) async {
    return transaction(() async {
      try {
        loggerGlobal.fine(
            "FolderUpdate", "Adding ${tags.length} tags to folder $folderId");

        final folderExists = await (select(folders)
              ..where((f) => f.id.equals(folderId)))
            .getSingleOrNull();
        if (folderExists == null) {
          throw ArgumentError("Folder with ID $folderId not found.");
        }

        final List<String> addedTagIds = [];

        for (var tag in tags) {
          final existingMetadata = await (select(metadataRecords)
                ..where((tbl) =>
                    tbl.itemId.equals(folderId) &
                    tbl.typeId.equals(MetadataTypeEnum.tag.dbId)))
              .get();

          final tagId = await addTag(tag.value);

          final alreadyLinked =
              existingMetadata.any((m) => m.metadataId == tagId);

          if (!alreadyLinked) {
            await into(metadataRecords).insert(
              MetadataRecordsCompanion.insert(
                id: generateId(),
                itemId: folderId,
                metadataId: tagId,
                typeId: MetadataTypeEnum.tag.dbId,
              ),
            );
            addedTagIds.add(tagId);
          }
        }

        loggerGlobal.fine(
            "FolderUpdate", "Added ${addedTagIds.length} tags to folder");
        return addedTagIds;
      } catch (e) {
        loggerGlobal.severe(
            "FolderUpdate", "Error adding tags to folder: $e");
        rethrow;
      }
    });
  }

  /// Removes tags from an existing folder.
  Future<int> removeTagsFromFolder({
    required String folderId,
    required List<String> tagIds,
  }) async {
    return transaction(() async {
      try {
        loggerGlobal.fine("FolderUpdate",
            "Removing ${tagIds.length} tags from folder $folderId");

        final deletedCount = await (delete(metadataRecords)
              ..where((tbl) =>
                  tbl.itemId.equals(folderId) &
                  tbl.metadataId.isIn(tagIds) &
                  tbl.typeId.equals(MetadataTypeEnum.tag.dbId)))
            .go();

        loggerGlobal.fine(
            "FolderUpdate", "Removed $deletedCount tag associations");
        return deletedCount;
      } catch (e) {
        loggerGlobal.severe(
            "FolderUpdate", "Error removing tags from folder: $e");
        rethrow;
      }
    });
  }
}
