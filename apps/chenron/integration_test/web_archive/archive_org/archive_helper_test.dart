import "package:chenron/database/extensions/id.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:chenron/database/extensions/user_config/read.dart";
import "package:drift/drift.dart" as drift;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/archive_helper.dart";
import "package:chenron/database/extensions/link/create.dart";
import "package:chenron/test_support/path_provider_fake.dart";
import "package:chenron/test_support/logger_setup.dart";
import "package:web_archiver/web_archiver.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Install fakes and test logger once for this suite.
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
    // Use a fake Archive.org client to keep tests offline and deterministic.
    archiveOrgClientFactory = (key, secret) => _FakeArchiveOrgClient();
    // Suppress drift multiple database warnings in tests.
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase database;
  late ConfigDatabase configDatabase;
  late UserConfig? userConfig;
  late String testUrl;

  setUp(() async {
    database = AppDatabase(
      queryExecutor: NativeDatabase.memory(),
      setupOnInit: true,
      databaseName: "test_db",
      debugMode: true,
    );
    await database.setup();
    configDatabase = ConfigDatabase(
      queryExecutor: NativeDatabase.memory(),
      setupOnInit: true,
    );
    await configDatabase.setup();
    // Ensure archive.org credentials are present to enable archiving paths in tests
    final userConfigs = configDatabase.userConfigs;
    await (configDatabase.update(userConfigs)).write(
      const UserConfigsCompanion(
        archiveOrgS3AccessKey: drift.Value("test_key"),
        archiveOrgS3SecretKey: drift.Value("test_secret"),
      ),
    );

    userConfig =
        await configDatabase.getUserConfig().then((config) => config?.data);
    testUrl = "https://example.org/";
  });

  tearDown(() async {
    await database.close();
    await configDatabase.close();
  });

  group("[offline] ArchiveHelper", () {
    test("archiveOrgLinks archives new links", () async {
      final linkResult = await database.createLink(link: testUrl);
      final linkId = linkResult.linkId;

      await database.archiveOrgLinks([linkId], userConfig!);

      final archivedLink = await database.getLink(linkId: linkId);
      expect(archivedLink?.data.archiveOrgUrl, isNotNull);
      expect(archivedLink?.data.archiveOrgUrl,
          startsWith("https://web.archive.org/"));
    });

    test("archiveOrgLinks skips recent archive links", () async {
      final linkResult = await database.createLink(link: testUrl);
      final linkId = linkResult.linkId;
      // Pre-archive once so the link has a recent archive
      await database.archiveOrgLinks([linkId], userConfig!, archiveDueDate: 0);
      final recentArchiveUrl = await database
          .getLink(linkId: linkId)
          .then((archiveLink) => archiveLink?.data.archiveOrgUrl);

      // With a large due date, a recent archive should be skipped
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

class _FakeArchiveOrgClient extends ArchiveOrgClient {
  _FakeArchiveOrgClient() : super("", "");

  @override
  Future<String> archiveAndWait(String targetUrl) async {
    // Return a deterministic archived URL differing from older timestamps
    return "https://web.archive.org/web/20990101000000/$targetUrl";
  }
}
