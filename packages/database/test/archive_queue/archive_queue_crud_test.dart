import "package:database/main.dart";
import "package:database/src/features/archive_queue/crud.dart";
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
    await database.delete(database.archiveJobs).go();
    await database.close();
  });

  group("ArchiveQueueCrud", () {
    test("enqueueArchiveJob creates a queued job", () async {
      final id = await database.enqueueArchiveJob(
        linkId: "link-123",
        url: "https://example.com",
        service: "archive_org",
      );

      expect(id, isNotEmpty);
      final job = await database.getArchiveJob(id);
      expect(job, isNotNull);
      expect(job!.status, "queued");
      expect(job.linkId, "link-123");
      expect(job.url, "https://example.com");
      expect(job.service, "archive_org");
      expect(job.attempts, 0);
    });

    test("getNextQueuedJob returns oldest queued job", () async {
      await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://first.com",
        service: "archive_org",
      );
      await Future.delayed(const Duration(milliseconds: 10));
      await database.enqueueArchiveJob(
        linkId: "link-2",
        url: "https://second.com",
        service: "archive_org",
      );

      final next = await database.getNextQueuedJob();
      expect(next, isNotNull);
      expect(next!.url, "https://first.com");
    });

    test("getNextQueuedJob skips in_progress and completed jobs", () async {
      final id1 = await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://in-progress.com",
        service: "archive_org",
      );
      await database.updateArchiveJobStatus(id: id1, status: "in_progress");

      final id2 = await database.enqueueArchiveJob(
        linkId: "link-2",
        url: "https://completed.com",
        service: "archive_org",
      );
      await database.updateArchiveJobStatus(
        id: id2,
        status: "completed",
        resultUrl: "https://archive.org/web/...",
      );

      await database.enqueueArchiveJob(
        linkId: "link-3",
        url: "https://queued.com",
        service: "archive_org",
      );

      final next = await database.getNextQueuedJob();
      expect(next!.url, "https://queued.com");
    });

    test("getNextQueuedJob returns null when queue is empty", () async {
      final next = await database.getNextQueuedJob();
      expect(next, isNull);
    });

    test("updateArchiveJobStatus updates status and resultUrl", () async {
      final id = await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://example.com",
        service: "archive_org",
      );

      await database.updateArchiveJobStatus(
        id: id,
        status: "completed",
        resultUrl: "https://web.archive.org/web/123/https://example.com",
      );

      final job = await database.getArchiveJob(id);
      expect(job!.status, "completed");
      expect(
        job.resultUrl,
        "https://web.archive.org/web/123/https://example.com",
      );
    });

    test("updateArchiveJobStatus updates error and increments attempts",
        () async {
      final id = await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://example.com",
        service: "archive_org",
      );

      await database.updateArchiveJobStatus(
        id: id,
        status: "failed",
        error: "Timeout after 5 minutes",
        incrementAttempts: true,
      );

      final job = await database.getArchiveJob(id);
      expect(job!.status, "failed");
      expect(job.error, "Timeout after 5 minutes");
      expect(job.attempts, 1);
    });

    test("re-queue a failed job resets status to queued", () async {
      final id = await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://example.com",
        service: "archive_org",
      );

      await database.updateArchiveJobStatus(
        id: id,
        status: "failed",
        error: "Temporary error",
        incrementAttempts: true,
      );

      await database.updateArchiveJobStatus(id: id, status: "queued");

      final job = await database.getArchiveJob(id);
      expect(job!.status, "queued");
      expect(job.attempts, 1);
    });

    test("getPendingJobCount returns correct count", () async {
      await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://a.com",
        service: "archive_org",
      );
      await database.enqueueArchiveJob(
        linkId: "link-2",
        url: "https://b.com",
        service: "archive_org",
      );

      expect(await database.getPendingArchiveJobCount(), 2);
    });

    test("clearCompletedJobs removes only completed jobs", () async {
      final id1 = await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://done.com",
        service: "archive_org",
      );
      await database.updateArchiveJobStatus(id: id1, status: "completed");

      await database.enqueueArchiveJob(
        linkId: "link-2",
        url: "https://pending.com",
        service: "archive_org",
      );

      await database.clearCompletedArchiveJobs();

      expect(await database.getPendingArchiveJobCount(), 1);
      expect(await database.getArchiveJob(id1), isNull);
    });

    test("hasArchiveJob prevents duplicate enqueue", () async {
      await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://example.com",
        service: "archive_org",
      );

      expect(
        await database.hasArchiveJob(linkId: "link-1", service: "archive_org"),
        isTrue,
      );
      expect(
        await database.hasArchiveJob(linkId: "link-1", service: "archive_is"),
        isFalse,
      );
    });
  });
}
