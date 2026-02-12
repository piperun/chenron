import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/cud.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/src/core/handlers/relation_handler.dart";
import "package:database/src/core/handlers/vepr_operation.dart";
import "package:database/src/features/folder/insert.dart";
import "package:database/src/features/tag/handlers/insert_handler.dart";
import "package:drift/drift.dart";

typedef FolderUpdateInput = ({
  String folderId,
  String? title,
  String? description,
  Value<int?>? color,
  CUD<Metadata>? tagUpdates,
  CUD<FolderItem>? itemUpdates,
});

typedef FolderUpdateProcessResult = ({
  Map<String, List<MetadataResultIds>> tagResults,
  Map<String, List<ItemResultIds>> itemResults,
});

typedef FolderUpdateResult = (
  FolderResultIds,
  Map<String, List<MetadataResultIds>>,
  Map<String, List<ItemResultIds>>,
);

class FolderUpdateVEPR extends VEPROperation<AppDatabase, FolderUpdateInput,
    FolderResultIds, FolderUpdateProcessResult, FolderUpdateResult> {
  FolderUpdateVEPR(super.db);

  @override
  void onValidate() {
    logStep("Validate", "Validating folder update for ID: ${input.folderId}");

    if (input.folderId.trim().isEmpty) {
      throw ArgumentError("Folder ID cannot be empty for update.");
    }

    logStep("Validate", "Validation passed");
  }

  @override
  Future<FolderResultIds> onExecute() async {
    logStep("Execute", "Updating folder record for ID: ${input.folderId}");

    if (input.title != null ||
        input.description != null ||
        input.color != null) {
      final folderUpdate = FoldersCompanion(
        title:
            input.title == null ? const Value.absent() : Value(input.title!),
        description: input.description == null
            ? const Value.absent()
            : Value(input.description!),
        color: input.color ?? const Value.absent(),
      );
      await (db.folders.update()
            ..where((t) => t.id.equals(input.folderId)))
          .write(folderUpdate);

      logStep("Execute", "Folder record updated.");
    } else {
      logStep("Execute", "No folder fields to update.");
    }

    return FolderResultIds(folderId: input.folderId);
  }

  @override
  Future<FolderUpdateProcessResult> onProcess() async {
    logStep("Process", "Processing tag and item CUD operations");

    final Map<String, List<MetadataResultIds>> tagResults = {
      "create": [],
      "update": [],
      "remove": [],
    };
    final Map<String, List<ItemResultIds>> itemResults = {
      "create": [],
      "update": [],
      "remove": [],
    };

    final folderId = input.folderId;

    // --- Tag CUD ---
    final tagUpdates = input.tagUpdates;
    if (tagUpdates != null) {
      if (tagUpdates.create.isNotEmpty) {
        await db.batch((batch) async {
          final createdTags = await db.insertTags(
            batch: batch,
            tagMetadata: tagUpdates.create,
          );
          for (final tagResult in createdTags) {
            tagResults["create"]!.add(db.insertMetadataRelation(
              batch: batch,
              itemId: folderId,
              metadataId: tagResult.tagId,
              type: MetadataTypeEnum.tag,
            ));
          }
        });
      }

      if (tagUpdates.update.isNotEmpty) {
        await db.batch((batch) async {
          for (final tagUpdate in tagUpdates.update) {
            if (tagUpdate.metadataId != null) {
              tagResults["update"]!.add(db.insertMetadataRelation(
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

      if (tagUpdates.remove.isNotEmpty) {
        await db.batch((batch) async {
          for (final tagId in tagUpdates.remove) {
            batch.deleteWhere(
              db.metadataRecords,
              (tbl) =>
                  tbl.metadataId.equals(tagId) &
                  tbl.itemId.equals(folderId) &
                  tbl.typeId.equals(MetadataTypeEnum.tag.dbId),
            );
          }
        });
      }

      logStep("Process", "Tag CUD completed.");
    }

    // --- Item CUD ---
    final itemUpdates = input.itemUpdates;
    if (itemUpdates != null) {
      if (itemUpdates.create.isNotEmpty) {
        await db.batch((batch) async {
          final createdItems = await db.insertFolderItems(
            batch: batch,
            folderId: folderId,
            itemInserts: itemUpdates.create,
          );
          itemResults["create"] = createdItems;
        });
      }

      if (itemUpdates.update.isNotEmpty) {
        await db.batch((batch) async {
          for (final itemUpdate in itemUpdates.update) {
            if (itemUpdate.itemId != null) {
              itemResults["update"]!.add(db.insertItemRelation(
                batch: batch,
                itemId: itemUpdate.itemId!,
                folderId: folderId,
                type: itemUpdate.type,
              ));
            }
          }
        });
      }

      if (itemUpdates.remove.isNotEmpty) {
        await db.batch((batch) async {
          for (final itemId in itemUpdates.remove) {
            batch.deleteWhere(
              db.items,
              (tbl) =>
                  tbl.itemId.equals(itemId) &
                  tbl.folderId.equals(folderId),
            );
            itemResults["remove"]!
                .add(ItemResultIds(itemId: itemId, folderId: folderId));
          }
        });
      }

      logStep("Process", "Item CUD completed.");
    }

    return (tagResults: tagResults, itemResults: itemResults);
  }

  @override
  FolderUpdateResult onBuildResult() {
    logStep("BuildResult", "Building final result");
    return (execResult, procResult.tagResults, procResult.itemResults);
  }
}
