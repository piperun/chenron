import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";

/// In-memory fake that records all calls for verification.
class FakeMetadataPersistence implements MetadataPersistence {
  final Map<String, Metadata> _store = {};
  final List<String> calls = [];

  @override
  Future<Metadata?> get(String url) async {
    calls.add("get:$url");
    return _store[url];
  }

  @override
  Future<void> set(Metadata metadata) async {
    calls.add("set:${metadata.url}");
    _store[metadata.url] = metadata;
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
  Future<List<Metadata>> getExpiredEntries() async {
    calls.add("getExpiredEntries");
    final now = DateTime.now();
    return _store.values
        .where((m) => now.difference(m.fetchedAt).inDays >= m.ttlDays)
        .toList();
  }

  /// Directly inject an entry (any age) into the store, bypassing
  /// MetadataCache's normal write path.
  void seed(Metadata metadata) {
    _store[metadata.url] = metadata;
  }
}

/// Persistence that throws on every operation.
class FailingMetadataPersistence implements MetadataPersistence {
  @override
  Future<Metadata?> get(String url) async =>
      throw Exception("persistence get failed");
  @override
  Future<void> set(Metadata metadata) async =>
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
  Future<List<Metadata>> getExpiredEntries() async =>
      throw Exception("persistence getExpiredEntries failed");
}

Metadata _meta(
  String url, {
  String? title,
  String? description,
  String? imageUrl,
  DateTime? fetchedAt,
  int ttlDays = 7,
  int consecutiveUnchanged = 0,
}) {
  return Metadata(
    url: url,
    title: title,
    description: description,
    imageUrl: imageUrl,
    fetchedAt: fetchedAt ?? DateTime.now(),
    ttlDays: ttlDays,
    consecutiveUnchanged: consecutiveUnchanged,
  );
}

void main() {
  late FakeMetadataPersistence fakePersistence;
  late MetadataCache cache;

  setUp(() {
    fakePersistence = FakeMetadataPersistence();
    cache = MetadataCache(persistence: fakePersistence);
  });

  tearDown(() async {
    await cache.clearAll();
  });

  group("MetadataCache basics", () {
    test("set stores in both memory and persistence", () async {
      final m = _meta("https://a.com", title: "A");
      await cache.set(m);

      final result = await cache.get("https://a.com");
      expect(result, isNotNull);
      expect(result!.title, "A");
      expect(fakePersistence.calls, contains("set:https://a.com"));
    });

    test("get returns null for unknown URL", () async {
      final result = await cache.get("https://unknown.com");
      expect(result, isNull);
    });

    test("set preserves fetchedAt timestamp from Metadata", () async {
      final ts = DateTime.now().subtract(const Duration(minutes: 1));
      final m = _meta("https://a.com", title: "A", fetchedAt: ts);
      await cache.set(m);

      final result = await cache.get("https://a.com");
      expect(result!.fetchedAt, ts);
    });

    test("remove clears from both memory and persistence", () async {
      await cache.set(_meta("https://a.com", title: "A"));
      await cache.remove("https://a.com");

      final result = await cache.get("https://a.com");
      expect(result, isNull);
      expect(fakePersistence.calls, contains("remove:https://a.com"));
    });

    test("clearAll resets memory + persistence", () async {
      await cache.set(_meta("https://a.com", title: "A"));
      await cache.set(_meta("https://b.com", title: "B"));

      await cache.clearAll();

      expect(await cache.get("https://a.com"), isNull);
      expect(await cache.get("https://b.com"), isNull);
      expect(fakePersistence.calls, contains("clearAll"));
    });
  });

  group("MetadataCache memory-first reads", () {
    test("serves from memory without hitting persistence", () async {
      await cache.set(_meta("https://a.com", title: "A"));
      fakePersistence.calls.clear();

      final result = await cache.get("https://a.com");
      expect(result!.title, "A");

      expect(
        fakePersistence.calls.where((c) => c.startsWith("get:")),
        isEmpty,
      );
    });

    test("falls back to persistence on memory miss", () async {
      fakePersistence.seed(_meta("https://a.com", title: "From DB"));

      final result = await cache.get("https://a.com");
      expect(result, isNotNull);
      expect(result!.title, "From DB");
      expect(fakePersistence.calls, contains("get:https://a.com"));
    });

    test("promotes persistence hit into memory cache", () async {
      fakePersistence.seed(_meta("https://a.com", title: "Promoted"));

      await cache.get("https://a.com");
      fakePersistence.calls.clear();

      final result = await cache.get("https://a.com");
      expect(result!.title, "Promoted");
      expect(
        fakePersistence.calls.where((c) => c.startsWith("get:")),
        isEmpty,
      );
    });
  });

  group("MetadataCache freshness", () {
    test("returns data fetched less than 7 days ago", () async {
      await cache.set(_meta("https://fresh.com", title: "Fresh"));

      final result = await cache.get("https://fresh.com");
      expect(result, isNotNull);
      expect(result!.title, "Fresh");
    });

    test("rejects stale data (>7 days, default TTL)", () async {
      fakePersistence.seed(_meta(
        "https://stale.com",
        title: "Old",
        fetchedAt: DateTime.now().subtract(const Duration(days: 8)),
      ));

      final result = await cache.get("https://stale.com");
      expect(result, isNull);
    });

    test("data at 6 days is still fresh", () async {
      fakePersistence.seed(_meta(
        "https://edge.com",
        title: "Six days",
        fetchedAt: DateTime.now().subtract(const Duration(days: 6)),
      ));

      final result = await cache.get("https://edge.com");
      expect(result, isNotNull);
      expect(result!.title, "Six days");
    });

    test("isFresh is true for fresh metadata", () {
      expect(cache.isFresh(_meta("https://x.com", title: "T")), isTrue);
    });

    test("isFresh is false for stale metadata", () {
      final stale = _meta(
        "https://x.com",
        title: "T",
        fetchedAt: DateTime.now().subtract(const Duration(days: 8)),
      );
      expect(cache.isFresh(stale), isFalse);
    });
  });

  group("MetadataCache graceful degradation", () {
    test("works without persistence (memory-only)", () async {
      cache = MetadataCache(persistence: FailingMetadataPersistence());

      // set should not throw — memory works, persistence error swallowed
      await cache.set(_meta("https://a.com", title: "Memory only"));

      final result = await cache.get("https://a.com");
      expect(result, isNotNull);
      expect(result!.title, "Memory only");
    });

    test("persistence errors on get don't crash", () async {
      cache = MetadataCache(persistence: FailingMetadataPersistence());
      final result = await cache.get("https://fail.com");
      expect(result, isNull);
    });

    test("persistence errors on remove don't crash", () async {
      cache = MetadataCache(persistence: FailingMetadataPersistence());
      await cache.remove("https://fail.com"); // must not throw
    });

    test("persistence errors on clearAll don't crash", () async {
      cache = MetadataCache(persistence: FailingMetadataPersistence());
      await cache.clearAll(); // must not throw — memory state cleared
    });
  });

  group("MetadataCache statistics", () {
    test("count delegates to persistence", () async {
      await cache.set(_meta("https://a.com", title: "A"));
      await cache.set(_meta("https://b.com", title: "B"));

      expect(await cache.count(), 2);
    });

    test("count returns 0 on persistence error", () async {
      cache = MetadataCache(persistence: FailingMetadataPersistence());
      expect(await cache.count(), 0);
    });

    test("memoryCacheSize / memoryCacheCapacity expose LRU stats", () async {
      await cache.set(_meta("https://a.com", title: "A"));
      expect(cache.memoryCacheSize, 1);
      expect(cache.memoryCacheCapacity, 100);
    });
  });

  group("MetadataCache adaptive TTL freshness", () {
    test("respects per-entry ttlDays instead of hardcoded 7", () async {
      fakePersistence.seed(_meta(
        "https://long-ttl.com",
        title: "Long TTL",
        fetchedAt: DateTime.now().subtract(const Duration(days: 10)),
        ttlDays: 30,
        consecutiveUnchanged: 2,
      ));

      final result = await cache.get("https://long-ttl.com");
      expect(result, isNotNull);
      expect(result!.title, "Long TTL");
    });

    test("entry with short TTL expires sooner", () async {
      fakePersistence.seed(_meta(
        "https://short-ttl.com",
        title: "Short TTL",
        fetchedAt: DateTime.now().subtract(const Duration(days: 4)),
        ttlDays: 3,
      ));

      final result = await cache.get("https://short-ttl.com");
      expect(result, isNull);
    });

    test("getStale returns stale entry without removing it", () async {
      fakePersistence.seed(_meta(
        "https://old.com",
        title: "Old Title",
        fetchedAt: DateTime.now().subtract(const Duration(days: 10)),
        ttlDays: 7,
        consecutiveUnchanged: 1,
      ));

      // Regular get returns null (stale).
      expect(await cache.get("https://old.com"), isNull);

      // getStale returns the entry regardless of freshness.
      final stale = await cache.getStale("https://old.com");
      expect(stale, isNotNull);
      expect(stale!.title, "Old Title");
      expect(stale.consecutiveUnchanged, 1);
      expect(stale.ttlDays, 7);
    });

    test("getStale returns null for unknown URL", () async {
      expect(await cache.getStale("https://unknown.com"), isNull);
    });
  });

  group("MetadataCache LRU eviction", () {
    test("memory cache evicts oldest entry when full", () async {
      // LRU capacity is 100. Fill it, then add one more.
      for (var i = 0; i < 101; i++) {
        await cache.set(_meta("https://site$i.com", title: "S$i"));
      }

      expect(cache.memoryCacheSize, 100);

      // site0 should be evicted from memory but still in persistence.
      fakePersistence.calls.clear();
      final evicted = await cache.get("https://site0.com");
      expect(evicted, isNotNull);
      expect(evicted!.title, "S0");
      expect(
        fakePersistence.calls.where((c) => c == "get:https://site0.com"),
        isNotEmpty,
      );
    });
  });
}
