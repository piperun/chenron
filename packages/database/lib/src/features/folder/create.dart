import "package:database/database.dart";
import "package:database/src/core/handlers/run_vepr.dart";
import "package:database/src/core/id.dart";
import "package:database/src/features/folder/insert.dart";
import "package:database/src/features/tag/handlers/insert_handler.dart";
import "package:drift/drift.dart";

typedef _FolderCreateProcess = ({
  List<TagResultIds>? createdTagIds,
  List<ItemResultIds>? createdItemIds,
});

extension FolderCreateExtensions on AppDatabase {
  Future<FolderResultIds> createFolder({
    required FolderDraft folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
  }) {
    return runVepr<String, _FolderCreateProcess, FolderResultIds>(
      logSource: "createFolder",
      validate: () {
        if (folderInfo.title.trim().isEmpty) {
          throw ArgumentError("Folder title cannot be empty.");
        }
      },
      execute: () async {
        final id = generateId();
        await folders.insertOne(FoldersCompanion.insert(
          id: id,
          title: folderInfo.title,
          description: folderInfo.description,
          color: Value(folderInfo.color),
        ));
        return id;
      },
      process: (folderId) async {
        List<TagResultIds>? createdTagIds;
        List<ItemResultIds>? createdItemIds;
        await batch((b) async {
          if (tags != null && tags.isNotEmpty) {
            createdTagIds = await insertTags(batch: b, tagMetadata: tags);
            for (final tagResult in createdTagIds!) {
              insertMetadataRelation(
                batch: b,
                metadataId: tagResult.tagId,
                itemId: folderId,
                type: MetadataTypeEnum.tag,
              );
            }
          }
          if (items != null && items.isNotEmpty) {
            createdItemIds = await insertFolderItems(
              batch: b,
              folderId: folderId,
              itemInserts: items,
            );
          }
        });
        return (createdTagIds: createdTagIds, createdItemIds: createdItemIds);
      },
      build: (folderId, proc) => FolderResultIds(
        folderId: folderId,
        tagIds: proc.createdTagIds,
        itemIds: proc.createdItemIds,
      ),
    );
  }
}
