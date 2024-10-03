import "package:chenron/database/database.dart";
import "package:chenron/utils/web_archive/archive_org/archive_org.dart";
import "package:chenron/utils/web_archive/archive_org/archive_org_options.dart";
import "package:drift/drift.dart";
import "package:logging/logging.dart";

extension ArchiveLinkExtensions on AppDatabase {
  static final Logger _logger = Logger("Archive Link Actions");

  Future<void> archiveLink(String linkId, String apiKey, String apiSecret,
      {ArchiveOrgOptions? options}) async {
    return transaction(() async {
      try {
        final link = await (select(links)..where((l) => l.id.equals(linkId)))
            .getSingle();
        final archiveClient = ArchiveOrgClient(apiKey, apiSecret);

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

  Future<void> batchArchiveLinks(
      List<String> linkIds, String apiKey, String apiSecret,
      {ArchiveOrgOptions? options}) async {
    for (final linkId in linkIds) {
      await archiveLink(linkId, apiKey, apiSecret, options: options);
    }
  }
}
