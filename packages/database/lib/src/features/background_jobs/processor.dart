import "dart:async";
import "package:app_logger/app_logger.dart";
import "package:database/database.dart";
import "package:database/src/features/background_jobs/crud.dart";
import "package:drift/drift.dart";
import "package:web_archiver/web_archiver.dart";

const _source = "ArchiveQueueProcessor";

/// Processes archive jobs from the background queue.
///
/// Only operates on entries with service ∈ {archive_org, archive_is}; the
/// metadata-fetch entries that share the table are audit-log style and
/// never end up in the queued state.
class ArchiveQueueProcessor {
  final AppDatabase database;
  final ArchiveOrgClientFactory archiveOrgClientFactory;
  final String accessKey;
  final String secretKey;
  final int maxAttempts;
  final Duration delayBetweenJobs;

  static bool _isProcessing = false;
  static ArchiveQueueProcessor? _instance;

  /// Register a processor instance at startup so it can be triggered
  /// when new jobs are enqueued mid-session.
  static void registerInstance(ArchiveQueueProcessor processor) {
    _instance = processor;
  }

  /// Trigger processing of queued jobs. Safe to call from anywhere —
  /// no-ops if already processing or no instance registered.
  /// Fire-and-forget: does not await completion.
  static void triggerProcessing() {
    unawaited(_instance?.processAll());
  }

  /// Clear the registered instance. Used in tests.
  static void clearInstance() {
    _instance = null;
  }

  ArchiveQueueProcessor({
    required this.database,
    required this.archiveOrgClientFactory,
    required this.accessKey,
    required this.secretKey,
    this.maxAttempts = 3,
    this.delayBetweenJobs = const Duration(seconds: 2),
  });

  /// Process the next queued job. Returns true if a job was found, false if empty.
  Future<bool> processNext() async {
    final job = await database.getNextQueuedArchiveJob();
    if (job == null) return false;

    // Mark in-progress
    await database.updateBackgroundJobStatus(
      id: job.id,
      status: BackgroundJobStatus.inProgress,
    );

    try {
      final client = archiveOrgClientFactory(accessKey, secretKey);
      final archivedUrl = await client.archiveAndWait(job.url);

      // Update job as completed
      await database.updateBackgroundJobStatus(
        id: job.id,
        status: BackgroundJobStatus.completed,
        resultUrl: archivedUrl,
      );

      // Update the link's archive URL. linkId is nullable on the table now,
      // but archive jobs always have one (set at enqueue time).
      final linkId = job.linkId;
      if (linkId != null) {
        await (database.update(database.links)
              ..where((l) => l.id.equals(linkId)))
            .write(LinksCompanion(archiveOrgUrl: Value(archivedUrl)));
      }

      loggerGlobal.info(_source, "Archived ${job.url} → $archivedUrl");
    } catch (e) {
      loggerGlobal.warning(_source, "Failed to archive ${job.url}: $e");
      final newAttempts = job.attempts + 1;
      if (newAttempts >= maxAttempts) {
        // Permanently failed — exceeded retry limit
        await database.updateBackgroundJobStatus(
          id: job.id,
          status: BackgroundJobStatus.failed,
          error: "Exceeded $maxAttempts attempts. Last error: $e",
          incrementAttempts: true,
        );
      } else {
        // Re-queue for retry
        await database.updateBackgroundJobStatus(
          id: job.id,
          status: BackgroundJobStatus.queued,
          error: e.toString(),
          incrementAttempts: true,
        );
        loggerGlobal.info(
          _source,
          "Re-queued ${job.url} (attempt $newAttempts/$maxAttempts)",
        );
      }
    }

    return true;
  }

  /// Process all queued jobs until the queue is empty.
  Future<int> processAll() async {
    if (_isProcessing) return 0;
    _isProcessing = true;
    try {
      var attempted = 0;

      while (true) {
        final hadJob = await processNext();
        if (!hadJob) break;
        attempted++;

        if (delayBetweenJobs > Duration.zero) {
          await Future.delayed(delayBetweenJobs);
        }
      }

      if (attempted > 0) {
        loggerGlobal.info(
          _source,
          "Archive queue: attempted $attempted jobs.",
        );
      }
      return attempted;
    } finally {
      _isProcessing = false;
    }
  }
}
