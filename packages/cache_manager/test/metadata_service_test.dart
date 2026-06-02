import "dart:async";

import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";
import "package:signals/signals.dart";

/// In-memory typed persistence backing the cache under test.
class _FakePersistence implements MetadataPersistence {
  final Map<String, Metadata> _store = {};

  @override
  Future<Metadata?> get(String url) async => _store[url];

  @override
  Future<void> set(Metadata metadata) async {
    _store[metadata.url] = metadata;
  }

  @override
  Future<void> remove(String url) async => _store.remove(url);

  @override
  Future<void> clearAll() async => _store.clear();

  @override
  Future<int> count() async => _store.length;

  @override
  Future<List<Metadata>> getExpiredEntries() async {
    final now = DateTime.now();
    return _store.values
        .where((m) => now.difference(m.fetchedAt).inDays >= m.ttlDays)
        .toList();
  }

  void seed(Metadata m) => _store[m.url] = m;
}

/// Programmable fake fetcher.
class _FakeFetcher {
  /// Per-URL canned response (or `null` to throw).
  final Map<String, RawFetchedMetadata?> responses = {};
  final List<String> calls = [];

  /// Resolves only after [release] is called for the URL — used to
  /// test in-flight coalescing and concurrency.
  final Map<String, Completer<void>> _gates = {};

  Future<RawFetchedMetadata> fetch(String url) async {
    calls.add(url);
    final gate = _gates[url];
    if (gate != null) await gate.future;
    final response = responses[url];
    if (response == null) throw Exception("boom: $url");
    return response;
  }

  void gate(String url) {
    _gates[url] = Completer<void>();
  }

  void release(String url) {
    _gates.remove(url)?.complete();
  }
}

void main() {
  late _FakePersistence persistence;
  late MetadataCache cache;
  late FailureTracker failures;
  late _FakeFetcher fetcher;

  setUp(() {
    persistence = _FakePersistence();
    cache = MetadataCache(persistence: persistence);
    failures = FailureTracker();
    fetcher = _FakeFetcher();
  });

  MetadataService buildService({
    int maxConcurrent = 3,
    Duration domainDelay = Duration.zero,
    OnFetchLogged? onFetchLogged,
  }) {
    return MetadataService(
      cache: cache,
      failures: failures,
      fetcher: fetcher.fetch,
      onFetchLogged: onFetchLogged,
      maxConcurrent: maxConcurrent,
      domainDelay: domainDelay,
    );
  }

  group("watch", () {
    test("returns the same signal instance for the same URL", () {
      final service = buildService();
      final a = service.watch("https://x.com");
      final b = service.watch("https://x.com");
      expect(identical(a, b), isTrue);
    });

    test("initially emits loading()", () {
      final service = buildService();
      final s = service.watch("https://x.com");
      expect(s.value, isA<MetadataStateLoading>());
    });

    test("emits ready() after a successful first fetch", () async {
      fetcher.responses["https://x.com"] =
          const RawFetchedMetadata(title: "X title");
      final service = buildService();
      final s = service.watch("https://x.com");

      // Pump microtasks until we leave the loading state.
      for (var i = 0; i < 10 && s.value is MetadataStateLoading; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(s.value, isA<MetadataStateReady>());
      final ready = s.value as MetadataStateReady;
      expect(ready.data.title, "X title");
      expect(ready.data.url, "https://x.com");
    });

    test("emits failed() after a fetch error and records failure", () async {
      // No response registered → fetcher throws.
      final service = buildService();
      final s = service.watch("https://err.com");

      for (var i = 0; i < 10 && s.value is MetadataStateLoading; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(s.value, isA<MetadataStateFailed>());
      final fail = s.value as MetadataStateFailed;
      expect(fail.attemptCount, 1);
      expect(failures.failureCount("https://err.com"), 1);
    });

    test("returns cached fresh data without fetching", () async {
      persistence.seed(Metadata(
        url: "https://cached.com",
        title: "Cached",
        fetchedAt: DateTime.now(),
        ttlDays: 7,
      ));

      final service = buildService();
      final s = service.watch("https://cached.com");

      for (var i = 0; i < 10 && s.value is MetadataStateLoading; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(s.value, isA<MetadataStateReady>());
      expect((s.value as MetadataStateReady).data.title, "Cached");
      expect(fetcher.calls, isEmpty);
    });

    test(
        "emits failed(backoff) without fetching when failure tracker says no",
        () async {
      failures.recordFailure("https://blocked.com");

      final service = buildService();
      final s = service.watch("https://blocked.com");

      for (var i = 0; i < 10 && s.value is MetadataStateLoading; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(s.value, isA<MetadataStateFailed>());
      expect((s.value as MetadataStateFailed).reason, "backoff");
      expect(fetcher.calls, isEmpty);
    });
  });

  group("in-flight coalescing", () {
    test("concurrent watches for the same URL share one fetch", () async {
      fetcher.gate("https://slow.com");
      fetcher.responses["https://slow.com"] =
          const RawFetchedMetadata(title: "Slow");

      final service = buildService();
      final a = service.watch("https://slow.com");
      final b = service.watch("https://slow.com");

      // Both should see the same signal — already covered by another
      // test, but here we also confirm only ONE fetch was issued.
      expect(identical(a, b), isTrue);

      // Give microtasks a chance to run; nothing should fetch yet
      // because we gated it.
      await Future<void>.delayed(Duration.zero);
      expect(fetcher.calls.length, 1);

      fetcher.release("https://slow.com");
      for (var i = 0; i < 10 && a.value is MetadataStateLoading; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(a.value, isA<MetadataStateReady>());
      // Still only one network call.
      expect(fetcher.calls.length, 1);
    });
  });

  group("forceFetch", () {
    test("bypasses cache and refetches fresh entries", () async {
      persistence.seed(Metadata(
        url: "https://x.com",
        title: "Old",
        fetchedAt: DateTime.now(),
        ttlDays: 30,
      ));
      fetcher.responses["https://x.com"] =
          const RawFetchedMetadata(title: "New");

      final service = buildService();
      final state = await service.forceFetch("https://x.com");

      expect(state, isA<MetadataStateReady>());
      expect((state as MetadataStateReady).data.title, "New");
      expect(fetcher.calls, ["https://x.com"]);
    });

    test("clears failure history then fetches", () async {
      failures.recordFailure("https://x.com");
      fetcher.responses["https://x.com"] =
          const RawFetchedMetadata(title: "OK");

      final service = buildService();
      final state = await service.forceFetch("https://x.com");

      expect(state, isA<MetadataStateReady>());
      expect(failures.failureCount("https://x.com"), 0);
    });

    test("updates the existing signal", () async {
      fetcher.responses["https://x.com"] =
          const RawFetchedMetadata(title: "First");
      final service = buildService();
      final s = service.watch("https://x.com");

      for (var i = 0; i < 10 && s.value is MetadataStateLoading; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect((s.value as MetadataStateReady).data.title, "First");

      fetcher.responses["https://x.com"] =
          const RawFetchedMetadata(title: "Second");
      await service.forceFetch("https://x.com");

      expect((s.value as MetadataStateReady).data.title, "Second");
    });
  });

  group("peek", () {
    test("returns loading() when no signal exists for the URL", () {
      final service = buildService();
      expect(service.peek("https://x.com"), isA<MetadataStateLoading>());
    });

    test("returns current signal value without fetching", () async {
      fetcher.responses["https://x.com"] =
          const RawFetchedMetadata(title: "X");
      final service = buildService();
      service.watch("https://x.com");

      // Drain the initial fetch.
      for (var i = 0;
          i < 10 && service.peek("https://x.com") is MetadataStateLoading;
          i++) {
        await Future<void>.delayed(Duration.zero);
      }

      final callsBefore = fetcher.calls.length;
      final state = service.peek("https://x.com");
      expect(state, isA<MetadataStateReady>());
      expect(fetcher.calls.length, callsBefore); // no new fetch
    });
  });

  group("onFetchLogged", () {
    test("fires on first successful fetch", () async {
      final logged = <(String, bool, String?)>[];
      fetcher.responses["https://x.com"] =
          const RawFetchedMetadata(title: "X");
      final service = buildService(
        onFetchLogged: (url, ok, {error}) => logged.add((url, ok, error)),
      );

      service.watch("https://x.com");
      for (var i = 0; i < 10 && logged.isEmpty; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(logged, [("https://x.com", true, null)]);
    });

    test("does NOT fire on subsequent (refresh) fetches", () async {
      final logged = <(String, bool, String?)>[];
      persistence.seed(Metadata(
        url: "https://x.com",
        title: "Old",
        fetchedAt: DateTime.now().subtract(const Duration(days: 30)),
        ttlDays: 7,
      ));
      fetcher.responses["https://x.com"] =
          const RawFetchedMetadata(title: "Refreshed");

      final service = buildService(
        onFetchLogged: (url, ok, {error}) => logged.add((url, ok, error)),
      );

      service.watch("https://x.com");
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      // Existing entry means !isFirstFetch — no success log.
      expect(logged, isEmpty);
    });

    test("fires on failures (always)", () async {
      final logged = <(String, bool, String?)>[];
      // No response → fetcher throws.
      final service = buildService(
        onFetchLogged: (url, ok, {error}) => logged.add((url, ok, error)),
      );

      service.watch("https://bad.com");
      for (var i = 0; i < 10 && logged.isEmpty; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(logged.length, 1);
      expect(logged.first.$1, "https://bad.com");
      expect(logged.first.$2, isFalse);
      expect(logged.first.$3, contains("boom"));
    });
  });

  group("concurrency", () {
    test("respects maxConcurrent slot limit", () async {
      // Three gated URLs, maxConcurrent=2 → only two start before
      // a slot is released.
      for (final url in ["https://a.com", "https://b.com", "https://c.com"]) {
        fetcher.gate(url);
        fetcher.responses[url] = RawFetchedMetadata(title: url);
      }

      final service = buildService(maxConcurrent: 2);
      service.watch("https://a.com");
      service.watch("https://b.com");
      service.watch("https://c.com");

      // Pump.
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(fetcher.calls.length, 2);

      // Release one — third should now start.
      fetcher.release("https://a.com");
      for (var i = 0; i < 10 && fetcher.calls.length < 3; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(fetcher.calls.length, 3);

      // Cleanup.
      fetcher.release("https://b.com");
      fetcher.release("https://c.com");
    });
  });

  group("refreshStaleEntries", () {
    test("refreshes only expired entries", () async {
      persistence.seed(Metadata(
        url: "https://fresh.com",
        title: "Fresh",
        fetchedAt: DateTime.now(),
        ttlDays: 7,
      ));
      persistence.seed(Metadata(
        url: "https://stale.com",
        title: "Old",
        fetchedAt: DateTime.now().subtract(const Duration(days: 30)),
        ttlDays: 7,
      ));
      fetcher.responses["https://stale.com"] =
          const RawFetchedMetadata(title: "Refreshed");

      final service = buildService();
      final count = await service.refreshStaleEntries();

      expect(count, 1);
      expect(fetcher.calls, ["https://stale.com"]);
    });

    test("concurrent calls collapse to one run", () async {
      persistence.seed(Metadata(
        url: "https://stale.com",
        title: "Old",
        fetchedAt: DateTime.now().subtract(const Duration(days: 30)),
        ttlDays: 7,
      ));
      fetcher.responses["https://stale.com"] =
          const RawFetchedMetadata(title: "Refreshed");

      final service = buildService();
      final a = service.refreshStaleEntries();
      final b = service.refreshStaleEntries();

      final results = await Future.wait([a, b]);
      // One of them did the work; the other returned 0 immediately.
      expect(results.contains(1), isTrue);
      expect(results.contains(0), isTrue);
      // Only one fetch happened.
      expect(fetcher.calls.length, 1);
    });
  });

  group("change detection / adaptive TTL", () {
    test("unchanged content increments consecutiveUnchanged", () async {
      persistence.seed(Metadata(
        url: "https://x.com",
        title: "Same",
        description: "Same desc",
        imageUrl: "https://img/1",
        fetchedAt: DateTime.now().subtract(const Duration(days: 30)),
        ttlDays: 7,
        consecutiveUnchanged: 2,
      ));
      fetcher.responses["https://x.com"] = const RawFetchedMetadata(
        title: "Same",
        description: "Same desc",
        imageUrl: "https://img/1",
      );

      final service = buildService();
      final state = await service.forceFetch("https://x.com");

      expect(state, isA<MetadataStateReady>());
      final m = (state as MetadataStateReady).data;
      expect(m.consecutiveUnchanged, 3);
    });

    test("changed content resets consecutiveUnchanged to 0", () async {
      persistence.seed(Metadata(
        url: "https://x.com",
        title: "Old",
        fetchedAt: DateTime.now().subtract(const Duration(days: 30)),
        ttlDays: 7,
        consecutiveUnchanged: 5,
      ));
      fetcher.responses["https://x.com"] =
          const RawFetchedMetadata(title: "Brand new");

      final service = buildService();
      final state = await service.forceFetch("https://x.com");

      expect(state, isA<MetadataStateReady>());
      expect((state as MetadataStateReady).data.consecutiveUnchanged, 0);
    });
  });

  group("forceFetch slot accounting (H9)", () {
    test(
        "force-refreshing an in-flight URL does not leak a concurrency slot",
        () async {
      // One URL already in-flight (gated), maxConcurrent=2.
      fetcher.gate("https://slow.com");
      fetcher.responses["https://slow.com"] =
          const RawFetchedMetadata(title: "Slow");

      final service = buildService(maxConcurrent: 2);

      // First observer kicks off the (gated) fetch -> 1 slot in use.
      service.watch("https://slow.com");
      await Future<void>.delayed(Duration.zero);
      expect(fetcher.calls.length, 1);

      // Force-refresh the SAME in-flight URL. It must coalesce onto the
      // running fetch rather than acquiring (and stranding) a 2nd slot.
      final forced = service.forceFetch("https://slow.com");
      await Future<void>.delayed(Duration.zero);
      // Still just the one network call — no duplicate fetch.
      expect(fetcher.calls.length, 1);

      // Resolve the in-flight fetch; the forced future resolves too.
      fetcher.release("https://slow.com");
      await forced;
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      // The pool must be fully restored: two fresh gated fetches should
      // both start concurrently. If forceFetch leaked a slot, only one
      // would start.
      for (final url in ["https://a.com", "https://b.com"]) {
        fetcher.gate(url);
        fetcher.responses[url] = RawFetchedMetadata(title: url);
      }
      service.watch("https://a.com");
      service.watch("https://b.com");
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(
        fetcher.calls.where((u) => u == "https://a.com" || u == "https://b.com").length,
        2,
        reason: "both slots should be free after the forced refresh resolved",
      );

      fetcher.release("https://a.com");
      fetcher.release("https://b.com");
    });

    test(
        "repeated force-refresh on a gated URL never exhausts the pool",
        () async {
      // Hammer forceFetch on the same gated URL; each coalesces onto the
      // one in-flight fetch. None may strand a slot.
      fetcher.gate("https://slow.com");
      fetcher.responses["https://slow.com"] =
          const RawFetchedMetadata(title: "Slow");

      final service = buildService(maxConcurrent: 2);
      service.watch("https://slow.com");
      await Future<void>.delayed(Duration.zero);

      final forced = <Future<MetadataState>>[];
      for (var i = 0; i < 5; i++) {
        forced.add(service.forceFetch("https://slow.com"));
        await Future<void>.delayed(Duration.zero);
      }
      expect(fetcher.calls.length, 1); // all coalesced

      fetcher.release("https://slow.com");
      await Future.wait(forced);
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      // Pool intact: maxConcurrent fresh fetches start together.
      for (final url in ["https://a.com", "https://b.com"]) {
        fetcher.gate(url);
        fetcher.responses[url] = RawFetchedMetadata(title: url);
      }
      service.watch("https://a.com");
      service.watch("https://b.com");
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(
        fetcher.calls.where((u) => u == "https://a.com" || u == "https://b.com").length,
        2,
      );

      fetcher.release("https://a.com");
      fetcher.release("https://b.com");
    });
  });

  group("dispose + signal-cache bounds (H8)", () {
    test("dispose disposes all signals and clears the caches", () async {
      fetcher.responses["https://x.com"] =
          const RawFetchedMetadata(title: "X");
      final service = buildService();
      final s = service.watch("https://x.com");
      for (var i = 0; i < 10 && s.value is MetadataStateLoading; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(service.signalCacheSize, 1);

      service.dispose();

      expect(s.disposed, isTrue);
      expect(service.signalCacheSize, 0);
      expect(service.domainThrottleMapSize, 0);
    });

    test("a late fetch resolving after dispose does not throw or write",
        () async {
      // Gate the fetch so it's still in-flight when we dispose.
      fetcher.gate("https://slow.com");
      fetcher.responses["https://slow.com"] =
          const RawFetchedMetadata(title: "Slow");

      final service = buildService();
      final s = service.watch("https://slow.com");
      await Future<void>.delayed(Duration.zero);

      service.dispose();
      expect(s.disposed, isTrue);

      // Let the gated fetch complete AFTER disposal. It must not throw a
      // "wrote to disposed signal" error nor resurrect the signal.
      fetcher.release("https://slow.com");
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(service.signalCacheSize, 0);
    });

    test("watch() after dispose is a no-op (returns disposed sentinel)",
        () async {
      final service = buildService();
      service.dispose();
      final s = service.watch("https://x.com");
      // Whatever it returns must already be disposed; no fetch fires.
      expect(s.disposed, isTrue);
      expect(fetcher.calls, isEmpty);
    });

    test("_signals cache evicts LRU entries past the cap", () async {
      // Cap is signalCacheCapacity; watch one more than the cap and the
      // least-recently-used signal must be evicted (disposed + removed).
      final service = buildService();
      final cap = service.signalCacheCapacity;

      Signal<MetadataState>? firstSignal;
      for (var i = 0; i < cap; i++) {
        final url = "https://host$i.com/page";
        fetcher.responses[url] = RawFetchedMetadata(title: "t$i");
        final s = service.watch(url);
        firstSignal ??= s;
      }
      expect(service.signalCacheSize, cap);

      // One more distinct URL -> overflow -> evict the oldest (host0).
      const overflowUrl = "https://overflow.com/page";
      fetcher.responses[overflowUrl] =
          const RawFetchedMetadata(title: "overflow");
      service.watch(overflowUrl);

      expect(service.signalCacheSize, cap);
      expect(firstSignal!.disposed, isTrue,
          reason: "least-recently-used signal should be evicted + disposed");

      // Drain pending fetches.
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    });

    test("watch() promotes recency so the active entry is not evicted",
        () async {
      final service = buildService();
      final cap = service.signalCacheCapacity;

      const keepUrl = "https://keep.com/page";
      fetcher.responses[keepUrl] = const RawFetchedMetadata(title: "keep");
      final keep = service.watch(keepUrl);

      // Fill the rest of the cap with other URLs.
      for (var i = 1; i < cap; i++) {
        final url = "https://host$i.com/page";
        fetcher.responses[url] = RawFetchedMetadata(title: "t$i");
        service.watch(url);
      }
      // Touch keepUrl again so it becomes most-recently-used.
      service.watch(keepUrl);

      // Overflow: the oldest non-keep entry (host1) is evicted, not keep.
      const overflowUrl = "https://overflow.com/page";
      fetcher.responses[overflowUrl] =
          const RawFetchedMetadata(title: "overflow");
      service.watch(overflowUrl);

      expect(keep.disposed, isFalse,
          reason: "recently-watched signal must survive eviction");

      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    });
  });

  group("domain throttle map pruning (H18)", () {
    test("stale _lastDomainFetch entries are pruned by cleanupStale",
        () async {
      // A short-but-not-instant window so both entries coexist until we
      // deliberately age past it, then prune.
      final service = buildService(
        domainDelay: const Duration(milliseconds: 40),
      );

      fetcher.responses["https://a.com/x"] =
          const RawFetchedMetadata(title: "a");
      fetcher.responses["https://b.com/x"] =
          const RawFetchedMetadata(title: "b");

      await service.forceFetch("https://a.com/x");
      await service.forceFetch("https://b.com/x");
      expect(service.domainThrottleMapSize, 2);

      // Wait past the throttle window, then prune.
      await Future<void>.delayed(const Duration(milliseconds: 60));
      service.cleanupStale();

      expect(service.domainThrottleMapSize, 0);
    });

    test("a recently-touched domain entry is NOT pruned", () async {
      final service = buildService(
        domainDelay: const Duration(seconds: 30),
      );

      fetcher.responses["https://a.com/x"] =
          const RawFetchedMetadata(title: "a");
      await service.forceFetch("https://a.com/x");
      expect(service.domainThrottleMapSize, 1);

      // Within the 30s window -> must survive pruning.
      service.cleanupStale();
      expect(service.domainThrottleMapSize, 1);
    });
  });
}
