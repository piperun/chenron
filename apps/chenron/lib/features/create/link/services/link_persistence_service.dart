import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:signals/signals.dart";

class LinkPersistenceService {
  Future<int> saveLinks({
    required List<LinkEntry> entries,
    required List<String> folderIds,
  }) async {
    final db = locator.get<Signal<AppDatabaseHandler>>().value;
    final appDb = db.appDatabase;

    final targetFolders = folderIds.isEmpty ? ["default"] : folderIds;

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
