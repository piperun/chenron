import "package:database/main.dart";
import "package:database/src/features/background_jobs/crud.dart";
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
    await database.delete(database.backgroundJobs).go();
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
      final job = await database.getBackgroundJob(id);
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

      final next = await database.getNextQueuedArchiveJob();
      expect(next, isNotNull);
      expect(next!.url, "https://first.com");
    });

    test("getNextQueuedJob skips in_progress and completed jobs", () async {
      final id1 = await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://in-progress.com",
        service: "archive_org",
      );
      await database.updateBackgroundJobStatus(id: id1, status: "in_progress");

      final id2 = await database.enqueueArchiveJob(
        linkId: "link-2",
        url: "https://completed.com",
        service: "archive_org",
      );
      await database.updateBackgroundJobStatus(
        id: id2,
        status: "completed",
        resultUrl: "https://archive.org/web/...",
      );

      await database.enqueueArchiveJob(
        linkId: "link-3",
        url: "https://queued.com",
        service: "archive_org",
      );

      final next = await database.getNextQueuedArchiveJob();
      expect(next!.url, "https://queued.com");
    });

    test("getNextQueuedJob returns null when queue is empty", () async {
      final next = await database.getNextQueuedArchiveJob();
      expect(next, isNull);
    });

    test("updateArchiveJobStatus updates status and resultUrl", () async {
      final id = await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://example.com",
        service: "archive_org",
      );

      await database.updateBackgroundJobStatus(
        id: id,
        status: "completed",
        resultUrl: "https://web.archive.org/web/123/https://example.com",
      );

      final job = await database.getBackgroundJob(id);
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

      await database.updateBackgroundJobStatus(
        id: id,
        status: "failed",
        error: "Timeout after 5 minutes",
        incrementAttempts: true,
      );

      final job = await database.getBackgroundJob(id);
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

      await database.updateBackgroundJobStatus(
        id: id,
        status: "failed",
        error: "Temporary error",
        incrementAttempts: true,
      );

      await database.updateBackgroundJobStatus(id: id, status: "queued");

      final job = await database.getBackgroundJob(id);
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
      await database.updateBackgroundJobStatus(id: id1, status: "completed");

      await database.enqueueArchiveJob(
        linkId: "link-2",
        url: "https://pending.com",
        service: "archive_org",
      );

      await database.clearCompletedBackgroundJobs();

      expect(await database.getPendingArchiveJobCount(), 1);
      expect(await database.getBackgroundJob(id1), isNull);
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

  group("recordMetadataFetch", () {
    test("writes a completed entry on success", () async {
      final id = await database.recordMetadataFetch(
        url: "https://example.com",
        succeeded: true,
        linkId: "link-1",
      );

      final job = await database.getBackgroundJob(id);
      expect(job, isNotNull);
      expect(job!.service, BackgroundJobService.metadataFetch);
      expect(job.status, BackgroundJobStatus.completed);
      expect(job.url, "https://example.com");
      expect(job.linkId, "link-1");
      expect(job.error, isNull);
    });

    test("writes a failed entry with error on failure", () async {
      final id = await database.recordMetadataFetch(
        url: "https://broken.com",
        succeeded: false,
        linkId: "link-2",
        error: "HTTP 503",
      );

      final job = await database.getBackgroundJob(id);
      expect(job!.status, BackgroundJobStatus.failed);
      expect(job.error, "HTTP 503");
    });

    test("permits null linkId for orphan fetches (background refresh)", () async {
      final id = await database.recordMetadataFetch(
        url: "https://orphan.com",
        succeeded: false,
        error: "Timeout",
      );

      final job = await database.getBackgroundJob(id);
      expect(job!.linkId, isNull);
      expect(job.url, "https://orphan.com");
    });

    test("metadata fetches are NOT picked up by the archive processor",
        () async {
      // Failed metadata entries shouldn't be queued — they are audit logs.
      // getNextQueuedArchiveJob filters by service, so it should ignore them
      // even if a metadata entry somehow ends up with status="queued".
      await database.recordMetadataFetch(
        url: "https://meta.com",
        succeeded: false,
        error: "boom",
      );

      // No archive jobs in the queue.
      final next = await database.getNextQueuedArchiveJob();
      expect(next, isNull);

      // Pending archive count excludes metadata fetches.
      expect(await database.getPendingArchiveJobCount(), 0);
    });

    test("getAllBackgroundJobs surfaces both archive jobs and metadata fetches",
        () async {
      await database.enqueueArchiveJob(
        linkId: "link-1",
        url: "https://archived.com",
        service: BackgroundJobService.archiveOrg,
      );
      await database.recordMetadataFetch(
        url: "https://fetched.com",
        succeeded: true,
        linkId: "link-1",
      );

      final all = await database.getAllBackgroundJobs();
      expect(all.length, 2);
      final services = all.map((j) => j.service).toSet();
      expect(services, containsAll([
        BackgroundJobService.archiveOrg,
        BackgroundJobService.metadataFetch,
      ]));
    });
  });
}
