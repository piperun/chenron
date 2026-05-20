/// Per-URL failure history + exponential back-off scheduling.
///
/// Extracted from the original `MetadataCache` so the cache layer is
/// pure storage and orchestration (concurrency, in-flight coalescing,
/// signals) can plug in failure-aware behavior on its own.
///
/// Back-off schedule (minutes between retries based on consecutive
/// failures): 2, 10, 60, 360, 1440 — capped at 24 hours. Nothing is
/// permanently blocked — even a URL that has failed many times will
/// eventually be retried once the 24-hour ceiling has elapsed.
library;

/// Back-off schedule in minutes, indexed by consecutive failure count
/// (clamped to the last entry once exceeded).
///
/// 2 min → 10 min → 1 hr → 6 hr → 24 hr (capped).
const List<int> kFailureBackoffMinutes = [2, 10, 60, 360, 1440];

/// How long a failure record may sit without retries before being
/// purged by [FailureTracker.cleanupStale].
const Duration kFailureStaleAge = Duration(days: 30);

/// Tracks consecutive fetch failures per URL and decides whether enough
/// time has elapsed to retry.
class FailureTracker {
  final Map<String, DateTime> _failedAttempts = {};
  final Map<String, int> _failureCount = {};

  /// Record that fetching [url] failed. Increments the count and stores
  /// the failure timestamp for back-off calculation.
  void recordFailure(String url) {
    _failedAttempts[url] = DateTime.now();
    _failureCount[url] = (_failureCount[url] ?? 0) + 1;
  }

  /// Whether enough time has passed since the last failure to retry.
  ///
  /// Back-off schedule: 2 min, 10 min, 1 hr, 6 hr, 24 hr (capped). URLs
  /// with no failure history always return `true`.
  bool shouldRetry(String url) {
    final lastAttempt = _failedAttempts[url];
    if (lastAttempt == null) return true;

    final count = _failureCount[url] ?? 0;
    final index = count.clamp(0, kFailureBackoffMinutes.length - 1);
    return DateTime.now().difference(lastAttempt).inMinutes >=
        kFailureBackoffMinutes[index];
  }

  /// Number of consecutive failures recorded for [url].
  int failureCount(String url) => _failureCount[url] ?? 0;

  /// Clear failure history for [url] (e.g., after a successful fetch).
  void clearFailure(String url) {
    _failedAttempts.remove(url);
    _failureCount.remove(url);
  }

  /// Drop failure entries that haven't been hit in a long time
  /// (avoids unbounded growth from URLs the user never revisits).
  void cleanupStale() {
    final cutoff = DateTime.now().subtract(kFailureStaleAge);
    _failedAttempts.removeWhere((_, time) => time.isBefore(cutoff));
    _failureCount.removeWhere((url, _) => !_failedAttempts.containsKey(url));
  }

  /// Wipe all tracked failures.
  void clearAll() {
    _failedAttempts.clear();
    _failureCount.clear();
  }
}
