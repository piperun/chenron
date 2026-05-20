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

  final Map<String, Signal<MetadataState>> _signals = {};
  final Map<String, Future<MetadataState>> _inFlight = {};
  final Map<String, DateTime> _lastDomainFetch = {};
  int _activeFetches = 0;
  final Queue<Completer<void>> _slotQueue = Queue();

  bool _refreshingStale = false;

  MetadataService({
    required MetadataCache cache,
    required FailureTracker failures,
    required MetadataFetcherFn fetcher,
    OnFetchLogged? onFetchLogged,
    int maxConcurrent = 3,
    Duration domainDelay = const Duration(milliseconds: 500),
  })  : _cache = cache,
        _failures = failures,
        _fetcher = fetcher,
        _onFetchLogged = onFetchLogged,
        _maxConcurrent = maxConcurrent,
        _domainDelay = domainDelay;

  /// Returns a long-lived signal that emits [MetadataState] for [url].
  ///
  /// Multiple callers for the same URL share the same signal instance.
  /// First caller triggers an initial fetch if cache miss; subsequent
  /// callers see the current state immediately.
  Signal<MetadataState> watch(String url) {
    final existing = _signals[url];
    if (existing != null) return existing;

    final s = signal<MetadataState>(const MetadataState.loading());
    _signals[url] = s;
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

  /// Force a fresh fetch, ignoring cache + failure history.
  ///
  /// Skips the cache check, clears failure history for the URL, and
  /// bypasses the in-flight de-dup. The associated signal (if any) is
  /// updated as part of the fetch.
  Future<MetadataState> forceFetch(String url) async {
    loggerGlobal.info(_source, "Force refresh requested: $url");
    _failures.clearFailure(url);
    // Ensure the signal exists so observers don't miss the update.
    final s = _signals[url] ??
        (_signals[url] = signal<MetadataState>(const MetadataState.loading()));
    s.value = const MetadataState.loading();

    await _acquireSlot();
    return _doFetch(url);
  }

  /// Background refresh of all expired entries.
  ///
  /// Idempotent — concurrent calls collapse into one run. Returns the
  /// count of entries refreshed. Per-URL refreshes route through the
  /// same concurrency + throttling pipeline as [watch] / [forceFetch].
  Future<int> refreshStaleEntries() async {
    if (_refreshingStale) return 0;
    _refreshingStale = true;
    loggerGlobal.info(_source, "Background refresh started");

    try {
      _failures.cleanupStale();
      final persistence = _cache.persistence;
      if (persistence == null) return 0;

      return await RefreshScheduler.processQueue(
        persistence: persistence,
        refreshOne: (url) async {
          if (_inFlight.containsKey(url)) return true; // skip; not an error
          if (!_failures.shouldRetry(url)) return true; // backoff; skip
          await _acquireSlot();
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
    final s = _signals[url];
    if (s == null) return; // disposed/cleared between scheduling and execution

    // 1. Cache check.
    final cached = await _cache.get(url);
    if (cached != null) {
      s.value = MetadataState.ready(cached);
      return;
    }

    // 2. Failure back-off check.
    if (!_failures.shouldRetry(url)) {
      final count = _failures.failureCount(url);
      loggerGlobal.fine(_source, "Skipped (backoff): $url | failures=$count");
      s.value = MetadataState.failed("backoff", count);
      return;
    }

    // 3. In-flight coalescing — share a single fetch Future per URL.
    final inFlight = _inFlight[url];
    if (inFlight != null) {
      // Another caller is already fetching; await its result. The
      // signal will be updated by that fetch's _doFetch.
      await inFlight;
      return;
    }

    await _acquireSlot();
    await _doFetch(url);
  }

  /// Perform the actual fetch with throttling, change detection, and
  /// state propagation. Always releases the concurrency slot on exit.
  Future<MetadataState> _doFetch(String url) {
    final existing = _inFlight[url];
    if (existing != null) return existing;

    final future = _doFetchInner(url);
    _inFlight[url] = future;
    return future;
  }

  Future<MetadataState> _doFetchInner(String url) async {
    final s = _signals[url] ??
        (_signals[url] = signal<MetadataState>(const MetadataState.loading()));

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
      s.value = newState;

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
      s.value = newState;
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
  Future<void> _throttleDomain(String url) async {
    final domain = Uri.tryParse(url)?.host;
    if (domain == null || domain.isEmpty) return;

    final last = _lastDomainFetch[domain];
    if (last != null) {
      final elapsed = DateTime.now().difference(last);
      if (elapsed < _domainDelay) {
        await Future<void>.delayed(_domainDelay - elapsed);
      }
    }
    _lastDomainFetch[domain] = DateTime.now();
  }
}
