import "package:database/database.dart";
import "package:database/main.dart";
import "package:chenron/locator.dart";
import "package:chenron/components/forms/folder_form.dart";
import "package:signals/signals.dart";

class FolderPersistenceService {
  /// Loads folders by their IDs, skipping any that don't exist.
  Future<List<Folder>> loadFoldersByIds(List<String> folderIds) async {
    final db = locator.get<Signal<AppDatabaseHandler>>().value;
    final folders = <Folder>[];

    for (final folderId in folderIds) {
      final result = await db.appDatabase.getFolder(folderId: folderId);
      if (result != null) {
        folders.add(result.data);
      }
    }

    return folders;
  }

  Future<void> saveFolder(FolderFormData formData) async {
    final db = locator.get<Signal<AppDatabaseHandler>>().value;
    final appDb = db.appDatabase;

    final tags = formData.tags.isNotEmpty
        ? formData.tags
            .map((tag) => Metadata(
                  value: tag,
                  type: MetadataTypeEnum.tag,
                ))
            .toList()
        : null;

    final result = await appDb.createFolder(
      folderInfo: FolderDraft(
        title: formData.title,
        description: formData.description,
      ),
      tags: tags,
    );

    if (formData.parentFolderIds.isNotEmpty) {
      for (final parentFolderId in formData.parentFolderIds) {
        await appDb.updateFolder(
          parentFolderId,
          itemUpdates: CUD(
            create: [],
            update: [
              FolderItem.folder(
                id: null,
                itemId: result.folderId,
                folderId: result.folderId,
                title: formData.title,
              )
            ],
            remove: [],
          ),
        );
      }
    }
  }
}
