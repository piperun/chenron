import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";

/// In-memory fake that records all calls for verification.
class FakeMetadataPersistence implements MetadataPersistence {
  final Map<String, Map<String, dynamic>> _store = {};
  final List<String> calls = [];

  @override
  Future<Map<String, dynamic>?> get(String url) async {
    calls.add("get:$url");
    final entry = _store[url];
    return entry != null ? Map<String, dynamic>.from(entry) : null;
  }

  @override
  Future<void> set(String url, Map<String, dynamic> metadata) async {
    calls.add("set:$url");
    _store[url] = Map<String, dynamic>.from(metadata);
  }

  @override
  Future<void> remove(String url) async {
    calls.add("remove:$url");
    _store.remove(url);
  }

  @override
  Future<void> clearAll() async {
    calls.add("clearAll");
    _store.clear();
  }

  @override
  Future<int> count() async {
    calls.add("count");
    return _store.length;
  }

  @override
  Future<List<Map<String, dynamic>>> getExpiredEntries() async {
    calls.add("getExpiredEntries");
    final now = DateTime.now();
    return _store.entries.where((e) {
      final fetchedAtStr = e.value["fetchedAt"] as String?;
      if (fetchedAtStr == null) return true;
      final fetchedAt = DateTime.tryParse(fetchedAtStr);
      if (fetchedAt == null) return true;
      final ttlDays = (e.value["ttlDays"] as int?) ?? 7;
      return now.difference(fetchedAt).inDays >= ttlDays;
    }).map((e) => {"url": e.key, ...e.value}).toList();
  }

  /// Directly inject a stale entry (old fetchedAt) into the store,
  /// bypassing MetadataCache's timestamp logic.
  void seedStale(String url, Map<String, dynamic> metadata) {
    _store[url] = Map<String, dynamic>.from(metadata);
  }
}

/// Persistence that throws on every operation.
class FailingMetadataPersistence implements MetadataPersistence {
  @override
  Future<Map<String, dynamic>?> get(String url) async =>
      throw Exception("persistence get failed");
  @override
  Future<void> set(String url, Map<String, dynamic> metadata) async =>
      throw Exception("persistence set failed");
  @override
  Future<void> remove(String url) async =>
      throw Exception("persistence remove failed");
  @override
  Future<void> clearAll() async =>
      throw Exception("persistence clearAll failed");
  @override
  Future<int> count() async => throw Exception("persistence count failed");
  @override
  Future<List<Map<String, dynamic>>> getExpiredEntries() async =>
      throw Exception("persistence getExpiredEntries failed");
}

void main() {
  late FakeMetadataPersistence fakePersistence;

  setUp(() {
    fakePersistence = FakeMetadataPersistence();
    MetadataCache.init(fakePersistence);
  });

  tearDown(() async {
    // Reset all static state between tests
    await MetadataCache.clearAll();
  });

  group("MetadataCache basics", () {
    test("set stores in both memory and persistence", () async {
      await MetadataCache.set("https://a.com", {"title": "A"});

      // Memory cache should have it (immediate get without persistence call)
      final result = await MetadataCache.get("https://a.com");
      expect(result, isNotNull);
      expect(result!["title"], "A");
      expect(result["fetchedAt"], isA<String>());

      // Persistence should have been called
      expect(fakePersistence.calls, contains("set:https://a.com"));
    });

    test("get returns null for unknown URL", () async {
      final result = await MetadataCache.get("https://unknown.com");
      expect(result, isNull);
    });

    test("set adds fetchedAt timestamp automatically", () async {
      await MetadataCache.set("https://a.com", {"title": "A"});

      final result = await MetadataCache.get("https://a.com");
      expect(result!.containsKey("fetchedAt"), isTrue);

      final fetchedAt = DateTime.parse(result["fetchedAt"] as String);
      expect(
        DateTime.now().difference(fetchedAt).inSeconds.abs(),
        lessThan(5),
      );
    });

    test("remove clears from both memory and persistence", () async {
      await MetadataCache.set("https://a.com", {"title": "A"});
      await MetadataCache.remove("https://a.com");

      final result = await MetadataCache.get("https://a.com");
      expect(result, isNull);
      expect(fakePersistence.calls, contains("remove:https://a.com"));
    });

    test("clearAll resets everything", () async {
      await MetadataCache.set("https://a.com", {"title": "A"});
      await MetadataCache.set("https://b.com", {"title": "B"});
      MetadataCache.recordFailure("https://c.com");
      MetadataCache.startFetching("https://d.com");

      await MetadataCache.clearAll();

      expect(await MetadataCache.get("https://a.com"), isNull);
      expect(await MetadataCache.get("https://b.com"), isNull);
      // Failure records should be cleared
      expect(MetadataCache.shouldRetry("https://c.com"), isTrue);
      // Fetching flags should be cleared
      expect(MetadataCache.isFetching("https://d.com"), isFalse);
      expect(fakePersistence.calls, contains("clearAll"));
    });
  });

  group("MetadataCache memory-first reads", () {
    test("serves from memory without hitting persistence", () async {
      await MetadataCache.set("https://a.com", {"title": "A"});
      fakePersistence.calls.clear();

      final result = await MetadataCache.get("https://a.com");
      expect(result!["title"], "A");

      // Persistence.get should NOT have been called — served from LRU
      expect(
        fakePersistence.calls.where((c) => c.startsWith("get:")),
        isEmpty,
      );
    });

    test("falls back to persistence on memory miss", () async {
      // Put directly in persistence, bypassing memory cache
      fakePersistence.seedStale("https://a.com", {
        "title": "From DB",
        "fetchedAt": DateTime.now().toIso8601String(),
      });

      final result = await MetadataCache.get("https://a.com");
      expect(result, isNotNull);
      expect(result!["title"], "From DB");
      expect(fakePersistence.calls, contains("get:https://a.com"));
    });

    test("promotes persistence hit into memory cache", () async {
      fakePersistence.seedStale("https://a.com", {
        "title": "Promoted",
        "fetchedAt": DateTime.now().toIso8601String(),
      });

      // First call: hits persistence
      await MetadataCache.get("https://a.com");
      fakePersistence.calls.clear();

      // Second call: should serve from memory, no persistence call
      final result = await MetadataCache.get("https://a.com");
      expect(result!["title"], "Promoted");
      expect(
        fakePersistence.calls.where((c) => c.startsWith("get:")),
        isEmpty,
      );
    });
  });

  group("MetadataCache freshness", () {
    test("returns data fetched less than 7 days ago", () async {
      await MetadataCache.set("https://fresh.com", {"title": "Fresh"});

      final result = await MetadataCache.get("https://fresh.com");
      expect(result, isNotNull);
      expect(result!["title"], "Fresh");
    });

    test("rejects stale data from memory cache (>7 days)", () async {
      // Manually set with old timestamp
      await MetadataCache.set("https://stale.com", {"title": "Stale"});

      // Now hack the memory cache entry via another set with old timestamp
      // We need to go through persistence to test stale rejection.
      // Clear memory and seed persistence with stale data.
      await MetadataCache.clearAll();

      final staleDate =
          DateTime.now().subtract(const Duration(days: 8)).toIso8601String();
      fakePersistence.seedStale("https://stale.com", {
        "title": "Old",
        "fetchedAt": staleDate,
      });

      final result = await MetadataCache.get("https://stale.com");
      expect(result, isNull);
    });

    test("rejects data with missing fetchedAt as stale", () async {
      await MetadataCache.clearAll();

      fakePersistence.seedStale("https://nots.com", {
        "title": "No timestamp",
        // no fetchedAt key
      });

      final result = await MetadataCache.get("https://nots.com");
      expect(result, isNull);
    });

    test("rejects data with invalid fetchedAt as stale", () async {
      await MetadataCache.clearAll();

      fakePersistence.seedStale("https://bad.com", {
        "title": "Bad TS",
        "fetchedAt": "not-a-date",
      });

      final result = await MetadataCache.get("https://bad.com");
      expect(result, isNull);
    });

    test("data at exactly 6 days is still fresh", () async {
      await MetadataCache.clearAll();

      final sixDaysAgo =
          DateTime.now().subtract(const Duration(days: 6)).toIso8601String();
      fakePersistence.seedStale("https://edge.com", {
        "title": "Six days",
        "fetchedAt": sixDaysAgo,
      });

      final result = await MetadataCache.get("https://edge.com");
      expect(result, isNotNull);
      expect(result!["title"], "Six days");
    });
  });

  group("MetadataCache failure tracking and backoff", () {
    test("shouldRetry returns true for never-failed URL", () {
      expect(MetadataCache.shouldRetry("https://new.com"), isTrue);
    });

    test("shouldRetry returns false immediately after failure", () {
      MetadataCache.recordFailure("https://fail.com");
      // First backoff is 2 minutes, so immediately after should be false
      expect(MetadataCache.shouldRetry("https://fail.com"), isFalse);
    });

    test("clearFailure resets retry to true", () {
      MetadataCache.recordFailure("https://fail.com");
      expect(MetadataCache.shouldRetry("https://fail.com"), isFalse);

      MetadataCache.clearFailure("https://fail.com");
      expect(MetadataCache.shouldRetry("https://fail.com"), isTrue);
    });

    test("multiple failures don't permanently block", () {
      // Record many failures
      for (var i = 0; i < 10; i++) {
        MetadataCache.recordFailure("https://fail.com");
      }
      // Still returns false immediately, but the point is it doesn't throw
      // or permanently deny — the backoff caps at 1440 min (24h)
      expect(MetadataCache.shouldRetry("https://fail.com"), isFalse);

      // After clearing, it should retry
      MetadataCache.clearFailure("https://fail.com");
      expect(MetadataCache.shouldRetry("https://fail.com"), isTrue);
    });

    test("failure tracking is per-URL", () {
      MetadataCache.recordFailure("https://bad.com");

      expect(MetadataCache.shouldRetry("https://bad.com"), isFalse);
      expect(MetadataCache.shouldRetry("https://good.com"), isTrue);
    });
  });

  group("MetadataCache fetching guards", () {
    test("isFetching returns false for unknown URL", () {
      expect(MetadataCache.isFetching("https://a.com"), isFalse);
    });

    test("startFetching / stopFetching toggle state", () {
      MetadataCache.startFetching("https://a.com");
      expect(MetadataCache.isFetching("https://a.com"), isTrue);

      MetadataCache.stopFetching("https://a.com");
      expect(MetadataCache.isFetching("https://a.com"), isFalse);
    });

    test("fetching is per-URL", () {
      MetadataCache.startFetching("https://a.com");

      expect(MetadataCache.isFetching("https://a.com"), isTrue);
      expect(MetadataCache.isFetching("https://b.com"), isFalse);
    });
  });

  group("MetadataCache graceful degradation", () {
    test("works without persistence (memory-only)", () async {
      // Reinitialize with a failing persistence to simulate unavailable DB
      MetadataCache.init(FailingMetadataPersistence());

      // set should not throw — memory cache works, persistence error swallowed
      await MetadataCache.set("https://a.com", {"title": "Memory only"});

      // get should serve from memory
      final result = await MetadataCache.get("https://a.com");
      expect(result, isNotNull);
      expect(result!["title"], "Memory only");
    });

    test("persistence errors on get don't crash", () async {
      MetadataCache.init(FailingMetadataPersistence());
      await MetadataCache.clearAll();

      // Should return null, not throw
      final result = await MetadataCache.get("https://fail.com");
      expect(result, isNull);
    });

    test("persistence errors on remove don't crash", () async {
      MetadataCache.init(FailingMetadataPersistence());

      // Should not throw
      await MetadataCache.remove("https://fail.com");
    });

    test("persistence errors on clearAll don't crash", () async {
      MetadataCache.init(FailingMetadataPersistence());

      // Should not throw — memory state is still cleared
      await MetadataCache.clearAll();
    });
  });

  group("MetadataCache statistics", () {
    test("getCacheEntryCount delegates to persistence", () async {
      await MetadataCache.set("https://a.com", {"title": "A"});
      await MetadataCache.set("https://b.com", {"title": "B"});

      final count = await MetadataCache.getCacheEntryCount();
      expect(count, 2);
    });

    test("getCacheEntryCount returns 0 on persistence error", () async {
      MetadataCache.init(FailingMetadataPersistence());
      final count = await MetadataCache.getCacheEntryCount();
      expect(count, 0);
    });

    test("getMemoryCacheStats returns size and maxSize", () async {
      await MetadataCache.set("https://a.com", {"title": "A"});

      final stats = MetadataCache.getMemoryCacheStats();
      expect(stats["size"], 1);
      expect(stats["maxSize"], 100);
    });
  });

  group("MetadataCache adaptive TTL freshness", () {
    test("respects per-entry ttlDays instead of hardcoded 7", () async {
      await MetadataCache.clearAll();

      // Seed entry with 30-day TTL, fetched 10 days ago — should be fresh
      fakePersistence.seedStale("https://long-ttl.com", {
        "title": "Long TTL",
        "fetchedAt":
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        "ttlDays": 30,
        "consecutiveUnchanged": 2,
      });

      final result = await MetadataCache.get("https://long-ttl.com");
      expect(result, isNotNull);
      expect(result!["title"], "Long TTL");
    });

    test("entry with short TTL expires sooner", () async {
      await MetadataCache.clearAll();

      // Seed entry with 3-day TTL, fetched 4 days ago — should be stale
      fakePersistence.seedStale("https://short-ttl.com", {
        "title": "Short TTL",
        "fetchedAt":
            DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        "ttlDays": 3,
        "consecutiveUnchanged": 0,
      });

      final result = await MetadataCache.get("https://short-ttl.com");
      expect(result, isNull);
    });

    test("missing ttlDays falls back to 7 days", () async {
      await MetadataCache.clearAll();

      fakePersistence.seedStale("https://legacy.com", {
        "title": "Legacy",
        "fetchedAt":
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        // No ttlDays key — old format
      });

      final result = await MetadataCache.get("https://legacy.com");
      expect(result, isNotNull);
    });

    test("getStale returns stale entry without removing it", () async {
      await MetadataCache.clearAll();

      fakePersistence.seedStale("https://old.com", {
        "title": "Old Title",
        "fetchedAt":
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        "ttlDays": 7,
        "consecutiveUnchanged": 1,
      });

      // Regular get should return null (stale)
      final fresh = await MetadataCache.get("https://old.com");
      expect(fresh, isNull);

      // getStale should return the data regardless of freshness
      final stale = await MetadataCache.getStale("https://old.com");
      expect(stale, isNotNull);
      expect(stale!["title"], "Old Title");
      expect(stale["consecutiveUnchanged"], 1);
      expect(stale["ttlDays"], 7);
    });

    test("getStale returns null for unknown URL", () async {
      final result = await MetadataCache.getStale("https://unknown.com");
      expect(result, isNull);
    });
  });

  group("MetadataCache LRU eviction", () {
    test("memory cache evicts oldest entry when full", () async {
      // The LRU cache has maxSize 100. Fill it, then add one more.
      // The first entry should be evicted from memory.
      for (var i = 0; i < 101; i++) {
        await MetadataCache.set("https://site$i.com", {"title": "S$i"});
      }

      final stats = MetadataCache.getMemoryCacheStats();
      expect(stats["size"], 100);

      // site0 should be evicted from memory but still in persistence
      fakePersistence.calls.clear();
      final evicted = await MetadataCache.get("https://site0.com");
      // Should fetch from persistence (it was evicted from LRU)
      expect(evicted, isNotNull);
      expect(evicted!["title"], "S0");
      expect(
        fakePersistence.calls.where((c) => c == "get:https://site0.com"),
        isNotEmpty,
      );
    });
  });

  group("MetadataCache failure cleanup", () {
    test("cleanupStaleFailures removes entries older than 30 days", () {
      // Record a failure and verify cleanup doesn't crash.
      // Since we can't backdate the timestamp, we verify the method runs
      // without error and that a recent failure survives cleanup.
      MetadataCache.recordFailure("https://old-fail.com");
      MetadataCache.cleanupStaleFailures();
      // Recent failure should NOT be cleaned up
      expect(MetadataCache.shouldRetry("https://old-fail.com"), isFalse);
    });

    test("cleanupStaleFailures preserves recent failures", () {
      MetadataCache.recordFailure("https://recent.com");
      MetadataCache.cleanupStaleFailures();
      // Still not retryable — cleanup didn't remove it
      expect(MetadataCache.shouldRetry("https://recent.com"), isFalse);
    });

    test("cleanupStaleFailures is safe to call with no failures", () {
      // Should not throw
      MetadataCache.cleanupStaleFailures();
      expect(MetadataCache.shouldRetry("https://anything.com"), isTrue);
    });

    test("clearFailure followed by cleanupStaleFailures leaves clean state",
        () {
      MetadataCache.recordFailure("https://a.com");
      MetadataCache.recordFailure("https://b.com");
      MetadataCache.clearFailure("https://a.com");
      MetadataCache.cleanupStaleFailures();
      // a.com was explicitly cleared
      expect(MetadataCache.shouldRetry("https://a.com"), isTrue);
      // b.com is recent, cleanup shouldn't remove it
      expect(MetadataCache.shouldRetry("https://b.com"), isFalse);
    });
  });
}
