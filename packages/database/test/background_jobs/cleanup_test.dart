import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:drift/drift.dart";
import "package:flutter_test/flutter_test.dart";

/// Tests for the two cleanup helpers powering the activity-log TTL:
///   - `recoverOrphanedBackgroundJobs()` — marks long-running
///     `in_progress` rows as `failed` so they don't hang as phantom
///     "Archiving..." entries forever.
///   - `purgeOldBackgroundJobs(olderThan: ...)` — deletes rows whose
///     `updated_at` is older than the configured TTL. `null` disables
///     purging entirely.
void main() {
  setUpAll(installTestLogger);

  late MockDatabaseHelper mockDb;
  late AppDatabase db;

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup();
    db = mockDb.database;
  });

  tearDown(() async {
    await mockDb.dispose();
  });

  int idCounter = 0;
  Future<String> insertJob({
    required String status,
    required DateTime updatedAt,
    String service = BackgroundJobService.archiveOrg,
  }) async {
    // background_jobs.id requires 30..60 chars (CUID-shaped). Build a
    // unique id from a monotonic counter, padded out to satisfy the
    // length constraint without depending on clock resolution.
    final id = "job-test-${(idCounter++).toString().padLeft(21, '0')}";
    await db.into(db.backgroundJobs).insert(
          BackgroundJobsCompanion.insert(
            id: id,
            url: "https://example.com/$id",
            service: service,
            status: Value(status),
            updatedAt: Value(updatedAt),
          ),
        );
    return id;
  }

  group("recoverOrphanedBackgroundJobs()", () {
    test("reclaims in_progress rows older than the stale window", () async {
      final orphanId = await insertJob(
        status: BackgroundJobStatus.inProgress,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final reclaimed = await db.recoverOrphanedBackgroundJobs();
      expect(reclaimed, equals(1));

      final job = await db.getBackgroundJob(orphanId);
      expect(job!.status, equals(BackgroundJobStatus.failed));
      expect(job.error, contains("auto-recovered"));
    });

    test("leaves recent in_progress rows alone", () async {
      final freshId = await insertJob(
        status: BackgroundJobStatus.inProgress,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final reclaimed = await db.recoverOrphanedBackgroundJobs();
      expect(reclaimed, equals(0));

      final job = await db.getBackgroundJob(freshId);
      expect(job!.status, equals(BackgroundJobStatus.inProgress));
    });

    test("doesn't touch queued / completed / failed rows", () async {
      await insertJob(
        status: BackgroundJobStatus.queued,
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      await insertJob(
        status: BackgroundJobStatus.completed,
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      await insertJob(
        status: BackgroundJobStatus.failed,
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      );

      final reclaimed = await db.recoverOrphanedBackgroundJobs();
      expect(reclaimed, equals(0));
    });

    test("staleAfter parameter overrides the default 30-min window",
        () async {
      await insertJob(
        status: BackgroundJobStatus.inProgress,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      // Default would skip this row.
      expect(await db.recoverOrphanedBackgroundJobs(), equals(0));

      // 5-min cutoff reclaims it.
      expect(
        await db.recoverOrphanedBackgroundJobs(
          staleAfter: const Duration(minutes: 5),
        ),
        equals(1),
      );
    });
  });

  group("purgeOldBackgroundJobs()", () {
    test("deletes rows whose updated_at is older than the TTL", () async {
      await insertJob(
        status: BackgroundJobStatus.completed,
        updatedAt: DateTime.now().subtract(const Duration(hours: 48)),
      );
      final freshId = await insertJob(
        status: BackgroundJobStatus.completed,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final deleted =
          await db.purgeOldBackgroundJobs(olderThan: const Duration(hours: 24));
      expect(deleted, equals(1));

      final survivors = await db.getAllBackgroundJobs();
      expect(survivors.length, equals(1));
      expect(survivors.first.id, equals(freshId));
    });

    test("null TTL = permanent retention (no rows deleted)", () async {
      await insertJob(
        status: BackgroundJobStatus.completed,
        updatedAt: DateTime.now().subtract(const Duration(days: 365)),
      );

      final deleted = await db.purgeOldBackgroundJobs(olderThan: null);
      expect(deleted, equals(0));
      expect((await db.getAllBackgroundJobs()).length, equals(1));
    });

    test("purges rows regardless of status (failed, queued, etc.)", () async {
      final oldCutoff = DateTime.now().subtract(const Duration(days: 30));
      for (final status in [
        BackgroundJobStatus.queued,
        BackgroundJobStatus.inProgress,
        BackgroundJobStatus.completed,
        BackgroundJobStatus.failed,
      ]) {
        await insertJob(status: status, updatedAt: oldCutoff);
      }

      final deleted =
          await db.purgeOldBackgroundJobs(olderThan: const Duration(hours: 24));
      expect(deleted, equals(4));
      expect(await db.getAllBackgroundJobs(), isEmpty);
    });
  });
}
