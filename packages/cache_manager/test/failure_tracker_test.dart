import "dart:async";

import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";

class MutableClock {
  DateTime now;

  MutableClock(this.now);

  DateTime call() => now;
}

class FakeMetadataRefreshPersistence implements MetadataRefreshPersistence {
  final Map<String, MetadataRefreshRecord> records = {};

  @override
  Future<void> clearAllRefreshRecords() async => records.clear();

  @override
  Future<MetadataRefreshRecord?> getRefreshRecord(String url) async =>
      records[url];

  @override
  Future<void> removeRefreshRecord(String url) async => records.remove(url);

  @override
  Future<void> setRefreshRecord(MetadataRefreshRecord record) async {
    records[record.url] = record;
  }
}

class ControlledMetadataRefreshPersistence
    implements MetadataRefreshPersistence {
  final Map<String, MetadataRefreshRecord> records = {};
  final Map<String, Completer<void>> setGates = {};
  Completer<MetadataRefreshRecord?>? getGate;
  bool failRemoves = false;
  bool failSets = false;
  int getCalls = 0;

  @override
  Future<void> clearAllRefreshRecords() async => records.clear();

  @override
  Future<MetadataRefreshRecord?> getRefreshRecord(String url) async {
    getCalls++;
    final gate = getGate;
    return gate == null ? records[url] : gate.future;
  }

  @override
  Future<void> removeRefreshRecord(String url) async {
    if (failRemoves) throw StateError("remove failed");
    records.remove(url);
  }

  @override
  Future<void> setRefreshRecord(MetadataRefreshRecord record) async {
    final gate = setGates[record.url];
    if (gate != null) await gate.future;
    if (failSets) throw StateError("set failed");
    records[record.url] = record;
  }
}

void main() {
  late FailureTracker tracker;

  setUp(() {
    tracker = FailureTracker();
  });

  group("FailureTracker persistent schedule", () {
    const url = "https://example.com/post";
    final initialNow = DateTime.utc(2026, 8, 9, 10);
    late MutableClock clock;
    late FakeMetadataRefreshPersistence persistence;

    setUp(() {
      clock = MutableClock(initialNow);
      persistence = FakeMetadataRefreshPersistence();
      tracker = FailureTracker(now: clock.call, persistence: persistence);
    });

    test("uses every backoff step after incrementing the failure count",
        () async {
      const expectedDelays = <Duration>[
        Duration(minutes: 2),
        Duration(minutes: 10),
        Duration(hours: 1),
        Duration(hours: 6),
        Duration(hours: 24),
        Duration(hours: 24),
      ];

      for (final delay in expectedDelays) {
        final record = await tracker.recordFailure(
          url,
          kind: MetadataFailureKind.transport,
        );
        expect(record.nextRetryAt, initialNow.add(delay));
      }
    });

    test("becomes retryable exactly at the persisted deadline", () async {
      await tracker.recordFailure(
        url,
        kind: MetadataFailureKind.timeout,
      );

      expect(tracker.shouldRetry(url), isFalse);
      clock.now = initialNow.add(const Duration(minutes: 2));
      expect(tracker.shouldRetry(url), isTrue);
    });

    test("Retry-After replaces backoff only when it is longer", () async {
      final long = await tracker.recordFailure(
        url,
        kind: MetadataFailureKind.rateLimited,
        retryAfter: const Duration(hours: 2),
      );
      expect(long.nextRetryAt, initialNow.add(const Duration(hours: 2)));

      final short = await tracker.recordFailure(
        "https://example.com/other",
        kind: MetadataFailureKind.rateLimited,
        retryAfter: const Duration(minutes: 1),
      );
      expect(short.nextRetryAt, initialNow.add(const Duration(minutes: 2)));
    });

    test("hydrates persisted retry state after restart", () async {
      await tracker.recordFailure(
        url,
        kind: MetadataFailureKind.httpStatus,
        statusCode: 503,
      );

      final restarted = FailureTracker(
        now: clock.call,
        persistence: persistence,
      );
      await restarted.hydrate(url);

      expect(restarted.shouldRetry(url), isFalse);
      expect(restarted.recordFor(url)!.lastFailureKind,
          MetadataFailureKind.httpStatus);
      expect(restarted.recordFor(url)!.lastStatusCode, 503);
      expect(restarted.failureCount(url), 1);
    });

    test("coalesces concurrent hydration for the same URL", () async {
      final controlled = ControlledMetadataRefreshPersistence();
      controlled.getGate = Completer<MetadataRefreshRecord?>();
      tracker = FailureTracker(now: clock.call, persistence: controlled);

      final first = tracker.hydrate(url);
      final second = tracker.hydrate(url);
      controlled.getGate!.complete(null);
      await Future.wait([first, second]);

      expect(controlled.getCalls, 1);
    });

    test("delayed hydration cannot overwrite a newer failure", () async {
      final controlled = ControlledMetadataRefreshPersistence();
      controlled.getGate = Completer<MetadataRefreshRecord?>();
      tracker = FailureTracker(now: clock.call, persistence: controlled);
      final old = MetadataRefreshRecord(
        url: url,
        lastAttemptAt: initialNow.subtract(const Duration(days: 1)),
        lastFailureKind: MetadataFailureKind.timeout,
        consecutiveFailures: 4,
        nextRetryAt: initialNow.subtract(const Duration(hours: 1)),
      );

      final hydration = tracker.hydrate(url);
      final failure = tracker.recordFailure(
        url,
        kind: MetadataFailureKind.transport,
      );
      controlled.getGate!.complete(old);
      await Future.wait([hydration, failure]);

      expect(tracker.recordFor(url)!.lastFailureKind,
          MetadataFailureKind.transport);
      expect(tracker.recordFor(url)!.consecutiveFailures, 1);
    });

    test("delayed empty hydration cannot remove a newer failure", () async {
      final controlled = ControlledMetadataRefreshPersistence();
      controlled.getGate = Completer<MetadataRefreshRecord?>();
      tracker = FailureTracker(now: clock.call, persistence: controlled);

      final hydration = tracker.hydrate(url);
      final failure = tracker.recordFailure(
        url,
        kind: MetadataFailureKind.httpStatus,
        statusCode: 503,
      );
      controlled.getGate!.complete(null);
      await Future.wait([hydration, failure]);

      expect(tracker.recordFor(url)!.lastStatusCode, 503);
      expect(tracker.failureCount(url), 1);
    });

    test("success deletion waits for a slow failure upsert", () async {
      final controlled = ControlledMetadataRefreshPersistence();
      controlled.setGates[url] = Completer<void>();
      tracker = FailureTracker(now: clock.call, persistence: controlled);

      final failure = tracker.recordFailure(
        url,
        kind: MetadataFailureKind.transport,
      );
      final success = tracker.recordSuccess(url);
      expect(tracker.recordFor(url), isNull);

      controlled.setGates[url]!.complete();
      await Future.wait([failure, success]);

      expect(controlled.records[url], isNull);
    });

    test("failed delete blocks hydrate until a later delete succeeds",
        () async {
      final controlled = ControlledMetadataRefreshPersistence();
      controlled.setGates[url] = Completer<void>();
      tracker = FailureTracker(now: clock.call, persistence: controlled);
      final failure = tracker.recordFailure(
        url,
        kind: MetadataFailureKind.transport,
      );
      controlled.failRemoves = true;
      final success = tracker.recordSuccess(url);

      controlled.setGates[url]!.complete();
      await Future.wait([failure, success]);
      await tracker.hydrate(url);

      expect(tracker.recordFor(url), isNull);

      controlled.failRemoves = false;
      await tracker.recordSuccess(url);
      final restored = MetadataRefreshRecord(
        url: url,
        lastAttemptAt: initialNow.add(const Duration(hours: 1)),
        lastFailureKind: MetadataFailureKind.timeout,
        consecutiveFailures: 2,
        nextRetryAt: initialNow.add(const Duration(hours: 2)),
      );
      controlled.records[url] = restored;

      await tracker.hydrate(url);

      expect(tracker.recordFor(url), restored);
    });

    test("failed upsert keeps newer memory authoritative during hydrate",
        () async {
      final controlled = ControlledMetadataRefreshPersistence();
      final old = MetadataRefreshRecord(
        url: url,
        lastAttemptAt: initialNow.subtract(const Duration(days: 1)),
        lastFailureKind: MetadataFailureKind.timeout,
        consecutiveFailures: 4,
        nextRetryAt: initialNow.subtract(const Duration(hours: 1)),
      );
      controlled.records[url] = old;
      controlled.failSets = true;
      tracker = FailureTracker(now: clock.call, persistence: controlled);

      final newer = await tracker.recordFailure(
        url,
        kind: MetadataFailureKind.blocked,
      );
      await tracker.hydrate(url);

      expect(tracker.recordFor(url), same(newer));
    });

    test("explicit hydration remains usable after a completed mutation",
        () async {
      final persistence = FakeMetadataRefreshPersistence();
      tracker = FailureTracker(now: clock.call, persistence: persistence);
      await tracker.recordFailure(
        url,
        kind: MetadataFailureKind.transport,
      );
      await tracker.recordSuccess(url);
      final restored = MetadataRefreshRecord(
        url: url,
        lastAttemptAt: initialNow.add(const Duration(hours: 1)),
        lastFailureKind: MetadataFailureKind.timeout,
        consecutiveFailures: 2,
        nextRetryAt: initialNow.add(const Duration(hours: 2)),
      );
      await persistence.setRefreshRecord(restored);

      await tracker.hydrate(url);

      expect(tracker.recordFor(url), restored);
    });
    test("manual bypass is read-only and keeps persisted history", () async {
      final recorded = await tracker.recordFailure(
        url,
        kind: MetadataFailureKind.blocked,
      );

      expect(tracker.shouldRetry(url, manual: true), isTrue);
      expect(tracker.recordFor(url), same(recorded));
      expect(persistence.records[url], same(recorded));
      expect(tracker.shouldRetry(url), isFalse);
    });

    test("success clears memory and persistence", () async {
      await tracker.recordFailure(
        url,
        kind: MetadataFailureKind.transport,
      );

      await tracker.recordSuccess(url);

      expect(tracker.recordFor(url), isNull);
      expect(tracker.nextRetryAt(url), isNull);
      expect(tracker.shouldRetry(url), isTrue);
      expect(persistence.records[url], isNull);
    });

    test("legacy ignored Future updates memory synchronously", () {
      tracker.recordFailure(url);

      expect(tracker.failureCount(url), 1);
      expect(
          tracker.nextRetryAt(url), initialNow.add(const Duration(minutes: 2)));
    });
  });

  group("FailureTracker shouldRetry", () {
    test("returns true for never-failed URL", () {
      expect(tracker.shouldRetry("https://new.com"), isTrue);
    });

    test("returns false immediately after first failure", () {
      tracker.recordFailure("https://fail.com");
      // First back-off step is 2 minutes; immediately after, no retry.
      expect(tracker.shouldRetry("https://fail.com"), isFalse);
    });

    test("clearFailure resets retry to true", () {
      tracker.recordFailure("https://fail.com");
      expect(tracker.shouldRetry("https://fail.com"), isFalse);

      tracker.clearFailure("https://fail.com");
      expect(tracker.shouldRetry("https://fail.com"), isTrue);
    });

    test("many failures don't crash or permanently block past the cap", () {
      // Record more failures than the schedule has entries; the
      // back-off should cap at the last step (24 hr) — still no
      // immediate retry, but the call itself must not throw.
      for (var i = 0; i < 20; i++) {
        tracker.recordFailure("https://fail.com");
      }
      expect(tracker.shouldRetry("https://fail.com"), isFalse);

      tracker.clearFailure("https://fail.com");
      expect(tracker.shouldRetry("https://fail.com"), isTrue);
    });

    test("failure tracking is per-URL", () {
      tracker.recordFailure("https://bad.com");
      expect(tracker.shouldRetry("https://bad.com"), isFalse);
      expect(tracker.shouldRetry("https://good.com"), isTrue);
    });
  });

  group("FailureTracker failureCount", () {
    test("zero for never-failed URL", () {
      expect(tracker.failureCount("https://x.com"), 0);
    });

    test("increments on each recordFailure", () {
      tracker.recordFailure("https://x.com");
      expect(tracker.failureCount("https://x.com"), 1);

      tracker.recordFailure("https://x.com");
      expect(tracker.failureCount("https://x.com"), 2);
    });

    test("clearFailure resets to zero", () {
      tracker.recordFailure("https://x.com");
      tracker.recordFailure("https://x.com");
      tracker.clearFailure("https://x.com");
      expect(tracker.failureCount("https://x.com"), 0);
    });
  });

  group("FailureTracker cleanupStale", () {
    test("recent failures survive cleanup", () {
      tracker.recordFailure("https://recent.com");
      tracker.cleanupStale();
      // Recent failure was not purged — still blocked by back-off.
      expect(tracker.shouldRetry("https://recent.com"), isFalse);
    });

    test("keeps an aged record while Retry-After is still active", () async {
      final clock = MutableClock(DateTime.utc(2026, 8, 9));
      tracker = FailureTracker(now: clock.call);
      await tracker.recordFailure(
        "https://slow.example",
        kind: MetadataFailureKind.rateLimited,
        retryAfter: const Duration(days: 60),
      );
      clock.now = DateTime.utc(2026, 9, 9);

      tracker.cleanupStale();

      expect(tracker.shouldRetry("https://slow.example"), isFalse);
      expect(
        tracker.nextRetryAt("https://slow.example"),
        DateTime.utc(2026, 10, 8),
      );
    });

    test("safe to call with no recorded failures", () {
      tracker.cleanupStale();
      expect(tracker.shouldRetry("https://anything.com"), isTrue);
    });

    test("clearFailure + cleanupStale leaves clean state", () {
      tracker.recordFailure("https://a.com");
      tracker.recordFailure("https://b.com");
      tracker.clearFailure("https://a.com");
      tracker.cleanupStale();

      // a.com was cleared explicitly.
      expect(tracker.shouldRetry("https://a.com"), isTrue);
      // b.com is recent — still blocked.
      expect(tracker.shouldRetry("https://b.com"), isFalse);
    });
  });

  group("FailureTracker clearAll", () {
    test("wipes all tracked failures", () {
      tracker.recordFailure("https://a.com");
      tracker.recordFailure("https://b.com");
      tracker.clearAll();

      expect(tracker.shouldRetry("https://a.com"), isTrue);
      expect(tracker.shouldRetry("https://b.com"), isTrue);
      expect(tracker.failureCount("https://a.com"), 0);
      expect(tracker.failureCount("https://b.com"), 0);
    });
  });
}
