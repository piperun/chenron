import "package:chenron/database/database.dart";
import "package:chenron/utils/logger.dart";
import "package:chenron/utils/web_archive/archive_org/archive_org.dart";
import "package:chenron/utils/web_archive/archive_org/archive_org_options.dart";
import "package:drift/drift.dart";

extension ArchiveLinkExtensions on AppDatabase {
  Future<void> archiveLink(String linkId,
      {required String accessKey,
      required String secretKey,
      ArchiveOrgOptions? options}) async {
    return transaction(() async {
      try {
        final link = await (select(links)..where((l) => l.id.equals(linkId)))
            .getSingle();
        final archiveClient = archiveOrgClientFactory(accessKey, secretKey);
        final archivedUrl = await archiveClient.archiveAndWait(link.path);

        await (update(links)..where((l) => l.id.equals(linkId))).write(
          LinksCompanion(
            archiveOrgUrl: Value(archivedUrl),
          ),
        );

        loggerGlobal.info(
            "ArchiveLinkActions", "Successfully archived link: $linkId");
      } catch (e) {
        loggerGlobal.severe("ArchiveLinkActions", "Error archiving link: $e");
        rethrow;
      }
    });
  }

  Future<void> batchArchiveLinks(List<String> linkIds,
      {required String accessKey,
      required String secretKey,
      ArchiveOrgOptions? options}) async {
    for (final linkId in linkIds) {
      await archiveLink(linkId,
          accessKey: accessKey, secretKey: secretKey, options: options);
    }
  }
}
