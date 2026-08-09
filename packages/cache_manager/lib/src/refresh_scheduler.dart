import "dart:async";
import "dart:math";

import "package:app_logger/app_logger.dart";
import "package:cache_manager/src/metadata.dart";
import "package:cache_manager/src/metadata_persistence.dart";
import "package:cache_manager/src/metadata_refresh.dart";

const _source = "RefreshScheduler";

/// Compute refresh priority for a cached entry.
///
/// `priority = daysPastExpiry / (consecutiveUnchanged + 1)`
///
/// Entries that are overdue AND have a history of changing get the
/// highest priority. Entries that are overdue but never change sit
/// at the bottom of the queue.
///
/// Returns <= 0 for entries that are not yet expired.
double computeRefreshPriority({
  required DateTime fetchedAt,
  required int ttlDays,
  required int consecutiveUnchanged,
  required DateTime now,
}) {
  final age = now.difference(fetchedAt).inHours / 24.0;
  final daysPastExpiry = age - ttlDays;
  if (daysPastExpiry <= 0) return daysPastExpiry;
  return daysPastExpiry / (consecutiveUnchanged + 1);
}

/// Builds a priority-sorted refresh queue from expired cache entries
/// and processes them with bounded concurrency.
class RefreshScheduler {
  /// Sort expired entries by descending refresh priority.
  static List<Metadata> buildQueue(
    List<Metadata> entries, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    final scored = <(double, Metadata)>[];
    for (final entry in entries) {
      final priority = computeRefreshPriority(
        fetchedAt: entry.fetchedAt,
        ttlDays: entry.ttlDays,
        consecutiveUnchanged: entry.consecutiveUnchanged,
        now: currentTime,
      );

      if (priority > 0) {
        scored.add((priority, entry));
      }
    }

    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return scored.map((e) => e.$2).toList();
  }

  /// Process unique expired entries in priority order with fixed workers.
  ///
  /// Workers continue through every terminal refresh outcome and stop
  /// claiming new work only when [shouldStop] returns true.
  static Future<MetadataRefreshSummary> processQueue({
    required MetadataPersistence persistence,
    required Future<MetadataRefreshResult> Function(String url) refreshOne,
    bool Function()? shouldStop,
    int maxConcurrent = 3,
  }) async {
    if (maxConcurrent <= 0) {
      throw ArgumentError.value(
        maxConcurrent,
        "maxConcurrent",
        "must be greater than zero",
      );
    }

    List<Metadata> expired;
    try {
      expired = await persistence.getExpiredEntries();
    } catch (e) {
      loggerGlobal.warning(_source, "Failed to query expired entries: $e");
      return const MetadataRefreshSummary();
    }

    final seen = <String>{};
    final queue = buildQueue(expired)
        .where((entry) => seen.add(entry.url))
        .toList(growable: false);
    if (queue.isEmpty) {
      loggerGlobal.info(_source, "No expired entries to refresh.");
      return const MetadataRefreshSummary();
    }

    loggerGlobal.info(
      _source,
      "Refresh queue: ${queue.length} expired entries to process.",
    );

    var nextIndex = 0;
    var summary = const MetadataRefreshSummary();

    Future<void> worker() async {
      while (true) {
        if (shouldStop?.call() ?? false) return;

        final index = nextIndex;
        if (index >= queue.length) return;
        nextIndex = index + 1;

        final result = await refreshOne(queue[index].url);
        summary = summary.add(result.outcome);
      }
    }

    final workerCount = min(maxConcurrent, queue.length);
    await Future.wait(List.generate(workerCount, (_) => worker()));

    loggerGlobal.info(
      _source,
      "Refresh complete: ${summary.total} terminal outcomes recorded.",
    );
    return summary;
  }
}
