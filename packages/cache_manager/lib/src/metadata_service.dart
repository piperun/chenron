import "dart:async";
import "dart:collection";

import "package:app_logger/app_logger.dart";
import "package:cache_manager/metadata_cache.dart";
import "package:cache_manager/src/failure_tracker.dart";
import "package:cache_manager/src/metadata.dart";
import "package:cache_manager/src/metadata_state.dart";
import "package:cache_manager/src/refresh_scheduler.dart";
import "package:cache_manager/src/ttl_strategy.dart";
import "package:signals/signals.dart";

const _source = "MetadataService";

/// Raw network result from a metadata fetcher.
///
/// The host app injects a fetcher callback that returns one of these.
/// Keeping the type small and plain (no freezed) — it crosses the
/// package boundary exactly once per fetch and doesn't need
/// JSON/equality machinery. `etag` and `contentHash` are optional so
/// fetchers that don't yet support conditional requests can return
/// `null` for them.
class RawFetchedMetadata {
  final String? title;
  final String? description;
  final String? imageUrl;

  /// Canonical URL reported by the fetcher (e.g. after redirects). The
  /// orchestrator falls back to the requested URL when this is null.
  final String? resolvedUrl;

  /// HTTP ETag if the fetcher captured one. Reserved for conditional
  /// request support; currently stored on [Metadata] but not used to
  /// short-circuit fetches.
  final String? etag;

  /// Hash of the fetched content for change detection. Reserved for
  /// future use; currently stored on [Metadata].
  final String? contentHash;

  const RawFetchedMetadata({
    this.title,
    this.description,
    this.imageUrl,
    this.resolvedUrl,
    this.etag,
    this.contentHash,
  });
}

/// Optional callback used by the service to log every fetch attempt
/// (e.g. into an activity-log table). Wrapping is the host app's job.
typedef OnFetchLogged = void Function(
  String url,
  bool succeeded, {
  String? error,
});

/// Network fetcher signature injected by the host app.
typedef MetadataFetcherFn = Future<RawFetchedMetadata> Function(String url);

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
  final MetadataFetcherFn _fetcher;
  final OnFetchLogged? _onFetchLogged;
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
  final LinkedHashMap<String, Signal<MetadataState>> _signals =
      LinkedHashMap();
  final int _signalCapacity;

  final Map<String, Future<MetadataState>> _inFlight = {};
  final Map<String, DateTime> _lastDomainFetch = {};
  int _activeFetches = 0;
  final Queue<Completer<void>> _slotQueue = Queue();

  bool _refreshingStale = false;
  bool _disposed = false;

  MetadataService({
    required MetadataCache cache,
    required FailureTracker failures,
    required MetadataFetcherFn fetcher,
    OnFetchLogged? onFetchLogged,
    int maxConcurrent = 3,
    Duration domainDelay = const Duration(milliseconds: 500),
    int signalCapacity = defaultSignalCapacity,
  })  : _cache = cache,
        _failures = failures,
        _fetcher = fetcher,
        _onFetchLogged = onFetchLogged,
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
      // Service is torn down — hand back an inert, already-disposed
      // signal and fetch nothing. Callers re-watch on the next live
      // service instance.
      return signal<MetadataState>(const MetadataState.loading())..dispose();
    }

    final existing = _signals[url];
    if (existing != null) {
      _touch(url); // promote to most-recently-used
      return existing;
    }

    final s = signal<MetadataState>(const MetadataState.loading());
    _putSignal(url, s);
    // Kick off the initial resolution asynchronously; errors are
    // absorbed into the signal state.
    unawaited(_resolve(url));
    return s;
  }

  /// Synchronously read the latest cached state for [url] without
  /// triggering a fetch. Returns [MetadataState.loading] if no signal
  /// yet exists for the URL.
  MetadataState peek(String url) {
    final s = _signals[url];
    if (s == null) return const MetadataState.loading();
    return s.value;
  }

  /// Force a fresh fetch, skipping the cache check and clearing failure
  /// history for [url]. The associated signal (created if absent) is
  /// flipped to `loading()` and then updated with the fetch result.
  ///
  /// If a fetch for [url] is already in flight, this coalesces onto it
  /// (same as [watch]) rather than issuing a second network call — the
  /// caller still gets the resolved state. Forcing is therefore safe to
  /// call repeatedly on an in-flight URL: no duplicate fetch, and no
  /// concurrency slot is stranded, because slot acquisition is owned by
  /// the single underlying fetch ([_doFetchInner]), not by the caller.
  Future<MetadataState> forceFetch(String url) {
    loggerGlobal.info(_source, "Force refresh requested: $url");
    if (_disposed) return Future.value(const MetadataState.loading());
    _failures.clearFailure(url);
    // Ensure the signal exists so observers don't miss the update.
    final s = _signals[url];
    if (s != null) {
      _touch(url);
      s.value = const MetadataState.loading();
    } else {
      _putSignal(url, signal<MetadataState>(const MetadataState.loading()));
    }

    // Slot acquire/release lives inside the real fetch path, so a
    // coalesced call never acquires a slot it can't release.
    return _doFetch(url);
  }

  /// Background refresh of all expired entries.
  ///
  /// Idempotent — concurrent calls collapse into one run. Returns the
  /// count of entries refreshed. Per-URL refreshes route through the
  /// same concurrency + throttling pipeline as [watch] / [forceFetch].
  Future<int> refreshStaleEntries() async {
    if (_disposed || _refreshingStale) return 0;
    _refreshingStale = true;
    loggerGlobal.info(_source, "Background refresh started");

    try {
      cleanupStale();
      final persistence = _cache.persistence;
      if (persistence == null) return 0;

      return await RefreshScheduler.processQueue(
        persistence: persistence,
        refreshOne: (url) async {
          if (_disposed) return false; // stop the queue; service is gone
          if (_inFlight.containsKey(url)) return true; // skip; not an error
          if (!_failures.shouldRetry(url)) return true; // backoff; skip
          // Slot acquire/release is owned by _doFetchInner.
          final state = await _doFetch(url);
          // `false` halts the queue — only when we hit a hard error.
          return state is! MetadataStateFailed;
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
    if (_signals[url] == null) {
      return; // disposed/cleared between scheduling and execution
    }

    // 1. Cache check.
    final cached = await _cache.get(url);
    if (cached != null) {
      _emit(url, MetadataState.ready(cached));
      return;
    }

    // 2. Failure back-off check.
    if (!_failures.shouldRetry(url)) {
      final count = _failures.failureCount(url);
      loggerGlobal.fine(_source, "Skipped (backoff): $url | failures=$count");
      _emit(url, MetadataState.failed("backoff", count));
      return;
    }

    // 3. In-flight coalescing — share a single fetch Future per URL.
    final inFlight = _inFlight[url];
    if (inFlight != null) {
      // Another caller is already fetching; await its result. The
      // signal will be updated by that fetch's _doFetchInner.
      await inFlight;
      return;
    }

    // Slot acquire/release is owned by _doFetchInner.
    await _doFetch(url);
  }

  /// Register (or coalesce onto) the single in-flight fetch for [url].
  ///
  /// Concurrent callers — including [forceFetch] — share the returned
  /// future. Slot acquisition is intentionally NOT done here: it lives
  /// in [_doFetchInner], the one place that actually performs a fetch,
  /// so a coalesced caller never acquires a slot it can't release.
  Future<MetadataState> _doFetch(String url) {
    final existing = _inFlight[url];
    if (existing != null) return existing;

    final future = _doFetchInner(url);
    _inFlight[url] = future;
    return future;
  }

  /// Perform the actual fetch with concurrency gating, throttling,
  /// change detection, and state propagation. Acquires exactly one
  /// concurrency slot and always releases it on exit, so acquire/release
  /// are paired 1:1 with a real fetch.
  Future<MetadataState> _doFetchInner(String url) async {
    // One acquire here, one release in `finally` — never stranded, even
    // when callers coalesce onto this future via [_doFetch].
    await _acquireSlot();

    try {
      // Read stale entry BEFORE fetching (for change comparison).
      final oldEntry = await _cache.getStale(url);
      final isFirstFetch = oldEntry == null;

      await _throttleDomain(url);
      final fetched = await _fetcher(url);
      final newTitle = fetched.title;
      final newDescription = fetched.description;
      final newImage = fetched.imageUrl;
      final resolvedUrl = fetched.resolvedUrl ?? url;

      // Compute adaptive TTL.
      int consecutiveUnchanged = 0;
      int ttlDays;

      if (oldEntry != null) {
        final changed = hasContentChanged(
          oldTitle: oldEntry.title,
          oldDescription: oldEntry.description,
          oldImage: oldEntry.imageUrl,
          newTitle: newTitle,
          newDescription: newDescription,
          newImage: newImage,
        );

        if (changed) {
          ttlDays = computeInitialTtl(title: newTitle, url: url);
          loggerGlobal.fine(
            _source,
            "Content CHANGED for: $url | TTL reset to ${ttlDays}d",
          );
        } else {
          consecutiveUnchanged = oldEntry.consecutiveUnchanged + 1;
          final baseDays = computeInitialTtl(title: newTitle, url: url);
          ttlDays = computeAdaptiveTtl(
            baseDays: baseDays,
            consecutiveUnchanged: consecutiveUnchanged,
          );
          loggerGlobal.fine(
            _source,
            "Content unchanged for: $url | streak=$consecutiveUnchanged | TTL escalated to ${ttlDays}d",
          );
        }
      } else {
        ttlDays = computeInitialTtl(title: newTitle, url: url);
        loggerGlobal.fine(
          _source,
          "First fetch for: $url | initial TTL=${ttlDays}d",
        );
      }

      ttlDays = applyJitter(ttlDays);

      final metadata = Metadata(
        url: resolvedUrl,
        title: newTitle,
        description: newDescription,
        imageUrl: newImage,
        fetchedAt: DateTime.now(),
        ttlDays: ttlDays,
        etag: fetched.etag,
        contentHash: fetched.contentHash,
        consecutiveUnchanged: consecutiveUnchanged,
      );

      await _cache.set(metadata);
      _failures.clearFailure(url);

      final newState = MetadataState.ready(metadata);
      _emit(url, newState);

      // Per the existing activity-log policy: log every initial fetch,
      // and only failures for subsequent fetches. TTL purges old rows.
      if (isFirstFetch) {
        _onFetchLogged?.call(url, true);
      }
      return newState;
    } catch (e) {
      _failures.recordFailure(url);
      final count = _failures.failureCount(url);
      loggerGlobal.warning(
        _source,
        "Fetch failed for: $url | failures=$count",
      );
      _onFetchLogged?.call(url, false, error: e.toString());
      final newState = MetadataState.failed(e.toString(), count);
      _emit(url, newState);
      return newState;
    } finally {
      _inFlight.remove(url);
      _releaseSlot();
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
    final domain = Uri.tryParse(url)?.host;
    if (domain == null || domain.isEmpty) return;

    _pruneDomainThrottle();

    final last = _lastDomainFetch[domain];
    if (last != null) {
      final elapsed = DateTime.now().difference(last);
      if (elapsed < _domainDelay) {
        await Future<void>.delayed(_domainDelay - elapsed);
      }
    }
    _lastDomainFetch[domain] = DateTime.now();
  }

  /// Drop throttle entries older than the delay window — they no longer
  /// affect throttling decisions.
  void _pruneDomainThrottle() {
    if (_lastDomainFetch.isEmpty) return;
    final cutoff = DateTime.now().subtract(_domainDelay);
    _lastDomainFetch.removeWhere((_, when) => when.isBefore(cutoff));
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
    _lastDomainFetch.clear();

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
  int get domainThrottleMapSize => _lastDomainFetch.length;
}
