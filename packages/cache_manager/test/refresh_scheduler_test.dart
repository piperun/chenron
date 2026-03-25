import "package:cache_manager/src/refresh_scheduler.dart";
import "package:cache_manager/src/metadata_persistence.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("computeRefreshPriority", () {
    test("higher staleness gives higher priority", () {
      final now = DateTime.now();
      final veryStale = computeRefreshPriority(
        fetchedAt: now.subtract(const Duration(days: 30)),
        ttlDays: 7,
        consecutiveUnchanged: 0,
        now: now,
      );
      final slightlyStale = computeRefreshPriority(
        fetchedAt: now.subtract(const Duration(days: 8)),
        ttlDays: 7,
        consecutiveUnchanged: 0,
        now: now,
      );
      expect(veryStale, greaterThan(slightlyStale));
    });

    test("more consecutive unchanged reduces priority", () {
      final now = DateTime.now();
      final neverChanged = computeRefreshPriority(
        fetchedAt: now.subtract(const Duration(days: 14)),
        ttlDays: 7,
        consecutiveUnchanged: 5,
        now: now,
      );
      final alwaysChanges = computeRefreshPriority(
        fetchedAt: now.subtract(const Duration(days: 14)),
        ttlDays: 7,
        consecutiveUnchanged: 0,
        now: now,
      );
      expect(alwaysChanges, greaterThan(neverChanged));
    });

    test("fresh entries get zero or negative priority", () {
      final now = DateTime.now();
      final fresh = computeRefreshPriority(
        fetchedAt: now.subtract(const Duration(days: 3)),
        ttlDays: 7,
        consecutiveUnchanged: 0,
        now: now,
      );
      expect(fresh, lessThanOrEqualTo(0));
    });
  });

  group("RefreshScheduler", () {
    test("buildQueue returns URLs sorted by descending priority", () {
      final now = DateTime.now();
      final entries = [
        {
          "url": "https://low.com",
          "fetchedAt": now.subtract(const Duration(days: 8)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 5,
        },
        {
          "url": "https://high.com",
          "fetchedAt": now.subtract(const Duration(days: 30)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 0,
        },
        {
          "url": "https://mid.com",
          "fetchedAt": now.subtract(const Duration(days: 14)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 1,
        },
      ];

      final queue = RefreshScheduler.buildQueue(entries, now: now);

      expect(queue[0]["url"], "https://high.com");
      expect(queue.last["url"], "https://low.com");
    });

    test("buildQueue excludes non-expired entries", () {
      final now = DateTime.now();
      final entries = [
        {
          "url": "https://fresh.com",
          "fetchedAt": now.subtract(const Duration(days: 3)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 0,
        },
        {
          "url": "https://stale.com",
          "fetchedAt": now.subtract(const Duration(days: 10)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 0,
        },
      ];

      final queue = RefreshScheduler.buildQueue(entries, now: now);

      expect(queue.length, 1);
      expect(queue[0]["url"], "https://stale.com");
    });

    test("buildQueue handles missing fields gracefully", () {
      final now = DateTime.now();
      final entries = [
        {
          "url": "https://legacy.com",
          "fetchedAt": now.subtract(const Duration(days: 10)).toIso8601String(),
        },
      ];

      final queue = RefreshScheduler.buildQueue(entries, now: now);
      expect(queue.length, 1);
    });

    test("processQueue calls refreshOne for each expired entry in order",
        () async {
      final now = DateTime.now();
      final refreshedUrls = <String>[];

      final fakePersistence = _FakePersistenceWithExpired([
        {
          "url": "https://a.com",
          "fetchedAt": now.subtract(const Duration(days: 20)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 0,
        },
        {
          "url": "https://b.com",
          "fetchedAt": now.subtract(const Duration(days: 10)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 0,
        },
      ]);

      final count = await RefreshScheduler.processQueue(
        persistence: fakePersistence,
        refreshOne: (url) async {
          refreshedUrls.add(url);
          return true;
        },
        delay: Duration.zero,
      );

      expect(count, 2);
      expect(refreshedUrls[0], "https://a.com");
      expect(refreshedUrls[1], "https://b.com");
    });

    test("processQueue stops when refreshOne returns false", () async {
      final now = DateTime.now();

      final fakePersistence = _FakePersistenceWithExpired([
        {
          "url": "https://a.com",
          "fetchedAt": now.subtract(const Duration(days: 20)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 0,
        },
        {
          "url": "https://b.com",
          "fetchedAt": now.subtract(const Duration(days: 10)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 0,
        },
      ]);

      final count = await RefreshScheduler.processQueue(
        persistence: fakePersistence,
        refreshOne: (url) async => false,
        delay: Duration.zero,
      );

      expect(count, 0);
    });

    test("processQueue stops when shouldStop returns true", () async {
      final now = DateTime.now();
      var callCount = 0;

      final fakePersistence = _FakePersistenceWithExpired([
        {
          "url": "https://a.com",
          "fetchedAt": now.subtract(const Duration(days: 20)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 0,
        },
        {
          "url": "https://b.com",
          "fetchedAt": now.subtract(const Duration(days: 10)).toIso8601String(),
          "ttlDays": 7,
          "consecutiveUnchanged": 0,
        },
      ]);

      final count = await RefreshScheduler.processQueue(
        persistence: fakePersistence,
        refreshOne: (url) async {
          callCount++;
          return true;
        },
        shouldStop: () => callCount >= 1,
        delay: Duration.zero,
      );

      expect(count, 1);
    });
  });
}

class _FakePersistenceWithExpired implements MetadataPersistence {
  final List<Map<String, dynamic>> _expired;
  _FakePersistenceWithExpired(this._expired);

  @override
  Future<List<Map<String, dynamic>>> getExpiredEntries() async => _expired;

  @override
  Future<Map<String, dynamic>?> get(String url) async => null;
  @override
  Future<void> set(String url, Map<String, dynamic> metadata) async {}
  @override
  Future<void> remove(String url) async {}
  @override
  Future<void> clearAll() async {}
  @override
  Future<int> count() async => 0;
}
