import "dart:async";

import "package:cache_manager/src/metadata_persistence.dart";
import "package:logging/logging.dart";

final _logger = Logger("RefreshScheduler");

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
/// and processes them with rate limiting.
class RefreshScheduler {
  /// Default delay between consecutive refresh operations.
  static const defaultDelay = Duration(seconds: 2);

  /// Sort expired entries by descending refresh priority.
  static List<Map<String, dynamic>> buildQueue(
    List<Map<String, dynamic>> entries, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    final scored = <(double, Map<String, dynamic>)>[];
    for (final entry in entries) {
      final fetchedAtStr = entry["fetchedAt"] as String?;
      if (fetchedAtStr == null) continue;
      final fetchedAt = DateTime.tryParse(fetchedAtStr);
      if (fetchedAt == null) continue;

      final ttlDays = (entry["ttlDays"] as int?) ?? 7;
      final consecutiveUnchanged =
          (entry["consecutiveUnchanged"] as int?) ?? 0;

      final priority = computeRefreshPriority(
        fetchedAt: fetchedAt,
        ttlDays: ttlDays,
        consecutiveUnchanged: consecutiveUnchanged,
        now: currentTime,
      );

      if (priority > 0) {
        scored.add((priority, entry));
      }
    }

    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return scored.map((e) => e.$2).toList();
  }

  /// Process expired entries in priority order.
  ///
  /// Calls [refreshOne] for each URL with a delay between calls.
  /// Stops early if [shouldStop] returns true or [refreshOne] returns false.
  static Future<int> processQueue({
    required MetadataPersistence persistence,
    required Future<bool> Function(String url) refreshOne,
    bool Function()? shouldStop,
    Duration delay = defaultDelay,
  }) async {
    List<Map<String, dynamic>> expired;
    try {
      expired = await persistence.getExpiredEntries();
    } catch (e) {
      _logger.warning("Failed to query expired entries: $e");
      return 0;
    }

    final queue = buildQueue(expired);
    if (queue.isEmpty) {
      _logger.info("No expired entries to refresh.");
      return 0;
    }

    _logger.info("Refresh queue: ${queue.length} expired entries to process.");

    var refreshed = 0;
    for (final entry in queue) {
      if (shouldStop?.call() ?? false) {
        _logger.info("Refresh stopped early after $refreshed entries.");
        break;
      }

      final url = entry["url"] as String;
      final success = await refreshOne(url);
      if (!success) {
        _logger.info(
            "Refresh halted (rate limit or error) after $refreshed entries.");
        break;
      }
      refreshed++;

      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }
    }

    _logger.info("Refresh complete: $refreshed entries refreshed.");
    return refreshed;
  }
}
