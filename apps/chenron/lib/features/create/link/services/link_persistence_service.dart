import "package:flutter/foundation.dart";

import "package:database/database.dart";
import "package:database/features.dart";
import "package:chenron/locator.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:signals/signals.dart";

class LinkPersistenceService {
  late final AppDatabase Function() _resolveDb;

  LinkPersistenceService()
      : _resolveDb = (() =>
            locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase);

  @visibleForTesting
  LinkPersistenceService.withDeps({required AppDatabase appDatabase})
      : _resolveDb = (() => appDatabase);

  Future<int> saveLinks({
    required List<LinkEntry> entries,
    required List<String> folderIds,
    Set<String> globalTags = const {},
  }) async {
    final appDb = _resolveDb();

    List<String> targetFolders = folderIds;
    if (targetFolders.isEmpty) {
      final defaultId = await appDb.getDefaultFolderId();
      if (defaultId != null) {
        targetFolders = [defaultId];
      }
    }

    // No destination — a link with no folder would be unreachable, so save
    // nothing (matches the "Saved 0 link(s)" contract callers rely on).
    if (targetFolders.isEmpty) {
      return 0;
    }

    var savedCount = 0;
    for (final entry in entries) {
      final mergedTags = <String>{...entry.tags, ...globalTags};
      final tags = mergedTags.isNotEmpty
          ? mergedTags
              .map((tag) => Metadata(
                    value: tag,
                    type: MetadataTypeEnum.tag,
                  ))
              .toList()
          : null;

      // Create the link (and its tags) once. `createLink` is idempotent on
      // the URL, so attaching the same link to several folders must not
      // re-run tag insertion — doing so would accumulate duplicate
      // tag-relation rows, one per target folder.
      final result = await appDb.createLink(
        link: entry.url,
        tags: tags,
      );

      for (final folderId in targetFolders) {
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
      }

      savedCount++;
    }

    return savedCount;
  }
}
