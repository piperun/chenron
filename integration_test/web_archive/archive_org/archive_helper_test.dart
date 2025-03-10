import "package:chenron/database/extensions/id.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:chenron/database/extensions/user_config/read.dart";
import "package:drift/drift.dart" as drift;
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/archive_helper.dart";
import "package:chenron/database/extensions/link/create.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late ConfigDatabase configDatabase;
  late UserConfig? userConfig;
  late String testUrl;

  setUp(() async {
    database = AppDatabase(setupOnInit: true, databaseName: "test_db");
    configDatabase = ConfigDatabase();
    userConfig = await configDatabase.getUserConfig();
    testUrl = "https://example.org/";
  });

  tearDown(() async {
    await database.close();
    await configDatabase.close();
  });

  group("ArchiveHelper", () {
    test("archiveOrgLinks archives new links", () async {
      final linkId = await database.createLink(link: testUrl);

      await database.archiveOrgLinks([linkId], userConfig!);

      final archivedLink = await database.getLink(linkId: linkId);
      expect(archivedLink?.data.archiveOrgUrl, isNotNull);
      expect(archivedLink?.data.archiveOrgUrl,
          startsWith("https://web.archive.org/"));
    });

    test("archiveOrgLinks skips recent archive links", () async {
      final linkId = await database.createLink(link: testUrl);
      final recentArchiveUrl = await database
          .getLink(linkId: linkId)
          .then((archiveLink) => archiveLink?.data.archiveOrgUrl);
      await database
          .archiveOrgLinks([linkId], userConfig!, archiveDueDate: 20000);

      final archivedLink = await database.getLink(linkId: linkId);
      expect(archivedLink?.data.archiveOrgUrl, equals(recentArchiveUrl));
    });

    test("archiveOrgLinks re-archives old archive links", () async {
      final String oldArchiveUrl =
          "https://web.archive.org/web/20200101000000/$testUrl";
      final linkId = database.generateId();
      await database.links.insertOne(
          LinksCompanion.insert(
            id: linkId,
            content: testUrl,
            archiveOrgUrl: drift.Value(oldArchiveUrl),
          ),
          mode: drift.InsertMode.insertOrReplace);

      await database.archiveOrgLinks([linkId], userConfig!, archiveDueDate: 0);

      final archivedLink = await database.getLink(linkId: linkId);
      expect(archivedLink?.data.archiveOrgUrl, isNotNull);
      expect(archivedLink?.data.archiveOrgUrl, isNot(equals(oldArchiveUrl)));
      expect(archivedLink?.data.archiveOrgUrl,
          startsWith("https://web.archive.org/"));
    });
  });
}
