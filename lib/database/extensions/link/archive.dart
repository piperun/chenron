import "package:chenron/database/database.dart";
import "package:chenron/utils/web_archive/archive_org/archive_org.dart";
import "package:chenron/utils/web_archive/archive_org/archive_org_options.dart";
import "package:drift/drift.dart";
import "package:logging/logging.dart";

extension ArchiveLinkExtensions on AppDatabase {
  static final Logger _logger = Logger("Archive Link Actions");

  Future<void> archiveLink(String linkId,
      {required String accessKey,
      required String secretKey,
      ArchiveOrgOptions? options}) async {
    return transaction(() async {
      try {
        final link = await (select(links)..where((l) => l.id.equals(linkId)))
            .getSingle();
        final archiveClient = ArchiveOrgClient(accessKey, secretKey);
        final archivedUrl = await archiveClient.archiveAndWait(link.content);

        await (update(links)..where((l) => l.id.equals(linkId))).write(
          LinksCompanion(
            archiveOrgUrl: Value(archivedUrl),
          ),
        );

        _logger.info("Successfully archived link: $linkId");
      } catch (e) {
        _logger.severe("Error archiving link: $e");
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
