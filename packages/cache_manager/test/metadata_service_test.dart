import "dart:async";
import "dart:math";

import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";

class _FakePersistence
    implements MetadataPersistence, MetadataRefreshPersistence {
  final Map<String, Metadata> metadata = {};
  final Map<String, MetadataRefreshRecord> records = {};
  DateTime now = DateTime.utc(2026, 8, 9, 12);

  @override
  Future<Metadata?> get(String url) async => metadata[url];

  @override
  Future<void> set(Metadata value) async {
    metadata[value.url] = value;
  }

  @override
  Future<void> remove(String url) async {
    metadata.remove(url);
  }

  @override
  Future<void> clearAll() async {
    metadata.clear();
    records.clear();
  }

  @override
  Future<int> count() async => metadata.length;

  @override
  Future<List<Metadata>> getExpiredEntries() async => metadata.values
      .where((value) => now.difference(value.fetchedAt).inDays >= value.ttlDays)
      .toList(growable: false);

  @override
  Future<MetadataRefreshRecord?> getRefreshRecord(String url) async =>
      records[url];

  @override
  Future<void> setRefreshRecord(MetadataRefreshRecord record) async {
    records[record.url] = record;
  }

  @override
  Future<void> removeRefreshRecord(String url) async {
    records.remove(url);
  }

  @override
  Future<void> clearAllRefreshRecords() async {
    records.clear();
  }

  void seed(Metadata value) => metadata[value.url] = value;
}

class _FakeFetcher {
  final Map<String, Future<MetadataFetchResult> Function(Metadata?)> handlers =
      {};
  final List<(String, Metadata?)> calls = [];
  int active = 0;
  int maxActive = 0;

  Future<MetadataFetchResult> fetch(
    String url, {
    Metadata? previous,
  }) async {
    calls.add((url, previous));
    active++;
    maxActive = max(maxActive, active);
    try {
      final handler = handlers[url];
      if (handler == null) throw StateError("No response for $url");
      return await handler(previous);
    } finally {
      active--;
    }
  }

  void respond(String url, MetadataFetchResult result) {
    handlers[url] = (_) async => result;
  }
}

class _NoJitterRandom implements Random {
  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0.5;

  @override
  int nextInt(int max) => 0;
}

MetadataModified _modified(
  String url, {
  String? title,
  String? description,
  String? imageUrl,
  String? etag,
  String? lastModified,
  String? contentHash,
}) =>
    MetadataModified(
      candidate: MetadataCandidate(
        resolvedUrl: url,
        title: title,
        description: description,
        imageUrl: imageUrl,
        etag: etag,
        lastModified: lastModified,
        contentHash: contentHash,
      ),
      statusCode: 200,
      responseBytes: 100,
      elapsed: const Duration(milliseconds: 20),
    );

void main() {
  const url = "https://example.com/post/1";
  late DateTime now;
  late _FakePersistence persistence;
  late MetadataCache cache;
  late FailureTracker failures;
  late DomainCircuitBreaker domains;
  late _FakeFetcher fetcher;

  Metadata staleMetadata({
    String metadataUrl = url,
    String title = "Known title",
    String? description = "Known description",
    String? imageUrl = "https://images.example/known.jpg",
    String? etag = '"old"',
    String? lastModified = "Fri, 01 Aug 2026 10:00:00 GMT",
    String? contentHash = "old-hash",
    int consecutiveUnchanged = 0,
  }) =>
      Metadata(
        url: metadataUrl,
        title: title,
        description: description,
        imageUrl: imageUrl,
        fetchedAt: now.subtract(const Duration(days: 30)),
        ttlDays: 7,
        etag: etag,
        lastModified: lastModified,
        contentHash: contentHash,
        consecutiveUnchanged: consecutiveUnchanged,
      );

  MetadataService buildService({
    int maxConcurrent = 3,
    int signalCapacity = MetadataService.defaultSignalCapacity,
    Duration domainDelay = Duration.zero,
    Future<void> Function(Duration)? delay,
    OnFetchLogged? onFetchLogged,
  }) =>
      MetadataService(
        cache: cache,
        failures: failures,
        domainCircuitBreaker: domains,
        fetcher: fetcher.fetch,
        onFetchLogged: onFetchLogged,
        now: () => now,
        ttlRandom: _NoJitterRandom(),
        maxConcurrent: maxConcurrent,
        domainDelay: domainDelay,
        delay: delay,
        signalCapacity: signalCapacity,
      );

  setUp(() {
    now = DateTime.utc(2026, 8, 9, 12);
    persistence = _FakePersistence()..now = now;
    cache = MetadataCache(persistence: persistence);
    failures = FailureTracker(persistence: persistence, now: () => now);
    domains = DomainCircuitBreaker(now: () => now);
    fetcher = _FakeFetcher();
  });

  test("stale cache is available and refreshing before fetch completes",
      () async {
    final old = staleMetadata();
    persistence.seed(old);
    final fetchCompleter = Completer<MetadataFetchResult>();
    fetcher.handlers[url] = (previous) {
      expect(previous, old);
      return fetchCompleter.future;
    };

    final signal = buildService().watch(url);
    await pumpEventQueue();

    expect(signal.value, isA<MetadataStateAvailable>());
    final during = signal.value as MetadataStateAvailable;
    expect(during.data.title, "Known title");
    expect(during.freshness, MetadataFreshness.stale);
    expect(during.refreshPhase, MetadataRefreshPhase.refreshing);

    fetchCompleter.complete(_modified(url, title: "New title"));
    await pumpEventQueue();
  });

  test("rejected refresh keeps stale data and emits failed phase", () async {
    final old = staleMetadata();
    persistence.seed(old);
    final fetchCompleter = Completer<MetadataFetchResult>();
    fetcher.handlers[url] = (_) => fetchCompleter.future;
    final service = buildService();

    final signal = service.watch(url);
    await pumpEventQueue();
    expect(signal.value, isA<MetadataStateAvailable>());
    expect((signal.value as MetadataStateAvailable).data.title, "Known title");
    expect(
      (signal.value as MetadataStateAvailable).refreshPhase,
      MetadataRefreshPhase.refreshing,
    );

    fetchCompleter.complete(const MetadataRejected(
      kind: MetadataFailureKind.blocked,
      reason: "403",
      statusCode: 403,
      elapsed: Duration(milliseconds: 20),
    ));
    await pumpEventQueue();

    final after = signal.value as MetadataStateAvailable;
    expect(after.data, old);
    expect(after.refreshPhase, MetadataRefreshPhase.failed);
    expect(after.lastFailure?.kind, MetadataFailureKind.blocked);
    expect(after.lastFailure?.reason, "403");
    expect(after.lastFailure?.statusCode, 403);
    expect(after.lastFailure?.attemptCount, 1);
    expect(after.lastFailure?.nextRetryAt, now.add(const Duration(minutes: 2)));
    expect(persistence.metadata[url], old);
    expect(persistence.records[url]?.lastStatusCode, 403);
    expect(domains.nextRetryAt(url), now.add(const Duration(minutes: 2)));
  });

  test("thrown transport failure keeps stale data and emits failed phase",
      () async {
    final old = staleMetadata();
    persistence.seed(old);
    fetcher.handlers[url] = (_) async => throw const SocketExceptionForTest();
    final signal = buildService().watch(url);

    await pumpEventQueue();

    final after = signal.value as MetadataStateAvailable;
    expect(after.data, old);
    expect(after.refreshPhase, MetadataRefreshPhase.failed);
    expect(after.lastFailure?.kind, MetadataFailureKind.transport);
    expect(after.lastFailure?.reason, contains("socket closed"));
    expect(after.lastFailure?.attemptCount, 1);
    expect(persistence.metadata[url], old);
  });

  test("no-cache failure emits unavailable failed", () async {
    fetcher.respond(
      url,
      const MetadataFetchFailed(
        kind: MetadataFailureKind.timeout,
        reason: "deadline",
        elapsed: Duration(seconds: 15),
      ),
    );
    final signal = buildService().watch(url);

    await pumpEventQueue();

    final state = signal.value as MetadataStateUnavailable;
    expect(state.refreshPhase, MetadataRefreshPhase.failed);
    expect(state.lastFailure?.kind, MetadataFailureKind.timeout);
    expect(state.lastFailure?.reason, "deadline");
    expect(state.lastFailure?.attemptCount, 1);
  });

  test("304 refreshes bookkeeping and returns unchanged while keeping fields",
      () async {
    final old = staleMetadata(consecutiveUnchanged: 2);
    persistence.seed(old);
    fetcher.respond(
      url,
      const MetadataNotModified(
        resolvedUrl: "https://cdn.example.com/post/1",
        etag: '"new"',
        lastModified: "Sat, 09 Aug 2026 12:00:00 GMT",
        elapsed: Duration(milliseconds: 15),
      ),
    );
    final logged = <MetadataRefreshResult>[];
    final service =
        buildService(onFetchLogged: (_, result) => logged.add(result));

    final result = await service.forceFetch(url);

    expect(result.outcome, MetadataRefreshOutcome.unchanged);
    final state = result.state as MetadataStateAvailable;
    expect(state.refreshPhase, MetadataRefreshPhase.idle);
    expect(state.freshness, MetadataFreshness.fresh);
    expect(state.data.url, url);
    expect(state.data.resolvedUrl, "https://cdn.example.com/post/1");
    expect(state.data.title, old.title);
    expect(state.data.description, old.description);
    expect(state.data.imageUrl, old.imageUrl);
    expect(state.data.fetchedAt, now);
    expect(state.data.etag, '"new"');
    expect(state.data.lastModified, "Sat, 09 Aug 2026 12:00:00 GMT");
    expect(state.data.contentHash, old.contentHash);
    expect(state.data.consecutiveUnchanged, 3);
    expect(state.data.ttlDays, 56);
    expect(logged.single, same(result));
  });

  test("modified accepted title replaces old title and returns updated",
      () async {
    persistence.seed(staleMetadata());
    fetcher.respond(url, _modified(url, title: "  Better title  "));

    final result = await buildService().forceFetch(url);

    expect(result.outcome, MetadataRefreshOutcome.updated);
    final data = (result.state as MetadataStateAvailable).data;
    expect(data.title, "Better title");
    expect(data.consecutiveUnchanged, 0);
    expect(data.ttlDays, 7);
  });

  test("modified missing description and image preserves verified fields",
      () async {
    final old = staleMetadata();
    persistence.seed(old);
    fetcher.respond(
      url,
      _modified(
        url,
        title: "Better title",
        description: "   ",
      ),
    );

    final result = await buildService().forceFetch(url);

    final data = (result.state as MetadataStateAvailable).data;
    expect(result.outcome, MetadataRefreshOutcome.updated);
    expect(data.description, old.description);
    expect(data.imageUrl, old.imageUrl);
  });

  test("domain-only incoming title never replaces meaningful old title",
      () async {
    final old = staleMetadata(title: "A meaningful article");
    persistence.seed(old);
    fetcher.respond(url, _modified(url, title: "  example  "));

    final result = await buildService().forceFetch(url);

    expect(result.outcome, MetadataRefreshOutcome.unchanged);
    final data = (result.state as MetadataStateAvailable).data;
    expect(data.title, "A meaningful article");
    expect(data.consecutiveUnchanged, 1);
    expect(data.ttlDays, 14);
  });

  test("Media placeholder does not replace a meaningful Media title",
      () async {
    const mediaUrl =
        "https://media.example/index.php?page=post&s=list&tags=sampletag";
    final old = staleMetadata(
      metadataUrl: mediaUrl,
      title: "Media / sampletag",
    );
    persistence.seed(old);
    fetcher.respond(mediaUrl, _modified(mediaUrl, title: "Media"));

    final result = await buildService().forceFetch(mediaUrl);

    expect(result.outcome, MetadataRefreshOutcome.unchanged);
    expect(
      (result.state as MetadataStateAvailable).data.title,
      "Media / sampletag",
    );
  });

  test("literal Media hostname does not replace a meaningful title",
      () async {
    const mediaUrl =
        "https://media.example/index.php?page=post&s=list&tags=sampletag";
    persistence.seed(
      staleMetadata(
        metadataUrl: mediaUrl,
        title: "Media / sampletag",
      ),
    );
    fetcher.respond(mediaUrl, _modified(mediaUrl, title: "media.example"));

    final result = await buildService().forceFetch(mediaUrl);

    expect(result.outcome, MetadataRefreshOutcome.unchanged);
    expect(
      (result.state as MetadataStateAvailable).data.title,
      "Media / sampletag",
    );
  });

  test("short-label hostname does not replace a meaningful title", () async {
    const shortHostUrl = "https://x.com/post/1";
    persistence.seed(
      staleMetadata(
        metadataUrl: shortHostUrl,
        title: "A meaningful title",
      ),
    );
    fetcher.respond(shortHostUrl, _modified(shortHostUrl, title: "x.com"));

    final result = await buildService().forceFetch(shortHostUrl);

    expect(result.outcome, MetadataRefreshOutcome.unchanged);
    expect(
      (result.state as MetadataStateAvailable).data.title,
      "A meaningful title",
    );
  });

  test("new domain-only title is not persisted without a previous title",
      () async {
    const mediaUrl = "https://media.example/post/1";
    fetcher.respond(mediaUrl, _modified(mediaUrl, title: "Media"));

    final result = await buildService().forceFetch(mediaUrl);

    final data = (result.state as MetadataStateAvailable).data;
    expect(data.title, isNull);
    expect(data.ttlDays, TtlTier.medium.baseDays);
  });
  test("saved requested URL remains cache key after redirect", () async {
    const redirected = "https://www.example.com/canonical/1";
    fetcher.respond(url, _modified(redirected, title: "Article"));

    final result = await buildService().forceFetch(url);

    final data = (result.state as MetadataStateAvailable).data;
    expect(data.url, url);
    expect(data.resolvedUrl, redirected);
    expect(persistence.metadata[url], data);
    expect(persistence.metadata[redirected], isNull);
  });

  test("force refresh never emits unavailable when cached data exists",
      () async {
    final old = staleMetadata();
    persistence.seed(old);
    final completer = Completer<MetadataFetchResult>();
    fetcher.handlers[url] = (_) => completer.future;
    final service = buildService();
    final signal = service.watch(url);
    await pumpEventQueue();

    final forced = service.forceFetch(url);
    await pumpEventQueue();

    final during = signal.value as MetadataStateAvailable;
    expect(during.data, old);
    expect(during.refreshPhase, MetadataRefreshPhase.refreshing);
    completer.complete(_modified(url, title: "New title"));
    await forced;
  });

  test("rejected force refresh preserves fresh snapshot freshness", () async {
    final fresh = staleMetadata().copyWith(fetchedAt: now);
    persistence.seed(fresh);
    fetcher.respond(
      url,
      const MetadataRejected(
        kind: MetadataFailureKind.blocked,
        reason: "blocked",
        statusCode: 403,
        elapsed: Duration(milliseconds: 20),
      ),
    );

    final result = await buildService().forceFetch(url);

    final state = result.state as MetadataStateAvailable;
    expect(state.data, fresh);
    expect(state.freshness, MetadataFreshness.fresh);
    expect(state.refreshPhase, MetadataRefreshPhase.failed);
  });

  test("thrown force refresh preserves fresh snapshot freshness", () async {
    final fresh = staleMetadata().copyWith(fetchedAt: now);
    persistence.seed(fresh);
    fetcher.handlers[url] = (_) async => throw const SocketExceptionForTest();

    final result = await buildService().forceFetch(url);

    final state = result.state as MetadataStateAvailable;
    expect(state.data, fresh);
    expect(state.freshness, MetadataFreshness.fresh);
    expect(state.lastFailure?.kind, MetadataFailureKind.transport);
  });
  test("force refresh bypasses URL and domain waiting once without reset",
      () async {
    final old = staleMetadata();
    persistence.seed(old);
    await failures.recordFailure(
      url,
      kind: MetadataFailureKind.blocked,
      statusCode: 403,
    );
    domains.recordFailure(url, kind: MetadataFailureKind.blocked);
    fetcher.respond(
      url,
      const MetadataFetchFailed(
        kind: MetadataFailureKind.transport,
        reason: "connection reset",
        elapsed: Duration(milliseconds: 20),
      ),
    );
    final service = buildService();

    final result = await service.forceFetch(url);

    expect(fetcher.calls.length, 1);
    expect(result.outcome, MetadataRefreshOutcome.failed);
    final state = result.state as MetadataStateAvailable;
    expect(state.data, old);
    expect(state.lastFailure?.attemptCount, 2);
    expect(failures.recordFor(url)?.consecutiveFailures, 2);
    expect(
      failures.nextRetryAt(url),
      now.add(const Duration(minutes: 10)),
    );
    expect(
      domains.nextRetryAt(url),
      now.add(const Duration(minutes: 10)),
    );

    final callCount = fetcher.calls.length;
    final secondService = buildService();
    final skippedSignal = secondService.watch(url);
    await pumpEventQueue();
    expect(fetcher.calls.length, callCount);
    expect(skippedSignal.value, isA<MetadataStateAvailable>());
    expect((skippedSignal.value as MetadataStateAvailable).data, old);
  });

  test("in-flight calls coalesce and acquire exactly one concurrency slot",
      () async {
    final firstCompleter = Completer<MetadataFetchResult>();
    fetcher.handlers[url] = (_) => firstCompleter.future;
    const otherUrl = "https://other.example/post/2";
    fetcher.respond(otherUrl, _modified(otherUrl, title: "Other"));
    final service = buildService(maxConcurrent: 1);

    final signal = service.watch(url);
    await pumpEventQueue();
    final forced = service.forceFetch(url);
    service.watch(otherUrl);
    await pumpEventQueue();

    expect(signal.value, isA<MetadataStateUnavailable>());
    expect(fetcher.calls.where((call) => call.$1 == url).length, 1);
    expect(fetcher.calls.where((call) => call.$1 == otherUrl), isEmpty);
    expect(fetcher.maxActive, 1);

    firstCompleter.complete(_modified(url, title: "First"));
    await forced;
    await pumpEventQueue();
    expect(fetcher.calls.where((call) => call.$1 == otherUrl).length, 1);
    expect(fetcher.maxActive, 1);
  });

  test("modified identical merged content returns unchanged and adapts TTL",
      () async {
    final old = staleMetadata(consecutiveUnchanged: 1);
    persistence.seed(old);
    fetcher.respond(
      url,
      _modified(
        "https://redirect.example/post/1",
        title: " Known title ",
        description: " Known description ",
        imageUrl: " https://images.example/known.jpg ",
        etag: '"new"',
      ),
    );

    final result = await buildService().forceFetch(url);

    expect(result.outcome, MetadataRefreshOutcome.unchanged);
    final data = (result.state as MetadataStateAvailable).data;
    expect(data.consecutiveUnchanged, 2);
    expect(data.ttlDays, 28);
    expect(data.resolvedUrl, "https://redirect.example/post/1");
    expect(data.etag, '"new"');
  });

  test("fresh lookup emits available idle and stops before retry decisions",
      () async {
    final fresh = staleMetadata().copyWith(fetchedAt: now);
    persistence.seed(fresh);
    await failures.recordFailure(url, kind: MetadataFailureKind.blocked);
    domains.recordFailure(url, kind: MetadataFailureKind.blocked);

    final signal = buildService().watch(url);
    await pumpEventQueue();

    final state = signal.value as MetadataStateAvailable;
    expect(state.data, fresh);
    expect(state.freshness, MetadataFreshness.fresh);
    expect(state.refreshPhase, MetadataRefreshPhase.idle);
    expect(fetcher.calls, isEmpty);
  });

  test("success clears URL and domain failure state", () async {
    persistence.seed(staleMetadata());
    await failures.recordFailure(url, kind: MetadataFailureKind.blocked);
    domains.recordFailure(url, kind: MetadataFailureKind.blocked);
    fetcher.respond(url, _modified(url, title: "Recovered"));

    await buildService().forceFetch(url);

    expect(failures.recordFor(url), isNull);
    expect(domains.nextRetryAt(url), isNull);
    expect(persistence.records[url], isNull);
  });

  test("skipped refresh records no new failure and preserves stale data",
      () async {
    final old = staleMetadata();
    persistence.seed(old);
    await failures.recordFailure(url, kind: MetadataFailureKind.blocked);
    final existing = failures.recordFor(url)!;

    final signal = buildService().watch(url);
    await pumpEventQueue();

    expect(fetcher.calls, isEmpty);
    expect(failures.recordFor(url), same(existing));
    final state = signal.value as MetadataStateAvailable;
    expect(state.data, old);
    expect(state.refreshPhase, MetadataRefreshPhase.failed);
    expect(state.lastFailure?.attemptCount, 1);
  });

  test("late fetch after dispose does not write or resurrect a signal",
      () async {
    final completer = Completer<MetadataFetchResult>();
    fetcher.handlers[url] = (_) => completer.future;
    final service = buildService();
    final watched = service.watch(url);
    await pumpEventQueue();

    service.dispose();
    completer.complete(_modified(url, title: "Late"));
    await pumpEventQueue();

    expect(watched.disposed, isTrue);
    expect(service.signalCacheSize, 0);
  });

  test("disposed force refresh preserves fresh snapshot freshness", () async {
    const blockerUrl = "https://blocker.example/post";
    final fresh = staleMetadata().copyWith(fetchedAt: now);
    persistence.seed(fresh);
    final blocker = Completer<MetadataFetchResult>();
    fetcher.handlers[blockerUrl] = (_) => blocker.future;
    final service = buildService(maxConcurrent: 1);
    service.watch(blockerUrl);
    await pumpEventQueue();

    final forced = service.forceFetch(url);
    await pumpEventQueue();
    service.dispose();

    final result = await forced;
    final state = result.state as MetadataStateAvailable;
    expect(result.outcome, MetadataRefreshOutcome.skipped);
    expect(state.data, fresh);
    expect(state.freshness, MetadataFreshness.fresh);

    blocker.complete(_modified(blockerUrl, title: "Late"));
    await pumpEventQueue();
  });

  test("host throttle state is pruned after its delay window", () async {
    fetcher.respond(url, _modified(url, title: "Known title"));
    final service = buildService(domainDelay: const Duration(minutes: 1));

    await service.forceFetch(url);
    expect(service.domainThrottleMapSize, 1);

    now = now.add(const Duration(minutes: 2));
    service.cleanupStale();
    expect(service.domainThrottleMapSize, 0);
  });
  test("concurrent same-host starts reserve every pacing interval", () async {
    final waits = <Duration>[];
    final waiters = <Completer<void>>[];
    Future<void> controlledDelay(Duration duration) {
      waits.add(duration);
      final completer = Completer<void>();
      waiters.add(completer);
      return completer.future;
    }

    final urls = [
      "https://paced.example/1",
      "https://paced.example/2",
      "https://paced.example/3",
    ];
    for (final pacedUrl in urls) {
      fetcher.respond(pacedUrl, _modified(pacedUrl, title: pacedUrl));
    }
    final service = buildService(
      domainDelay: const Duration(milliseconds: 10),
      delay: controlledDelay,
    );

    for (final pacedUrl in urls) {
      service.watch(pacedUrl);
    }
    await pumpEventQueue();

    expect(fetcher.calls.map((call) => call.$1), [urls.first]);
    expect(waits, const [
      Duration(milliseconds: 10),
      Duration(milliseconds: 20),
    ]);

    waiters.first.complete();
    await pumpEventQueue();
    expect(fetcher.calls.map((call) => call.$1), urls.take(2));

    waiters.last.complete();
    await pumpEventQueue();
    expect(fetcher.calls.map((call) => call.$1), urls);
  });

  test("disposed pacing waiter cannot resurrect host state or fetch", () async {
    final waiter = Completer<void>();
    final urls = ["https://paced.example/1", "https://paced.example/2"];
    for (final pacedUrl in urls) {
      fetcher.respond(pacedUrl, _modified(pacedUrl, title: pacedUrl));
    }
    final service = buildService(
      domainDelay: const Duration(milliseconds: 10),
      delay: (_) => waiter.future,
    );
    for (final pacedUrl in urls) {
      service.watch(pacedUrl);
    }
    await pumpEventQueue();

    service.dispose();
    waiter.complete();
    await pumpEventQueue();

    expect(fetcher.calls.map((call) => call.$1), [urls.first]);
    expect(service.domainThrottleMapSize, 0);
  });

  test("refreshStaleEntries processes expired entries only", () async {
    const staleUrl = "https://stale.example/post";
    const freshUrl = "https://fresh.example/post";
    persistence.seed(staleMetadata(metadataUrl: staleUrl));
    persistence.seed(
      staleMetadata(metadataUrl: freshUrl).copyWith(fetchedAt: now),
    );
    fetcher.respond(staleUrl, _modified(staleUrl, title: "Refreshed"));

    final summary = await buildService().refreshStaleEntries();

    expect(summary.updated, 1);
    expect(summary.total, 1);
    expect(fetcher.calls.map((call) => call.$1), [staleUrl]);
  });

  test("concurrent refreshStaleEntries calls collapse without duplicates",
      () async {
    const staleUrl = "https://stale.example/post";
    persistence.seed(staleMetadata(metadataUrl: staleUrl));
    final completer = Completer<MetadataFetchResult>();
    fetcher.handlers[staleUrl] = (_) => completer.future;
    final service = buildService();

    final first = service.refreshStaleEntries();
    final second = service.refreshStaleEntries();
    await pumpEventQueue();
    expect((await second).total, 0);
    expect(fetcher.calls.map((call) => call.$1), [staleUrl]);

    completer.complete(_modified(staleUrl, title: "Refreshed"));
    final summary = await first;
    expect(summary.updated, 1);
    expect(summary.total, 1);
    expect(fetcher.calls.map((call) => call.$1), [staleUrl]);
  });
  test("signals remain bounded and dispose is idempotent", () async {
    final service = buildService(signalCapacity: 2);
    for (final entry in [
      ("https://a.example/post", "A"),
      ("https://b.example/post", "B"),
      ("https://c.example/post", "C"),
    ]) {
      fetcher.respond(entry.$1, _modified(entry.$1, title: entry.$2));
    }
    final first = service.watch("https://a.example/post");
    service.watch("https://b.example/post");
    service.watch("https://c.example/post");

    expect(service.signalCacheSize, 2);
    expect(first.disposed, isTrue);
    await pumpEventQueue();

    service.dispose();
    service.dispose();
    expect(service.signalCacheSize, 0);
    expect(service.domainThrottleMapSize, 0);
    final inert = service.watch(url);
    expect(inert.disposed, isTrue);
  });
}

class SocketExceptionForTest implements Exception {
  const SocketExceptionForTest();

  @override
  String toString() => "socket closed";
}
