import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/cud.dart";
import "package:database/models/folder.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/src/features/background_jobs/crud.dart";
import "package:database/src/features/background_jobs/processor.dart";
import "package:database/src/features/folder/create.dart";
import "package:database/src/features/folder/update.dart";
import "package:database/src/features/link/read.dart";
import "package:database/src/features/user_config/read.dart";

extension PayloadExtensions on AppDatabase {
  Future<void> createFolderExtended({
    required FolderDraft folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
  }) async {
    final FolderResultIds results = await createFolder(
      folderInfo: folderInfo,
      tags: tags,
      items: items,
    );

    // Enqueue archive jobs (instant, non-blocking)
    final linkIds = results.itemIds
            ?.map((item) => item.linkId)
            .whereType<String>()
            .toList() ??
        [];
    await _enqueueArchiveJobsForLinks(linkIds);
  }

  Future<void> updateFolderExtended({
    required String folderId,
    required FolderDraft folderInfo,
    CUD<Metadata>? tags,
    CUD<FolderItem>? items,
  }) async {
    await updateFolder(
      folderId,
      title: folderInfo.title,
      description: folderInfo.description,
      tagUpdates: tags,
      itemUpdates: items,
    );

    if (items == null) return;

    final createLinkIds = items.create.map((item) => item.id!).toList();
    final updateLinkIds = items.update.map((item) => item.id!).toList();
    await _enqueueArchiveJobsForLinks([...createLinkIds, ...updateLinkIds]);
  }

  /// Enqueue archive jobs for links if archiving is configured.
  Future<void> _enqueueArchiveJobsForLinks(List<String> linkIds) async {
    if (linkIds.isEmpty) return;

    final configDatabase = ConfigDatabase();
    try {
      final userConfig = await configDatabase.getUserConfig();
      if (userConfig == null) return;
      final config = userConfig.data;

      final hasArchiveOrg = config.archiveOrgS3AccessKey != null &&
          config.archiveOrgS3AccessKey!.isNotEmpty &&
          config.archiveOrgS3SecretKey != null &&
          config.archiveOrgS3SecretKey!.isNotEmpty;

      if (!hasArchiveOrg) return;

      for (final linkId in linkIds) {
        final linkResult = await getLink(linkId: linkId);
        if (linkResult == null) continue;

        // Skip if already enqueued or in progress
        if (await hasArchiveJob(linkId: linkId, service: "archive_org")) {
          continue;
        }

        await enqueueArchiveJob(
          linkId: linkId,
          url: linkResult.data.path,
          service: "archive_org",
        );
      }
    } finally {
      await configDatabase.close();
    }

    // Trigger background processing immediately
    ArchiveQueueProcessor.triggerProcessing();
  }
}
