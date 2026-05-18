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
            locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase);

  @visibleForTesting
  FolderPersistenceService.withDeps({required AppDatabase appDatabase})
      : _resolveDb = (() => appDatabase);

  /// Loads folders by their IDs, skipping any that don't exist.
  ///
  /// Uses `getFoldersByIds` for a single `WHERE id IN (...)` round-trip
  /// rather than one query per id.
  Future<List<Folder>> loadFoldersByIds(List<String> folderIds) {
    final appDb = _resolveDb();
    return appDb.getFoldersByIds(folderIds);
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
