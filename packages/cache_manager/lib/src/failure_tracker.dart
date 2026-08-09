/// Per-URL failure history with restart-safe backoff scheduling.
library;

import "dart:async";

import "package:cache_manager/src/metadata_fetch_result.dart";
import "package:cache_manager/src/metadata_refresh_persistence.dart";

/// Backoff schedule in minutes for consecutive failures.
///
/// 2 min → 10 min → 1 hr → 6 hr → 24 hr (capped).
const List<int> kFailureBackoffMinutes = [2, 10, 60, 360, 1440];

/// How long an untouched failure record is retained during cleanup.
const Duration kFailureStaleAge = Duration(days: 30);

/// Tracks consecutive fetch failures per URL and persists retry deadlines.
class FailureTracker {
  final DateTime Function() _now;
  final Map<String, MetadataRefreshRecord> _records = {};
  final Map<String, Object> _hydrationTokens = {};
  final Map<String, Future<void>> _hydrations = {};
  final Map<String, Future<void>> _persistenceTails = {};
  MetadataRefreshPersistence? _persistence;
  int _persistenceEpoch = 0;

  FailureTracker({
    DateTime Function()? now,
    MetadataRefreshPersistence? persistence,
  })  : _now = now ?? DateTime.now,
        _persistence = persistence;

  /// Inject or replace the retry-state persistence backend.
  void attachPersistence(MetadataRefreshPersistence persistence) {
    _persistence = persistence;
  }

  /// Restore one URL's retry state after process startup.
  ///
  /// Concurrent calls for the same URL share one read. A local mutation that
  /// happens before the read completes wins over the older persisted result.
  Future<void> hydrate(String url) {
    final existing = _hydrations[url];
    if (existing != null) return existing;

    final persistence = _persistence;
    if (persistence == null) return Future<void>.value();
    final token = Object();
    _hydrationTokens[url] = token;
    final previous = _persistenceTails[url] ?? Future<void>.value();
    late final Future<void> hydration;
    hydration = previous
        .then((_) => _loadHydration(url, persistence, token))
        .whenComplete(() {
      if (identical(_hydrations[url], hydration)) {
        _hydrations.remove(url);
      }
      if (identical(_hydrationTokens[url], token)) {
        _hydrationTokens.remove(url);
      }
    });
    _hydrations[url] = hydration;
    return hydration;
  }

  /// Record a failed attempt and persist its next retry deadline.
  ///
  /// [kind] defaults to transport only as a temporary compatibility bridge for
  /// Task 6 callers that do not yet provide structured failure information.
  /// Memory is updated before the returned Future can yield so legacy callers
  /// that ignore it still observe the new failure immediately.
  Future<MetadataRefreshRecord> recordFailure(
    String url, {
    MetadataFailureKind kind = MetadataFailureKind.transport,
    int? statusCode,
    Duration? retryAfter,
  }) {
    final attemptedAt = _now();
    final count = (_records[url]?.consecutiveFailures ?? 0) + 1;
    final scheduleIndex = (count - 1).clamp(
      0,
      kFailureBackoffMinutes.length - 1,
    );
    final scheduledDelay = Duration(
      minutes: kFailureBackoffMinutes[scheduleIndex],
    );
    final delay = retryAfter != null && retryAfter > scheduledDelay
        ? retryAfter
        : scheduledDelay;
    final record = MetadataRefreshRecord(
      url: url,
      lastAttemptAt: attemptedAt,
      lastFailureKind: kind,
      lastStatusCode: statusCode,
      consecutiveFailures: count,
      nextRetryAt: attemptedAt.add(delay),
    );
    _invalidateHydration(url);
    _records[url] = record;

    final persistence = _persistence;
    if (persistence == null) return Future.value(record);
    return _enqueuePersistence(
      url,
      () => persistence.setRefreshRecord(record),
    ).then((_) => record);
  }

  /// Clear retry state after a successful refresh.
  ///
  /// Memory is cleared synchronously before persistence is awaited. Per-URL
  /// persistence ordering ensures this delete cannot overtake an earlier write.
  Future<void> recordSuccess(String url) {
    _invalidateHydration(url);
    _records.remove(url);
    final persistence = _persistence;
    if (persistence == null) return Future<void>.value();
    return _enqueuePersistence(
      url,
      () => persistence.removeRefreshRecord(url),
    );
  }

  /// Whether the URL may be attempted now.
  ///
  /// A manual attempt bypasses the deadline without mutating either memory or
  /// persistence. Only [recordSuccess] clears failure history.
  bool shouldRetry(String url, {bool manual = false}) {
    if (manual) return true;
    final deadline = _records[url]?.nextRetryAt;
    return deadline == null || !_now().isBefore(deadline);
  }

  /// The current retry deadline, if this URL has failure history.
  DateTime? nextRetryAt(String url) => _records[url]?.nextRetryAt;

  /// The complete in-memory retry record for [url].
  MetadataRefreshRecord? recordFor(String url) => _records[url];

  /// Temporary Task 6 compatibility adapter.
  @Deprecated("Use recordFor(url)?.consecutiveFailures; remove after Task 6.")
  int failureCount(String url) => _records[url]?.consecutiveFailures ?? 0;

  /// Temporary Task 6 compatibility adapter for successful fetches.
  @Deprecated("Use and await recordSuccess; remove after Task 6.")
  void clearFailure(String url) {
    unawaited(recordSuccess(url));
  }

  /// Drop records that have not been attempted in a long time.
  void cleanupStale() {
    final now = _now();
    final cutoff = now.subtract(kFailureStaleAge);
    final staleUrls = _records.entries
        .where((entry) {
          final record = entry.value;
          return record.lastAttemptAt.isBefore(cutoff) &&
              (record.nextRetryAt == null || !record.nextRetryAt!.isAfter(now));
        })
        .map((entry) => entry.key)
        .toList(growable: false);
    final persistence = _persistence;
    for (final url in staleUrls) {
      _invalidateHydration(url);
      _records.remove(url);
      if (persistence != null) {
        unawaited(_enqueuePersistence(
          url,
          () => persistence.removeRefreshRecord(url),
        ));
      }
    }
  }

  /// Clear in-memory compatibility state before the cache's atomic user clear.
  ///
  /// Persistence clearing belongs to `MetadataPersistence.clearAll`, which can
  /// delete snapshot and retry tables in one transaction. Queued operations
  /// that have not started are invalidated so they cannot repopulate that clear.
  @Deprecated("Use persistence clearing through Task 6 orchestration.")
  void clearAll() {
    _persistenceEpoch++;
    final affectedUrls = <String>{
      ..._records.keys,
      ..._hydrations.keys,
      ..._persistenceTails.keys,
    };
    for (final url in affectedUrls) {
      _invalidateHydration(url);
    }
    _records.clear();
  }

  Future<void> _loadHydration(
    String url,
    MetadataRefreshPersistence persistence,
    Object token,
  ) async {
    try {
      if (!identical(_hydrationTokens[url], token)) return;
      final record = await persistence.getRefreshRecord(url);
      if (!identical(_hydrationTokens[url], token)) return;
      if (record == null) {
        _records.remove(url);
      } else {
        _records[url] = record;
      }
    } catch (_) {
      // Persistence failure must not disable in-process retry tracking.
    }
  }

  Future<void> _enqueuePersistence(
    String url,
    Future<void> Function() operation,
  ) {
    final previous = _persistenceTails[url] ?? Future<void>.value();
    final epoch = _persistenceEpoch;
    final next = previous.then((_) async {
      if (epoch != _persistenceEpoch) return;
      await _ignorePersistenceErrors(operation);
    });
    _persistenceTails[url] = next;
    unawaited(next.then((_) {
      if (identical(_persistenceTails[url], next)) {
        _persistenceTails.remove(url);
      }
    }));
    return next;
  }

  void _invalidateHydration(String url) => _hydrationTokens.remove(url);

  Future<void> _ignorePersistenceErrors(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
    } catch (_) {
      // In-memory retry state remains authoritative for this process.
    }
  }
}
