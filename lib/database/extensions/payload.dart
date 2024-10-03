import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/database/extensions/link/archive.dart";
import "package:chenron/database/extensions/user_config/read.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/models/folder_results.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/utils/web_archive/archive_org/archive_org_options.dart";

extension PayloadExtensions on AppDatabase {
  Future<void> createFolderAndArchive({
    required FolderInfo folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
    ArchiveOrgOptions? archiveOptions,
  }) async {
    final configDatabase = ConfigDatabase();
    FolderResults results = await createFolder(
      folderInfo: folderInfo,
      tags: tags,
      items: items,
    );
    final UserConfig? userConfig = await configDatabase.getUserConfig();
    if (userConfig == null) return;

    if (userConfig.archiveEnabled &&
        userConfig.archiveOrgS3AccessKey!.isNotEmpty &&
        userConfig.archiveOrgS3SecretKey!.isNotEmpty) {
      for (final itemId in results.itemIds!) {
        await archiveLink(
          itemId.linkId!,
          userConfig.archiveOrgS3AccessKey!,
          userConfig.archiveOrgS3SecretKey!,
          options: archiveOptions,
        );
      }
    }
    await configDatabase.close();
  }
}
