import "package:database/database.dart";
import "package:database/src/core/id.dart";
import "package:drift/drift.dart";

/// Service values for the [BackgroundJobs.service] column.
class BackgroundJobService {
  static const archiveOrg = "archive_org";
  static const archiveIs = "archive_is";

  /// A metadata fetch attempt (success or failure). These entries are
  /// audit-log style — written after the fetch completes — so they never
  /// have status="queued" and are not picked up by the archive processor.
  static const metadataFetch = "metadata_fetch";

  /// True iff [service] is an archive-style queued job (eligible for the
  /// archive queue processor).
  static bool isArchive(String service) =>
      service == archiveOrg || service == archiveIs;
}

/// Status values for the [BackgroundJobs.status] column.
class BackgroundJobStatus {
  static const queued = "queued";
  static const inProgress = "in_progress";
  static const completed = "completed";
  static const failed = "failed";
}

extension BackgroundJobsCrudExtensions on AppDatabase {
  // ---------------------------------------------------------------------------
  // Archive-job specific (queued workflow)
  // ---------------------------------------------------------------------------

  /// Enqueue a new archive job. Returns the job ID.
  Future<String> enqueueArchiveJob({
    required String linkId,
    required String url,
    required String service,
  }) async {
    final id = generateId();
    await into(backgroundJobs).insert(
      BackgroundJobsCompanion.insert(
        id: id,
        linkId: Value(linkId),
        url: url,
        service: service,
      ),
    );
    return id;
  }

  /// Get the next queued archive job (oldest first). Skips metadata-fetch
  /// entries — those are audit-log entries, not work to be processed.
  Future<BackgroundJob?> getNextQueuedArchiveJob() async {
    return (select(backgroundJobs)
          ..where((j) =>
              j.status.equals(BackgroundJobStatus.queued) &
              j.service.isIn(const [
                BackgroundJobService.archiveOrg,
                BackgroundJobService.archiveIs,
              ]))
          ..orderBy([(j) => OrderingTerm.asc(j.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Count of queued + in_progress archive jobs (excludes metadata fetches).
  Future<int> getPendingArchiveJobCount() async {
    final count = countAll();
    final query = selectOnly(backgroundJobs)
      ..addColumns([count])
      ..where(backgroundJobs.status.isIn([
            BackgroundJobStatus.queued,
            BackgroundJobStatus.inProgress,
          ]) &
          backgroundJobs.service.isIn(const [
            BackgroundJobService.archiveOrg,
            BackgroundJobService.archiveIs,
          ]));
    final row = await query.getSingle();
    return row.read(count)!;
  }

  /// Retry a failed archive job by resetting its status to queued.
  Future<void> retryArchiveJob(String id) async {
    await updateBackgroundJobStatus(
      id: id,
      status: BackgroundJobStatus.queued,
    );
  }

  /// Check if a queued or in-progress archive job already exists for this
  /// link and service. Used to dedupe at enqueue time.
  Future<bool> hasArchiveJob({
    required String linkId,
    required String service,
  }) async {
    final query = select(backgroundJobs)
      ..where(
        (j) =>
            j.linkId.equals(linkId) &
            j.service.equals(service) &
            j.status.isIn(const [
              BackgroundJobStatus.queued,
              BackgroundJobStatus.inProgress,
            ]),
      );
    return (await query.getSingleOrNull()) != null;
  }

  // ---------------------------------------------------------------------------
  // Metadata fetch logging (audit-log workflow)
  // ---------------------------------------------------------------------------

  /// Record a metadata fetch attempt. Always written with a terminal status
  /// (completed or failed) since fetches happen synchronously — there is no
  /// queue to pull from.
  ///
  /// [linkId] is optional: the startup metadata refresh pass iterates the
  /// metadata cache (keyed by URL), so no specific link is associated.
  Future<String> recordMetadataFetch({
    required String url,
    required bool succeeded,
    String? linkId,
    String? error,
  }) async {
    final id = generateId();
    await into(backgroundJobs).insert(
      BackgroundJobsCompanion.insert(
        id: id,
        linkId: Value(linkId),
        url: url,
        service: BackgroundJobService.metadataFetch,
        status: Value(succeeded
            ? BackgroundJobStatus.completed
            : BackgroundJobStatus.failed),
        error: Value(error),
      ),
    );
    return id;
  }

  // ---------------------------------------------------------------------------
  // Generic background-job queries (read-only / cleanup)
  // ---------------------------------------------------------------------------

  /// Get a single background job by ID.
  Future<BackgroundJob?> getBackgroundJob(String id) async {
    return (select(backgroundJobs)..where((j) => j.id.equals(id)))
        .getSingleOrNull();
  }

  /// Update job status, optionally setting resultUrl, error, and incrementing
  /// attempts. Works for any job kind.
  Future<void> updateBackgroundJobStatus({
    required String id,
    required String status,
    String? resultUrl,
    String? error,
    bool incrementAttempts = false,
  }) async {
    final job = await getBackgroundJob(id);
    if (job == null) return;

    await (update(backgroundJobs)..where((j) => j.id.equals(id))).write(
      BackgroundJobsCompanion(
        status: Value(status),
        resultUrl: Value(resultUrl),
        error: Value(error),
        attempts: Value(incrementAttempts ? job.attempts + 1 : job.attempts),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Remove completed jobs (cleanup) — applies to both archive jobs and
  /// metadata-fetch entries.
  Future<void> clearCompletedBackgroundJobs() async {
    await (delete(backgroundJobs)
          ..where((j) => j.status.equals(BackgroundJobStatus.completed)))
        .go();
  }

  /// Get all background jobs (archive + metadata fetches), newest first.
  /// This is what the activity log surfaces.
  Future<List<BackgroundJob>> getAllBackgroundJobs() async {
    return (select(backgroundJobs)
          ..orderBy([(j) => OrderingTerm.desc(j.updatedAt)]))
        .get();
  }
}
