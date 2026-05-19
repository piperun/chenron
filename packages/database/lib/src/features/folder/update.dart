import "package:database/database.dart";
import "package:database/src/core/handlers/run_vepr.dart";
import "package:database/src/core/id.dart";
import "package:database/src/features/folder/insert.dart";
import "package:database/src/features/tag/create.dart";
import "package:database/src/features/tag/handlers/insert_handler.dart";
import "package:app_logger/app_logger.dart";
import "package:drift/drift.dart";

typedef _FolderUpdateProcess = ({
  Map<String, List<MetadataResultIds>> tagResults,
  Map<String, List<ItemResultIds>> itemResults,
});

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
  }) {
    return runVepr<FolderResultIds, _FolderUpdateProcess,
        (
      FolderResultIds,
      Map<String, List<MetadataResultIds>>,
      Map<String, List<ItemResultIds>>,
    )>(
      logSource: "updateFolder",
      validate: () {
        if (folderId.trim().isEmpty) {
          throw ArgumentError("Folder ID cannot be empty for update.");
        }
      },
      execute: () async {
        if (title != null || description != null || color != null) {
          final patch = FoldersCompanion(
            title: title == null ? const Value.absent() : Value(title),
            description: description == null
                ? const Value.absent()
                : Value(description),
            color: color ?? const Value.absent(),
          );
          await (folders.update()..where((t) => t.id.equals(folderId)))
              .write(patch);
        }
        return FolderResultIds(folderId: folderId);
      },
      process: (_) async {
        final tagResults = <String, List<MetadataResultIds>>{
          "create": [],
          "update": [],
          "remove": [],
        };
        final itemResults = <String, List<ItemResultIds>>{
          "create": [],
          "update": [],
          "remove": [],
        };

        if (tagUpdates != null) {
          if (tagUpdates.create.isNotEmpty) {
            await batch((b) async {
              final created = await insertTags(
                batch: b,
                tagMetadata: tagUpdates.create,
              );
              for (final tagResult in created) {
                tagResults["create"]!.add(insertMetadataRelation(
                  batch: b,
                  itemId: folderId,
                  metadataId: tagResult.tagId,
                  type: MetadataTypeEnum.tag,
                ));
              }
            });
          }
          if (tagUpdates.update.isNotEmpty) {
            await batch((b) async {
              for (final u in tagUpdates.update) {
                if (u.metadataId != null) {
                  tagResults["update"]!.add(insertMetadataRelation(
                    batch: b,
                    itemId: folderId,
                    metadataId: u.metadataId!,
                    type: MetadataTypeEnum.tag,
                    value: u.value,
                  ));
                }
              }
            });
          }
          if (tagUpdates.remove.isNotEmpty) {
            await batch((b) async {
              for (final tagId in tagUpdates.remove) {
                b.deleteWhere(
                  metadataRecords,
                  (tbl) =>
                      tbl.metadataId.equals(tagId) &
                      tbl.itemId.equals(folderId) &
                      tbl.typeId.equalsValue(MetadataTypeEnum.tag),
                );
              }
            });
          }
        }

        if (itemUpdates != null) {
          if (itemUpdates.create.isNotEmpty) {
            await batch((b) async {
              itemResults["create"] = await insertFolderItems(
                batch: b,
                folderId: folderId,
                itemInserts: itemUpdates.create,
              );
            });
          }
          if (itemUpdates.update.isNotEmpty) {
            await batch((b) async {
              for (final u in itemUpdates.update) {
                if (u.itemId != null) {
                  itemResults["update"]!.add(insertItemRelation(
                    batch: b,
                    itemId: u.itemId!,
                    folderId: folderId,
                    type: u.type,
                  ));
                }
              }
            });
          }
          if (itemUpdates.remove.isNotEmpty) {
            await batch((b) async {
              for (final itemId in itemUpdates.remove) {
                b.deleteWhere(
                  items,
                  (tbl) =>
                      tbl.itemId.equals(itemId) &
                      tbl.folderId.equals(folderId),
                );
                itemResults["remove"]!
                    .add(ItemResultIds(itemId: itemId, folderId: folderId));
              }
            });
          }
        }

        return (tagResults: tagResults, itemResults: itemResults);
      },
      build: (folderIds, proc) =>
          (folderIds, proc.tagResults, proc.itemResults),
    );
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
                    tbl.typeId.equalsValue(MetadataTypeEnum.tag)))
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
                typeId: MetadataTypeEnum.tag,
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
                  tbl.typeId.equalsValue(MetadataTypeEnum.tag)))
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
