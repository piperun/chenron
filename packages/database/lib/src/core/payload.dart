import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/cud.dart";
import "package:database/models/db_result.dart";
import "package:database/models/folder.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/src/core/archive_helper.dart";
import "package:database/src/features/folder/create.dart";
import "package:database/src/features/folder/update.dart";
import "package:database/src/features/user_config/read.dart";
import "package:web_archiver/web_archiver.dart";

extension PayloadExtensions on AppDatabase {
  Future<void> createFolderExtended({
    required FolderDraft folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
    ArchiveOrgOptions? archiveOptions,
  }) async {
    final configDatabase = ConfigDatabase();
    final FolderResultIds results = await createFolder(
      folderInfo: folderInfo,
      tags: tags,
      items: items,
    );
    final UserConfigResult? userConfig = await configDatabase.getUserConfig();
    if (userConfig == null) return;
    await archiveOrgLinks(
      results.itemIds!.map((item) => item.linkId).whereType<String>().toList(),
      userConfig.data,
      archiveOptions: archiveOptions,
    );
    await configDatabase.close();
  }

  Future<void> updateFolderExtended({
    required String folderId,
    required FolderDraft folderInfo,
    CUD<Metadata>? tags,
    CUD<FolderItem>? items,
    ArchiveOrgOptions? archiveOptions,
  }) async {
    final configDatabase = ConfigDatabase();
    await updateFolder(
      folderId,
      title: folderInfo.title,
      description: folderInfo.description,
      tagUpdates: tags,
      itemUpdates: items,
    );
    final UserConfigResult? userConfig = await configDatabase.getUserConfig();
    if (userConfig == null || items == null) return;

    final List<String> archiveCreateLinks =
        items.create.map((item) => item.id!).toList();
    final List<String> archiveUpdateLinks =
        items.update.map((item) => item.id!).toList();
    for (final archiveList in [archiveCreateLinks, archiveUpdateLinks]) {
      if (archiveList.isEmpty) continue;
      await archiveOrgLinks(
        archiveList,
        userConfig.data,
        archiveOptions: archiveOptions,
      );
    }

    await configDatabase.close();
  }
}
