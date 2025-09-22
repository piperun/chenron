import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/archive_helper.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/database/extensions/folder/update.dart";
import "package:chenron/database/extensions/user_config/read.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/db_result.dart" show UserConfigResult;
import "package:chenron/models/folder.dart";
import "package:chenron/models/created_ids.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/utils/web_archive/archive_org/archive_org_options.dart";

extension PayloadExtensions on AppDatabase {
  Future<void> createFolderExtended({
    required FolderDraft folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
    ArchiveOrgOptions? archiveOptions,
  }) async {
    final configDatabase = ConfigDatabase();
    FolderResultIds results = await createFolder(
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

    List<String> archiveCreateLinks =
        items.create.map((item) => item.id!).toList();
    List<String> archiveUpdateLinks =
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
