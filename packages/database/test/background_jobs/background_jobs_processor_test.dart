import "package:database/database.dart";
import "package:database/src/features/background_jobs/crud.dart";
import "package:database/src/features/background_jobs/processor.dart";
import "package:database/src/features/link/create.dart";
import "package:database/src/features/link/read.dart";
import "package:web_archiver/web_archiver.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
      databaseName: "test_db",
      setupOnInit: true,
      debugMode: true,
    );
  });

  tearDown(() async {
    ArchiveQueueProcessor.clearInstance();
    await database.delete(database.backgroundJobs).go();
    await database.delete(database.links).go();
    await database.close();
  });

  group("ArchiveQueueProcessor", () {
    test("processNext archives a queued job and updates link", () async {
      final linkResult = await database.createLink(link: "https://example.com");

      await database.enqueueArchiveJob(
        linkId: linkResult.linkId,
        url: "https://example.com",
        service: "archive_org",
      );

      final fakeClient = _FakeArchiveOrgClient();
      final processor = ArchiveQueueProcessor(
        database: database,
        archiveOrgClientFactory: (key, secret) => fakeClient,
        accessKey: "test-key",
        secretKey: "test-secret",
      );

      final processed = await processor.processNext();
      expect(processed, isTrue);

      final jobs = await (database.select(database.backgroundJobs)).get();
      expect(jobs.first.status, "completed");
      expect(jobs.first.resultUrl, isNotNull);

      final link = await database.getLink(linkId: linkResult.linkId);
      expect(link!.data.archiveOrgUrl, isNotNull);
    });

    test("processNext re-queues job on first failure", () async {
      final linkResult = await database.createLink(link: "https://fail.com");

      await database.enqueueArchiveJob(
        linkId: linkResult.linkId,
        url: "https://fail.com",
        service: "archive_org",
      );

      final failingClient = _FakeArchiveOrgClient(shouldFail: true);
      final processor = ArchiveQueueProcessor(
        database: database,
        archiveOrgClientFactory: (key, secret) => failingClient,
        accessKey: "test-key",
        secretKey: "test-secret",
      );

      final processed = await processor.processNext();
      expect(processed, isTrue);

      // With default maxAttempts=3, first failure re-queues for retry
      final jobs = await (database.select(database.backgroundJobs)).get();
      expect(jobs.first.status, "queued");
      expect(jobs.first.error, isNotNull);
      expect(jobs.first.attempts, 1);
    });

    test("processNext returns false when queue is empty", () async {
      final processor = ArchiveQueueProcessor(
        database: database,
        archiveOrgClientFactory: (key, secret) => _FakeArchiveOrgClient(),
        accessKey: "test-key",
        secretKey: "test-secret",
      );

      final processed = await processor.processNext();
      expect(processed, isFalse);
    });

    test("job permanently fails after exceeding max attempts", () async {
      final linkResult = await database.createLink(
        link: "https://always-fails.com",
      );

      await database.enqueueArchiveJob(
        linkId: linkResult.linkId,
        url: "https://always-fails.com",
        service: "archive_org",
      );

      final failingClient = _FakeArchiveOrgClient(shouldFail: true);
      final processor = ArchiveQueueProcessor(
        database: database,
        archiveOrgClientFactory: (key, secret) => failingClient,
        accessKey: "test-key",
        secretKey: "test-secret",
        maxAttempts: 3,
        delayBetweenJobs: Duration.zero,
      );

      // processAll will attempt the job 3 times, each time it fails and
      // gets re-queued, until the 3rd attempt permanently fails it
      await processor.processAll();

      final jobs = await (database.select(database.backgroundJobs)).get();
      expect(jobs.first.status, "failed");
      expect(jobs.first.attempts, 3);
      expect(jobs.first.error, contains("Exceeded 3 attempts"));
    });

    test("processAll processes multiple jobs in order", () async {
      final link1 = await database.createLink(link: "https://a.com");
      final link2 = await database.createLink(link: "https://b.com");

      await database.enqueueArchiveJob(
        linkId: link1.linkId,
        url: "https://a.com",
        service: "archive_org",
      );
      await database.enqueueArchiveJob(
        linkId: link2.linkId,
        url: "https://b.com",
        service: "archive_org",
      );

      final fakeClient = _FakeArchiveOrgClient();
      final processor = ArchiveQueueProcessor(
        database: database,
        archiveOrgClientFactory: (key, secret) => fakeClient,
        accessKey: "test-key",
        secretKey: "test-secret",
        delayBetweenJobs: Duration.zero,
      );

      final count = await processor.processAll();
      expect(count, 2);
      expect(fakeClient.archiveCallCount, 2);
    });
  });

  group("ArchiveQueueProcessor static instance + triggerProcessing", () {
    test("registerInstance stores and triggerProcessing invokes it", () async {
      final linkResult = await database.createLink(link: "https://trigger.com");

      await database.enqueueArchiveJob(
        linkId: linkResult.linkId,
        url: "https://trigger.com",
        service: "archive_org",
      );

      final fakeClient = _FakeArchiveOrgClient();
      final processor = ArchiveQueueProcessor(
        database: database,
        archiveOrgClientFactory: (key, secret) => fakeClient,
        accessKey: "test-key",
        secretKey: "test-secret",
        delayBetweenJobs: Duration.zero,
      );

      ArchiveQueueProcessor.registerInstance(processor);
      ArchiveQueueProcessor.triggerProcessing();

      // triggerProcessing is fire-and-forget, give it time to complete
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final jobs = await (database.select(database.backgroundJobs)).get();
      expect(jobs.first.status, "completed");
      expect(fakeClient.archiveCallCount, 1);

      final link = await database.getLink(linkId: linkResult.linkId);
      expect(link!.data.archiveOrgUrl, isNotNull);
    });

    test("triggerProcessing is safe when no instance registered", () {
      // Should not throw
      ArchiveQueueProcessor.triggerProcessing();
    });

    test("triggerProcessing no-ops when already processing", () async {
      final link1 = await database.createLink(link: "https://slow1.com");
      final link2 = await database.createLink(link: "https://slow2.com");

      await database.enqueueArchiveJob(
        linkId: link1.linkId,
        url: "https://slow1.com",
        service: "archive_org",
      );
      await database.enqueueArchiveJob(
        linkId: link2.linkId,
        url: "https://slow2.com",
        service: "archive_org",
      );

      final fakeClient = _SlowFakeArchiveOrgClient();
      final processor = ArchiveQueueProcessor(
        database: database,
        archiveOrgClientFactory: (key, secret) => fakeClient,
        accessKey: "test-key",
        secretKey: "test-secret",
        delayBetweenJobs: Duration.zero,
      );

      ArchiveQueueProcessor.registerInstance(processor);

      // Start processing
      final firstRun = processor.processAll();
      // Trigger again while first run is active — should no-op
      ArchiveQueueProcessor.triggerProcessing();

      await firstRun;

      // Only one run should have happened (2 jobs processed once, not twice)
      expect(fakeClient.archiveCallCount, 2);
    });
  });
}

class _SlowFakeArchiveOrgClient extends ArchiveOrgClient {
  int archiveCallCount = 0;

  _SlowFakeArchiveOrgClient() : super("fake", "fake");

  @override
  Future<String> archiveAndWait(String targetUrl,
      {ArchiveOrgOptions? options}) async {
    archiveCallCount++;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return "https://web.archive.org/web/fake/$targetUrl";
  }
}

class _FakeArchiveOrgClient extends ArchiveOrgClient {
  final bool shouldFail;
  int archiveCallCount = 0;

  _FakeArchiveOrgClient({this.shouldFail = false}) : super("fake", "fake");

  @override
  Future<String> archiveAndWait(String targetUrl,
      {ArchiveOrgOptions? options}) async {
    archiveCallCount++;
    if (shouldFail) {
      throw Exception("Simulated archive failure");
    }
    return "https://web.archive.org/web/fake/$targetUrl";
  }
}
