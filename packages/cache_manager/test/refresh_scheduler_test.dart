import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";

Metadata _meta(
  String url, {
  DateTime? fetchedAt,
  int ttlDays = 7,
  int consecutiveUnchanged = 0,
}) {
  return Metadata(
    url: url,
    fetchedAt: fetchedAt ?? DateTime.now(),
    ttlDays: ttlDays,
    consecutiveUnchanged: consecutiveUnchanged,
  );
}

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
        _meta(
          "https://low.com",
          fetchedAt: now.subtract(const Duration(days: 8)),
          consecutiveUnchanged: 5,
        ),
        _meta(
          "https://high.com",
          fetchedAt: now.subtract(const Duration(days: 30)),
        ),
        _meta(
          "https://mid.com",
          fetchedAt: now.subtract(const Duration(days: 14)),
          consecutiveUnchanged: 1,
        ),
      ];

      final queue = RefreshScheduler.buildQueue(entries, now: now);

      expect(queue[0].url, "https://high.com");
      expect(queue.last.url, "https://low.com");
    });

    test("buildQueue excludes non-expired entries", () {
      final now = DateTime.now();
      final entries = [
        _meta(
          "https://fresh.com",
          fetchedAt: now.subtract(const Duration(days: 3)),
        ),
        _meta(
          "https://stale.com",
          fetchedAt: now.subtract(const Duration(days: 10)),
        ),
      ];

      final queue = RefreshScheduler.buildQueue(entries, now: now);

      expect(queue.length, 1);
      expect(queue[0].url, "https://stale.com");
    });

    test("processQueue calls refreshOne for each expired entry in order",
        () async {
      final now = DateTime.now();
      final refreshedUrls = <String>[];

      final fakePersistence = _FakePersistenceWithExpired([
        _meta("https://a.com", fetchedAt: now.subtract(const Duration(days: 20))),
        _meta("https://b.com", fetchedAt: now.subtract(const Duration(days: 10))),
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
        _meta("https://a.com", fetchedAt: now.subtract(const Duration(days: 20))),
        _meta("https://b.com", fetchedAt: now.subtract(const Duration(days: 10))),
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
        _meta("https://a.com", fetchedAt: now.subtract(const Duration(days: 20))),
        _meta("https://b.com", fetchedAt: now.subtract(const Duration(days: 10))),
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
  final List<Metadata> _expired;
  _FakePersistenceWithExpired(this._expired);

  @override
  Future<List<Metadata>> getExpiredEntries() async => _expired;

  @override
  Future<Metadata?> get(String url) async => null;
  @override
  Future<void> set(Metadata metadata) async {}
  @override
  Future<void> remove(String url) async {}
  @override
  Future<void> clearAll() async {}
  @override
  Future<int> count() async => 0;
}
