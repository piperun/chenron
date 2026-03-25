import "package:database/main.dart";
import "package:database/src/core/id.dart";
import "package:drift/drift.dart";

extension ArchiveQueueCrudExtensions on AppDatabase {
  /// Enqueue a new archive job. Returns the job ID.
  Future<String> enqueueArchiveJob({
    required String linkId,
    required String url,
    required String service,
  }) async {
    final id = generateId();
    await into(archiveJobs).insert(
      ArchiveJobsCompanion.insert(
        id: id,
        linkId: linkId,
        url: url,
        service: service,
      ),
    );
    return id;
  }

  /// Get a single archive job by ID.
  Future<ArchiveJob?> getArchiveJob(String id) async {
    return (select(archiveJobs)..where((j) => j.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get the next queued job (oldest first).
  Future<ArchiveJob?> getNextQueuedJob() async {
    return (select(archiveJobs)
          ..where((j) => j.status.equals("queued"))
          ..orderBy([(j) => OrderingTerm.asc(j.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Update job status, optionally setting resultUrl, error, and incrementing
  /// attempts.
  Future<void> updateArchiveJobStatus({
    required String id,
    required String status,
    String? resultUrl,
    String? error,
    bool incrementAttempts = false,
  }) async {
    final job = await getArchiveJob(id);
    if (job == null) return;

    await (update(archiveJobs)..where((j) => j.id.equals(id))).write(
      ArchiveJobsCompanion(
        status: Value(status),
        resultUrl: Value(resultUrl),
        error: Value(error),
        attempts: Value(incrementAttempts ? job.attempts + 1 : job.attempts),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Count of queued + in_progress jobs.
  Future<int> getPendingArchiveJobCount() async {
    final count = countAll();
    final query = selectOnly(archiveJobs)
      ..addColumns([count])
      ..where(archiveJobs.status.isIn(["queued", "in_progress"]));
    final row = await query.getSingle();
    return row.read(count)!;
  }

  /// Remove completed jobs (cleanup).
  Future<void> clearCompletedArchiveJobs() async {
    await (delete(archiveJobs)..where((j) => j.status.equals("completed")))
        .go();
  }

  /// Check if a job already exists for this link and service.
  Future<bool> hasArchiveJob({
    required String linkId,
    required String service,
  }) async {
    final query = select(archiveJobs)
      ..where(
        (j) =>
            j.linkId.equals(linkId) &
            j.service.equals(service) &
            j.status.isIn(["queued", "in_progress"]),
      );
    return (await query.getSingleOrNull()) != null;
  }
}
