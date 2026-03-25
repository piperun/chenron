import "package:database/main.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:drift/drift.dart" as drift;
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";
import "package:web_archiver/web_archiver.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
    archiveOrgClientFactory = (key, secret) => _FakeArchiveOrgClient();
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase database;
  late String testUrl;

  setUp(() async {
    database = AppDatabase(
      queryExecutor: NativeDatabase.memory(),
      setupOnInit: true,
      databaseName: "test_db",
      debugMode: true,
    );
    await database.setup();
    testUrl = "https://example.org/";
  });

  tearDown(() async {
    ArchiveQueueProcessor.clearInstance();
    await database.close();
  });

  group("[offline] Archive Queue Integration", () {
    test("enqueue + process archives a link", () async {
      final linkResult = await database.createLink(link: testUrl);

      await database.enqueueArchiveJob(
        linkId: linkResult.linkId,
        url: testUrl,
        service: "archive_org",
      );

      final processor = ArchiveQueueProcessor(
        database: database,
        archiveOrgClientFactory: archiveOrgClientFactory,
        accessKey: "test_key",
        secretKey: "test_secret",
        delayBetweenJobs: Duration.zero,
      );

      await processor.processAll();

      final archivedLink =
          await database.getLink(linkId: linkResult.linkId);
      expect(archivedLink?.data.archiveOrgUrl, isNotNull);
      expect(archivedLink?.data.archiveOrgUrl,
          startsWith("https://web.archive.org/"));

      final job = await database.getAllArchiveJobs();
      expect(job.first.status, "completed");
    });

    test("duplicate enqueue is prevented", () async {
      final linkResult = await database.createLink(link: testUrl);

      await database.enqueueArchiveJob(
        linkId: linkResult.linkId,
        url: testUrl,
        service: "archive_org",
      );

      // Second enqueue for same link+service should be skipped
      final hasDuplicate = await database.hasArchiveJob(
        linkId: linkResult.linkId,
        service: "archive_org",
      );
      expect(hasDuplicate, isTrue);

      // Only one job exists
      final jobs = await database.getAllArchiveJobs();
      expect(jobs.length, 1);
    });

    test("failed job is re-queued and eventually succeeds", () async {
      final linkResult = await database.createLink(link: testUrl);

      await database.enqueueArchiveJob(
        linkId: linkResult.linkId,
        url: testUrl,
        service: "archive_org",
      );

      // First run: use a client that fails once then succeeds
      var callCount = 0;
      final flakeyClient = _FlakeyArchiveOrgClient(
        failUntil: 1,
        onCall: () => callCount++,
      );

      final processor = ArchiveQueueProcessor(
        database: database,
        archiveOrgClientFactory: (key, secret) => flakeyClient,
        accessKey: "test_key",
        secretKey: "test_secret",
        delayBetweenJobs: Duration.zero,
      );

      await processor.processAll();

      // Should have been called twice: fail → re-queue → succeed
      expect(callCount, 2);

      final job = (await database.getAllArchiveJobs()).first;
      expect(job.status, "completed");
      expect(job.attempts, 1); // 1 failed attempt before success

      final link = await database.getLink(linkId: linkResult.linkId);
      expect(link?.data.archiveOrgUrl, isNotNull);
    });

    test("triggerProcessing fires processing from static instance", () async {
      final linkResult = await database.createLink(link: testUrl);

      await database.enqueueArchiveJob(
        linkId: linkResult.linkId,
        url: testUrl,
        service: "archive_org",
      );

      final processor = ArchiveQueueProcessor(
        database: database,
        archiveOrgClientFactory: archiveOrgClientFactory,
        accessKey: "test_key",
        secretKey: "test_secret",
        delayBetweenJobs: Duration.zero,
      );

      ArchiveQueueProcessor.registerInstance(processor);
      ArchiveQueueProcessor.triggerProcessing();

      // Fire-and-forget — give it time to complete
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final link = await database.getLink(linkId: linkResult.linkId);
      expect(link?.data.archiveOrgUrl, isNotNull);
    });
  });
}

class _FakeArchiveOrgClient extends ArchiveOrgClient {
  _FakeArchiveOrgClient() : super("", "");

  @override
  Future<String> archiveAndWait(String targetUrl,
      {ArchiveOrgOptions? options}) async {
    return "https://web.archive.org/web/20990101000000/$targetUrl";
  }
}

class _FlakeyArchiveOrgClient extends ArchiveOrgClient {
  final int failUntil;
  final void Function() onCall;
  int _calls = 0;

  _FlakeyArchiveOrgClient({required this.failUntil, required this.onCall})
      : super("", "");

  @override
  Future<String> archiveAndWait(String targetUrl,
      {ArchiveOrgOptions? options}) async {
    onCall();
    if (_calls++ < failUntil) {
      throw Exception("Simulated transient failure");
    }
    return "https://web.archive.org/web/20990101000000/$targetUrl";
  }
}
