import "package:flutter/foundation.dart";

import "package:database/database.dart";
import "package:database/main.dart";
import "package:chenron/locator.dart";
import "package:chenron/components/forms/folder_form.dart";
import "package:signals/signals.dart";

class FolderPersistenceService {
  late final AppDatabase Function() _resolveDb;

  FolderPersistenceService()
      : _resolveDb = (() =>
            locator.get<Signal<AppDatabaseHandler>>().value.appDatabase);

  @visibleForTesting
  FolderPersistenceService.withDeps({required AppDatabase appDatabase})
      : _resolveDb = (() => appDatabase);

  /// Loads folders by their IDs, skipping any that don't exist.
  Future<List<Folder>> loadFoldersByIds(List<String> folderIds) async {
    final appDb = _resolveDb();
    final folders = <Folder>[];

    for (final folderId in folderIds) {
      final result = await appDb.getFolder(folderId: folderId);
      if (result != null) {
        folders.add(result.data);
      }
    }

    return folders;
  }

  Future<void> saveFolder(FolderFormData formData) async {
    final appDb = _resolveDb();

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
        color: formData.color,
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
