import "dart:async";
import "dart:collection";
import "dart:math";

import "package:app_logger/app_logger.dart";
import "package:cache_manager/metadata_cache.dart";
import "package:cache_manager/src/domain_circuit_breaker.dart";
import "package:cache_manager/src/failure_tracker.dart";
import "package:cache_manager/src/metadata_fetch_result.dart";
import "package:cache_manager/src/metadata_refresh.dart";
import "package:cache_manager/src/metadata.dart";
import "package:cache_manager/src/metadata_state.dart";
import "package:cache_manager/src/refresh_scheduler.dart";
import "package:cache_manager/src/ttl_strategy.dart";
import "package:signals/signals.dart";

const _source = "MetadataService";

/// Network fetcher injected by the host application's HTTP boundary.
typedef MetadataFetcherFn = Future<MetadataFetchResult> Function(
  String url, {
  Metadata? previous,
});

/// Best-effort hook for recording a terminal network refresh result.
typedef OnFetchLogged = void Function(
  String url,
  MetadataRefreshResult result,
);

/// Long-lived orchestrator for metadata fetches.
///
/// Replaces the static `MetadataFactory` from the host app. Owns:
///   - concurrency pool ([maxConcurrent] simultaneous fetches, extras
///     queued)
///   - per-domain throttling ([domainDelay] between hits to the same
///     host)
///   - in-flight coalescing (concurrent callers for the same URL share
///     one Future)
///   - signal lifecycle — one [Signal] of [MetadataState] per URL,
///     cached and shared across observers
///
/// Construct it with the storage [cache], a [failures] tracker, and a
/// host-provided [fetcher] callback. Optionally pass an
/// [onFetchLogged] hook to record fetch attempts.
class MetadataService {
  final MetadataCache _cache;
  final FailureTracker _failures;
  final DomainCircuitBreaker _domainCircuitBreaker;
  final MetadataFetcherFn _fetcher;
  final OnFetchLogged? _onFetchLogged;
  final DateTime Function() _now;
  final Future<void> Function(Duration) _delay;
  final Random _ttlRandom;
  final int _maxConcurrent;
  final Duration _domainDelay;

  /// Default cap on the number of live per-URL signals retained, mirroring
  /// [MetadataCache]'s in-memory LRU bound. Once exceeded, the
  /// least-recently-watched signal is disposed and dropped.
  static const int defaultSignalCapacity = 100;

  /// Per-URL state signals, kept in access order (most-recently-watched
  /// last) so the head is the LRU eviction candidate. Bounded by
  /// [_signalCapacity]; an evicted signal is disposed. A consumer that
  /// re-watches an evicted URL just gets a fresh signal + re-resolution.
  final LinkedHashMap<String, Signal<MetadataState>> _signals = LinkedHashMap();
  final int _signalCapacity;

  final Map<String, Future<MetadataRefreshResult>> _inFlight = {};
  final Map<String, DateTime> _reservedDomainStart = {};
  int _activeFetches = 0;
  final Queue<Completer<void>> _slotQueue = Queue();

  bool _refreshingStale = false;
  bool _disposed = false;

  MetadataService({
    required MetadataCache cache,
    required FailureTracker failures,
    required DomainCircuitBreaker domainCircuitBreaker,
    required MetadataFetcherFn fetcher,
    OnFetchLogged? onFetchLogged,
    DateTime Function()? now,
    Future<void> Function(Duration)? delay,
    Random? ttlRandom,
    int maxConcurrent = 3,
    Duration domainDelay = const Duration(milliseconds: 500),
    int signalCapacity = defaultSignalCapacity,
  })  : _cache = cache,
        _failures = failures,
        _domainCircuitBreaker = domainCircuitBreaker,
        _fetcher = fetcher,
        _onFetchLogged = onFetchLogged,
        _now = now ?? DateTime.now,
        _delay = delay ?? Future<void>.delayed,
        _ttlRandom = ttlRandom ?? Random(),
        _maxConcurrent = maxConcurrent,
        _domainDelay = domainDelay,
        _signalCapacity = signalCapacity;

  /// Returns a long-lived signal that emits [MetadataState] for [url].
  ///
  /// Multiple callers for the same URL share the same signal instance.
  /// First caller triggers an initial fetch if cache miss; subsequent
  /// callers see the current state immediately.
  Signal<MetadataState> watch(String url) {
    if (_disposed) {
      return signal<MetadataState>(const MetadataState.unavailable())
        ..dispose();
    }

    final existing = _signals[url];
    if (existing != null) {
      _touch(url);
      return existing;
    }

    final state = signal<MetadataState>(const MetadataState.unavailable(
      refreshPhase: MetadataRefreshPhase.refreshing,
    ));
    _putSignal(url, state);
    unawaited(_resolve(url));
    return state;
  }

  /// Read the latest state without starting resolution.
  MetadataState peek(String url) =>
      _signals[url]?.value ?? const MetadataState.unavailable();

  /// Refresh [url] manually, bypassing URL and domain waiting once.
  ///
  /// Manual refresh never clears retry history before the outcome and never
  /// replaces an available snapshot with an unavailable state.
  Future<MetadataRefreshResult> forceFetch(String url) {
    loggerGlobal.info(_source, "Force refresh requested: $url");
    if (_disposed) {
      return Future.value(MetadataRefreshResult(
        url: url,
        outcome: MetadataRefreshOutcome.skipped,
        state: const MetadataState.unavailable(),
      ));
    }
    if (_signals.containsKey(url)) {
      _touch(url);
    } else {
      _putSignal(
        url,
        signal<MetadataState>(const MetadataState.unavailable(
          refreshPhase: MetadataRefreshPhase.refreshing,
        )),
      );
    }
    return _refresh(url, manual: true);
  }

  /// Background refresh of all expired entries.
  ///
  /// Idempotent — concurrent calls collapse into one run. Returns the
  /// count of entries refreshed. Per-URL refreshes route through the
  /// same concurrency + throttling pipeline as [watch] / [forceFetch].
  Future<int> refreshStaleEntries() async {
    if (_disposed || _refreshingStale) return 0;
    _refreshingStale = true;
    try {
      cleanupStale();
      final persistence = _cache.persistence;
      if (persistence == null) return 0;
      return await RefreshScheduler.processQueue(
        persistence: persistence,
        shouldStop: () => _disposed,
        refreshOne: (url) async {
          final result = await _refresh(url, manual: false);
          return result.outcome != MetadataRefreshOutcome.failed &&
              result.outcome != MetadataRefreshOutcome.rejected;
        },
      );
    } finally {
      _refreshingStale = false;
    }
  }
  // ---------------------------------------------------------------------------
  // Internal: resolution
  // ---------------------------------------------------------------------------

  Future<void> _resolve(String url) async {
    if (_signals[url] == null || _disposed) return;
    await _refresh(url, manual: false);
  }

  /// Resolve in strict stale-while-revalidate order: lookup, visible state,
  /// retry hydration/decisions, coalescing, slot/throttle, fetch, reduction.
  Future<MetadataRefreshResult> _refresh(
    String url, {
    required bool manual,
  }) async {
    final lookup = await _cache.lookup(url, now: _now());
    final previous = lookup?.data;

    if (!manual && lookup?.freshness == MetadataFreshness.fresh) {
      final state = MetadataState.available(
        data: previous!,
        freshness: MetadataFreshness.fresh,
      );
      _emit(url, state);
      return MetadataRefreshResult(
        url: url,
        outcome: MetadataRefreshOutcome.skipped,
        state: state,
      );
    }

    if (lookup != null) {
      _emit(
        url,
        MetadataState.available(
          data: previous!,
          freshness: lookup.freshness,
          refreshPhase: MetadataRefreshPhase.refreshing,
        ),
      );
    } else {
      _emit(
        url,
        const MetadataState.unavailable(
          refreshPhase: MetadataRefreshPhase.refreshing,
        ),
      );
    }

    await _failures.hydrate(url);
    if (!manual) {
      final urlAllowed = _failures.shouldRetry(url);
      final domainDecision =
          urlAllowed ? _domainCircuitBreaker.decisionFor(url) : null;
      if (!urlAllowed || domainDecision == DomainRequestDecision.skip) {
        return _skip(url, lookup);
      }
    }

    final existing = _inFlight[url];
    if (existing != null) return existing;

    late final Future<MetadataRefreshResult> future;
    future = _doFetchInner(url, previous, lookup?.freshness).whenComplete(() {
      if (identical(_inFlight[url], future)) {
        _inFlight.remove(url);
      }
    });
    _inFlight[url] = future;
    return future;
  }

  MetadataRefreshResult _skip(String url, MetadataCacheLookup? lookup) {
    final record = _failures.recordFor(url);
    final failure = record == null
        ? null
        : MetadataRefreshFailure(
            kind: record.lastFailureKind ?? MetadataFailureKind.transport,
            reason: "retry waiting",
            attemptCount: record.consecutiveFailures,
            statusCode: record.lastStatusCode,
            nextRetryAt: record.nextRetryAt,
          );
    final phase = failure == null
        ? MetadataRefreshPhase.idle
        : MetadataRefreshPhase.failed;
    final state = lookup == null
        ? MetadataState.unavailable(
            refreshPhase: phase,
            lastFailure: failure,
          )
        : MetadataState.available(
            data: lookup.data,
            freshness: lookup.freshness,
            refreshPhase: phase,
            lastFailure: failure,
          );
    _emit(url, state);
    return MetadataRefreshResult(
      url: url,
      outcome: MetadataRefreshOutcome.skipped,
      state: state,
    );
  }

  /// Perform one real network attempt with one concurrency slot.
  Future<MetadataRefreshResult> _doFetchInner(
    String url,
    Metadata? previous,
    MetadataFreshness? previousFreshness,
  ) async {
    await _acquireSlot();
    try {
      if (_disposed) {
        return _disposedResult(url, previous, previousFreshness);
      }
      await _throttleDomain(url);
      if (_disposed) {
        return _disposedResult(url, previous, previousFreshness);
      }

      final stopwatch = Stopwatch()..start();
      MetadataFetchResult fetched;
      try {
        fetched = await _fetcher(url, previous: previous);
      } catch (error) {
        fetched = MetadataFetchFailed(
          kind: MetadataFailureKind.transport,
          reason: error.toString(),
          elapsed: stopwatch.elapsed,
        );
      }
      return await _reduce(url, previous, previousFreshness, fetched);
    } finally {
      _releaseSlot();
    }
  }

  MetadataRefreshResult _disposedResult(
    String url,
    Metadata? previous,
    MetadataFreshness? previousFreshness,
  ) {
    final state = previous == null
        ? const MetadataState.unavailable()
        : MetadataState.available(
            data: previous,
            freshness: previousFreshness ?? MetadataFreshness.stale,
          );
    return MetadataRefreshResult(
      url: url,
      outcome: MetadataRefreshOutcome.skipped,
      state: state,
    );
  }

  Future<MetadataRefreshResult> _reduce(
    String url,
    Metadata? previous,
    MetadataFreshness? previousFreshness,
    MetadataFetchResult fetched,
  ) async {
    final result = switch (fetched) {
      MetadataModified() => await _reduceModified(url, previous, fetched),
      MetadataNotModified() => await _reduceNotModified(url, previous, fetched),
      MetadataRejected() => await _reduceFailure(
          url,
          previous,
          kind: fetched.kind,
          reason: fetched.reason,
          statusCode: fetched.statusCode,
          retryAfter: fetched.retryAfter,
          outcome: MetadataRefreshOutcome.rejected,
          previousFreshness: previousFreshness,
        ),
      MetadataFetchFailed() => await _reduceFailure(
          url,
          previous,
          kind: fetched.kind,
          reason: fetched.reason,
          statusCode: fetched.statusCode,
          outcome: MetadataRefreshOutcome.failed,
          previousFreshness: previousFreshness,
        ),
    };
    _logFetch(url, result);
    return result;
  }

  Future<MetadataRefreshResult> _reduceModified(
    String url,
    Metadata? previous,
    MetadataModified fetched,
  ) async {
    final candidate = fetched.candidate;
    final incomingTitle = _normalized(candidate.title);
    final previousTitle = previous?.title;
    final title = incomingTitle != null && isDefaultTitle(incomingTitle, url)
        ? previousTitle
        : _keepIncomingOrPrevious(candidate.title, previousTitle);
    final description =
        _keepIncomingOrPrevious(candidate.description, previous?.description);
    final imageUrl =
        _keepIncomingOrPrevious(candidate.imageUrl, previous?.imageUrl);

    final changed = previous == null ||
        hasContentChanged(
          oldTitle: previous.title,
          newTitle: title,
          oldDescription: previous.description,
          newDescription: description,
          oldImage: previous.imageUrl,
          newImage: imageUrl,
        );
    final consecutiveUnchanged =
        changed ? 0 : previous.consecutiveUnchanged + 1;
    final baseDays = computeInitialTtl(title: title, url: url);
    final ttlDays = applyJitter(
      changed
          ? baseDays
          : computeAdaptiveTtl(
              baseDays: baseDays,
              consecutiveUnchanged: consecutiveUnchanged,
            ),
      random: _ttlRandom,
    );
    final metadata = Metadata(
      url: url,
      resolvedUrl:
          _normalized(candidate.resolvedUrl) ?? previous?.resolvedUrl ?? url,
      title: title,
      description: description,
      imageUrl: imageUrl,
      fetchedAt: _now(),
      ttlDays: ttlDays,
      etag: candidate.etag ?? previous?.etag,
      lastModified: candidate.lastModified ?? previous?.lastModified,
      contentHash: candidate.contentHash ?? previous?.contentHash,
      consecutiveUnchanged: consecutiveUnchanged,
    );

    return _saveSuccess(
      url,
      metadata,
      changed
          ? MetadataRefreshOutcome.updated
          : MetadataRefreshOutcome.unchanged,
    );
  }

  Future<MetadataRefreshResult> _reduceNotModified(
    String url,
    Metadata? previous,
    MetadataNotModified fetched,
  ) async {
    if (previous == null) {
      return _reduceFailure(
        url,
        null,
        kind: MetadataFailureKind.malformed,
        reason: "304 response requires a previous metadata snapshot",
        outcome: MetadataRefreshOutcome.failed,
        previousFreshness: null,
      );
    }

    final consecutiveUnchanged = previous.consecutiveUnchanged + 1;
    final baseDays = computeInitialTtl(title: previous.title, url: url);
    final ttlDays = applyJitter(
      computeAdaptiveTtl(
        baseDays: baseDays,
        consecutiveUnchanged: consecutiveUnchanged,
      ),
      random: _ttlRandom,
    );
    final metadata = previous.copyWith(
      url: url,
      resolvedUrl:
          _normalized(fetched.resolvedUrl) ?? previous.resolvedUrl ?? url,
      fetchedAt: _now(),
      ttlDays: ttlDays,
      etag: fetched.etag ?? previous.etag,
      lastModified: fetched.lastModified ?? previous.lastModified,
      consecutiveUnchanged: consecutiveUnchanged,
    );
    return _saveSuccess(url, metadata, MetadataRefreshOutcome.unchanged);
  }

  Future<MetadataRefreshResult> _saveSuccess(
    String url,
    Metadata metadata,
    MetadataRefreshOutcome outcome,
  ) async {
    await _cache.set(metadata);
    await _failures.recordSuccess(url);
    _domainCircuitBreaker.recordSuccess(url);
    final state = MetadataState.available(
      data: metadata,
      freshness: MetadataFreshness.fresh,
    );
    _emit(url, state);
    return MetadataRefreshResult(url: url, outcome: outcome, state: state);
  }

  Future<MetadataRefreshResult> _reduceFailure(
    String url,
    Metadata? previous, {
    required MetadataFailureKind kind,
    required String reason,
    required MetadataRefreshOutcome outcome,
    int? statusCode,
    Duration? retryAfter,
    required MetadataFreshness? previousFreshness,
  }) async {
    final record = await _failures.recordFailure(
      url,
      kind: kind,
      statusCode: statusCode,
      retryAfter: retryAfter,
    );
    _domainCircuitBreaker.recordFailure(
      url,
      kind: kind,
      retryAfter: retryAfter,
    );
    final failure = MetadataRefreshFailure(
      kind: record.lastFailureKind ?? kind,
      reason: reason,
      attemptCount: record.consecutiveFailures,
      statusCode: record.lastStatusCode,
      nextRetryAt: record.nextRetryAt,
    );
    final state = previous == null
        ? MetadataState.unavailable(
            refreshPhase: MetadataRefreshPhase.failed,
            lastFailure: failure,
          )
        : MetadataState.available(
            data: previous,
            freshness: previousFreshness ?? MetadataFreshness.stale,
            refreshPhase: MetadataRefreshPhase.failed,
            lastFailure: failure,
          );
    _emit(url, state);
    loggerGlobal.warning(
      _source,
      "Fetch ${outcome.name} for: $url | failures=${record.consecutiveFailures}",
    );
    return MetadataRefreshResult(url: url, outcome: outcome, state: state);
  }

  String? _normalized(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String? _keepIncomingOrPrevious(String? incoming, String? previous) =>
      _normalized(incoming) ?? previous;

  void _logFetch(String url, MetadataRefreshResult result) {
    try {
      _onFetchLogged?.call(url, result);
    } catch (error) {
      loggerGlobal.fine(_source, "Fetch log callback failed for $url: $error");
    }
  }
  // ---------------------------------------------------------------------------
  // Internal: concurrency + throttling
  // ---------------------------------------------------------------------------

  /// Wait for a free slot in the concurrency pool.
  Future<void> _acquireSlot() async {
    if (_activeFetches < _maxConcurrent) {
      _activeFetches++;
      return;
    }
    final completer = Completer<void>();
    _slotQueue.add(completer);
    await completer.future;
  }

  /// Release a slot, waking the next queued fetch if any.
  void _releaseSlot() {
    if (_slotQueue.isNotEmpty) {
      _slotQueue.removeFirst().complete();
    } else if (_activeFetches > 0) {
      _activeFetches--;
    }
  }

  /// Enforce a minimum delay between requests to the same domain.
  ///
  /// Opportunistically prunes throttle entries that have aged past the
  /// delay window: once an entry is older than [_domainDelay] it can no
  /// longer cause a wait, so keeping it would only grow the map without
  /// bound (one stranded entry per distinct host ever fetched).
  Future<void> _throttleDomain(String url) async {
    final domain = Uri.parse(url).host.toLowerCase();
    if (domain.isEmpty) return;

    _pruneDomainThrottle();
    final now = _now();
    final previousReservation = _reservedDomainStart[domain];
    final nextAfterPrevious = previousReservation?.add(_domainDelay);
    final reservedStart =
        nextAfterPrevious != null && nextAfterPrevious.isAfter(now)
            ? nextAfterPrevious
            : now;
    _reservedDomainStart[domain] = reservedStart;

    final wait = reservedStart.difference(now);
    if (wait > Duration.zero) {
      await _delay(wait);
    }
  }

  /// Drop throttle entries older than the delay window — they no longer
  /// affect throttling decisions.
  void _pruneDomainThrottle() {
    if (_reservedDomainStart.isEmpty) return;
    final cutoff = _now().subtract(_domainDelay);
    _reservedDomainStart.removeWhere((_, when) => !when.isAfter(cutoff));
  }

  // ---------------------------------------------------------------------------
  // Internal: signal cache (bounded, LRU)
  // ---------------------------------------------------------------------------

  /// Insert a freshly created signal as most-recently-used, evicting the
  /// least-recently-used entry (and disposing its signal) past the cap.
  void _putSignal(String url, Signal<MetadataState> s) {
    _signals[url] = s; // LinkedHashMap keeps insertion (= recency) order
    if (_signals.length > _signalCapacity) {
      final lruKey = _signals.keys.first;
      final evicted = _signals.remove(lruKey);
      evicted?.dispose();
    }
  }

  /// Mark [url]'s signal as most-recently-used by reinserting it at the
  /// tail of the access-ordered map.
  void _touch(String url) {
    final s = _signals.remove(url);
    if (s != null) _signals[url] = s;
  }

  /// Write [state] to [url]'s signal, but only if the service is still
  /// live and that exact signal is still the cached one (it may have
  /// been evicted or the service disposed while a fetch was in flight).
  /// Prevents "wrote to a disposed signal" errors from late fetches.
  void _emit(String url, MetadataState state) {
    if (_disposed) return;
    final s = _signals[url];
    if (s == null || s.disposed) return;
    s.value = state;
  }

  // ---------------------------------------------------------------------------
  // Maintenance + teardown
  // ---------------------------------------------------------------------------

  /// Opportunistic, allocation-light maintenance: prune the per-domain
  /// throttle map and stale failure history. Safe to call periodically
  /// (e.g. alongside [refreshStaleEntries]).
  void cleanupStale() {
    _pruneDomainThrottle();
    _failures.cleanupStale();
    _domainCircuitBreaker.cleanup();
  }

  /// Release every owned resource: dispose all per-URL signals, clear
  /// the signal/in-flight/throttle maps, and drain the slot queue.
  ///
  /// Idempotent. After disposal [watch] returns an inert disposed signal
  /// and fetches are no-ops; any fetch still in flight resolves without
  /// writing to (or resurrecting) a signal.
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    for (final s in _signals.values) {
      s.dispose();
    }
    _signals.clear();
    _inFlight.clear();
    _reservedDomainStart.clear();

    // Wake anything still parked on a slot so awaiters don't hang.
    while (_slotQueue.isNotEmpty) {
      _slotQueue.removeFirst().complete();
    }
    _activeFetches = 0;
  }

  // ---------------------------------------------------------------------------
  // Diagnostics (mirrors MetadataCache.memoryCacheSize/-Capacity)
  // ---------------------------------------------------------------------------

  /// Number of per-URL signals currently retained.
  int get signalCacheSize => _signals.length;

  /// Configured cap on retained per-URL signals.
  int get signalCacheCapacity => _signalCapacity;

  /// Number of domains currently tracked for throttling.
  int get domainThrottleMapSize => _reservedDomainStart.length;
}
