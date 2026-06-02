import "package:database/database.dart";
import "package:app_logger/app_logger.dart";
import "package:web_archiver/web_archiver.dart";
import "package:drift/drift.dart";

extension ArchiveLinkExtensions on AppDatabase {
  Future<void> archiveLink(
    String linkId, {
    required String accessKey,
    required String secretKey,
    ArchiveOrgClient? client,
    ArchiveOrgOptions? options,
  }) async {
    // The archive round-trip can take seconds to minutes. It must run with
    // no write transaction open, otherwise it holds the single SQLite
    // connection's write lock for the whole HTTP duration and stalls every
    // other writer. So: read, then network, then a single short write — none
    // of it wrapped in one long transaction.
    try {
      final link =
          await (select(links)..where((l) => l.id.equals(linkId))).getSingle();
      final archiveClient =
          client ?? defaultArchiveOrgClientFactory(accessKey, secretKey);
      final archivedUrl = await archiveClient.archiveAndWait(
        link.path,
        options: options,
      );

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
  }

  Future<void> batchArchiveLinks(
    List<String> linkIds, {
    required String accessKey,
    required String secretKey,
    ArchiveOrgClient? client,
    ArchiveOrgOptions? options,
  }) async {
    for (final linkId in linkIds) {
      await archiveLink(linkId,
          accessKey: accessKey,
          secretKey: secretKey,
          client: client,
          options: options);
    }
  }
}
