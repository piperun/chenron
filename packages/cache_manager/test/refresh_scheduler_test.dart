import "dart:async";
import "dart:math";

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

    test("processQueue caps active workers and summarizes every outcome",
        () async {
      final now = DateTime.now();
      var active = 0;
      var maxObserved = 0;
      final gate = Completer<void>();
      final outcomes = MetadataRefreshOutcome.values;

      final fakePersistence = _FakePersistenceWithExpired([
        for (var index = 0; index < outcomes.length; index++)
          _meta(
            "https://example.com/$index",
            fetchedAt: now.subtract(Duration(days: 20 - index)),
          ),
      ]);

      final future = RefreshScheduler.processQueue(
        persistence: fakePersistence,
        refreshOne: (url) async {
          active++;
          maxObserved = max(maxObserved, active);
          await gate.future;
          active--;
          final index = int.parse(Uri.parse(url).pathSegments.single);
          return _result(url, outcomes[index]);
        },
        maxConcurrent: 3,
      );

      await pumpEventQueue();
      expect(maxObserved, 3);

      gate.complete();
      final summary = await future;

      expect(summary.updated, 1);
      expect(summary.unchanged, 1);
      expect(summary.skipped, 1);
      expect(summary.rejected, 1);
      expect(summary.failed, 1);
      expect(summary.total, outcomes.length);
    });

    test("processQueue deduplicates URLs and continues after failures",
        () async {
      final now = DateTime.now();
      final processed = <String>[];

      final fakePersistence = _FakePersistenceWithExpired([
        _meta(
          "https://rejected.example/item",
          fetchedAt: now.subtract(const Duration(days: 30)),
        ),
        _meta(
          "https://failed.example/item",
          fetchedAt: now.subtract(const Duration(days: 25)),
        ),
        _meta(
          "https://later.example/item",
          fetchedAt: now.subtract(const Duration(days: 20)),
        ),
        _meta(
          "https://later.example/item",
          fetchedAt: now.subtract(const Duration(days: 10)),
        ),
      ]);

      final summary = await RefreshScheduler.processQueue(
        persistence: fakePersistence,
        refreshOne: (url) async {
          processed.add(url);
          return _result(
            url,
            switch (Uri.parse(url).host) {
              "rejected.example" => MetadataRefreshOutcome.rejected,
              "failed.example" => MetadataRefreshOutcome.failed,
              _ => MetadataRefreshOutcome.updated,
            },
          );
        },
        maxConcurrent: 1,
      );

      expect(processed, [
        "https://rejected.example/item",
        "https://failed.example/item",
        "https://later.example/item",
      ]);
      expect(summary.rejected, 1);
      expect(summary.failed, 1);
      expect(summary.updated, 1);
      expect(summary.total, 3);
    });

    test("processQueue stops when shouldStop returns true", () async {
      final now = DateTime.now();
      var callCount = 0;

      final fakePersistence = _FakePersistenceWithExpired([
        _meta("https://a.com",
            fetchedAt: now.subtract(const Duration(days: 20))),
        _meta("https://b.com",
            fetchedAt: now.subtract(const Duration(days: 10))),
      ]);

      final summary = await RefreshScheduler.processQueue(
        persistence: fakePersistence,
        refreshOne: (url) async {
          callCount++;
          return _result(url, MetadataRefreshOutcome.updated);
        },
        shouldStop: () => callCount >= 1,
        maxConcurrent: 1,
      );

      expect(summary.updated, 1);
      expect(summary.total, 1);
    });
    test("processQueue rejects a non-positive worker cap", () async {
      final now = DateTime.now();
      final fakePersistence = _FakePersistenceWithExpired([
        _meta(
          "https://example.com/item",
          fetchedAt: now.subtract(const Duration(days: 20)),
        ),
      ]);

      await expectLater(
        RefreshScheduler.processQueue(
          persistence: fakePersistence,
          refreshOne: (url) async =>
              _result(url, MetadataRefreshOutcome.updated),
          maxConcurrent: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}

MetadataRefreshResult _result(
  String url,
  MetadataRefreshOutcome outcome,
) =>
    MetadataRefreshResult(
      url: url,
      outcome: outcome,
      state: const MetadataState.unavailable(),
    );

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
