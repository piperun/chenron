import "package:flutter/foundation.dart";

import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:signals/signals.dart";

class LinkPersistenceService {
  late final AppDatabase Function() _resolveDb;

  LinkPersistenceService()
      : _resolveDb = (() =>
            locator.get<Signal<AppDatabaseHandler>>().value.appDatabase);

  @visibleForTesting
  LinkPersistenceService.withDeps({required AppDatabase appDatabase})
      : _resolveDb = (() => appDatabase);

  Future<int> saveLinks({
    required List<LinkEntry> entries,
    required List<String> folderIds,
  }) async {
    final appDb = _resolveDb();

    List<String> targetFolders = folderIds;
    if (targetFolders.isEmpty) {
      final defaultId = await appDb.getDefaultFolderId();
      if (defaultId != null) {
        targetFolders = [defaultId];
      }
    }

    var savedCount = 0;
    for (final folderId in targetFolders) {
      for (final entry in entries) {
        final tags = entry.tags.isNotEmpty
            ? entry.tags
                .map((tag) => Metadata(
                      value: tag,
                      type: MetadataTypeEnum.tag,
                    ))
                .toList()
            : null;

        final result = await appDb.createLink(
          link: entry.url,
          tags: tags,
        );

        await appDb.updateFolder(
          folderId,
          itemUpdates: CUD(
            create: [],
            update: [
              FolderItem.link(
                id: null,
                itemId: result.linkId,
                url: entry.url,
              )
            ],
            remove: [],
          ),
        );

        savedCount++;
      }
    }

    return savedCount;
  }
}
