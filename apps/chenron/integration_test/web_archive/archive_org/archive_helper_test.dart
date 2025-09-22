import 'dart:io';
import "package:chenron/database/extensions/id.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:chenron/database/extensions/user_config/read.dart";
import "package:drift/drift.dart" as drift;
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/archive_helper.dart";
import "package:chenron/database/extensions/link/create.dart";
import "package:chenron/test_support/path_provider_fake.dart";
import "package:chenron/test_support/logger_setup.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Install fakes and test logger once for this suite.
  late String basePath;
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
    // Use a dedicated temp directory for databases to avoid Windows write quirks.
    basePath = Directory.systemTemp.createTempSync('chenron_db_test').path;
    // Suppress drift multiple database warnings in tests.
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase database;
  late ConfigDatabase configDatabase;
  late UserConfig? userConfig;
  late String testUrl;

  setUp(() async {
    database = AppDatabase(
      setupOnInit: true,
      databaseName: "test_db",
      customPath: basePath,
    );
    configDatabase = ConfigDatabase(customPath: basePath);
    userConfig =
        await configDatabase.getUserConfig().then((config) => config?.data);
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
            path: testUrl,
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
