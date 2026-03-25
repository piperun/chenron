import "dart:async";
import "dart:collection";

import "package:chenron/utils/metadata.dart";
import "package:cache_manager/cache_manager.dart";
import "package:signals/signals.dart";

class MetadataFactory {
  /// Emits the URL of the most recently force-refreshed metadata.
  static final lastRefreshedUrl = signal<String?>(null);

  static const _maxConcurrent = 3;
  static const _domainDelay = Duration(milliseconds: 500);

  static int _activeFetches = 0;
  static final _queue = Queue<Completer<void>>();
  static final Map<String, DateTime> _lastDomainFetch = {};

  /// Wait for a free slot in the concurrency pool.
  static Future<void> _acquireSlot() async {
    if (_activeFetches < _maxConcurrent) {
      _activeFetches++;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
  }

  /// Release a slot, waking the next queued fetch if any.
  static void _releaseSlot() {
    if (_queue.isNotEmpty) {
      _queue.removeFirst().complete();
    } else {
      _activeFetches--;
    }
  }

  /// Enforce a minimum delay between requests to the same domain.
  static Future<void> _throttleDomain(String url) async {
    final domain = Uri.tryParse(url)?.host;
    if (domain == null) return;

    final last = _lastDomainFetch[domain];
    if (last != null) {
      final elapsed = DateTime.now().difference(last);
      if (elapsed < _domainDelay) {
        await Future<void>.delayed(_domainDelay - elapsed);
      }
    }
    _lastDomainFetch[domain] = DateTime.now();
  }

  /// Perform the actual network fetch, detect content changes, and
  /// update the adaptive TTL accordingly.
  static Future<Map<String, dynamic>?> _fetchAndCache(String url) async {
    try {
      MetadataCache.startFetching(url);

      // Read old entry BEFORE fetching (for change comparison)
      final oldEntry = await MetadataCache.getStale(url);

      await _throttleDomain(url);
      final fetched = await MetadataFetcher.fetch(url);
      final newTitle = fetched.title;
      final newDescription = fetched.description;
      final newImage = fetched.image;

      // Compute adaptive TTL fields
      int consecutiveUnchanged = 0;
      int ttlDays;

      if (oldEntry != null) {
        final changed = hasContentChanged(
          oldTitle: oldEntry["title"] as String?,
          oldDescription: oldEntry["description"] as String?,
          oldImage: oldEntry["image"] as String?,
          newTitle: newTitle,
          newDescription: newDescription,
          newImage: newImage,
        );

        if (changed) {
          // Content changed — reset to initial TTL
          ttlDays = computeInitialTtl(title: newTitle, url: url);
        } else {
          // Content unchanged — escalate TTL.
          // Always use the initial heuristic TTL as the base, not the
          // stored ttlDays (which includes prior doubling + jitter).
          // This ensures clean exponential growth: base * 2^n.
          consecutiveUnchanged =
              ((oldEntry["consecutiveUnchanged"] as int?) ?? 0) + 1;
          final baseDays = computeInitialTtl(title: newTitle, url: url);
          ttlDays = computeAdaptiveTtl(
            baseDays: baseDays,
            consecutiveUnchanged: consecutiveUnchanged,
          );
        }
      } else {
        // First fetch — compute initial TTL from heuristics
        ttlDays = computeInitialTtl(title: newTitle, url: url);
      }

      // Apply jitter to spread out refreshes
      ttlDays = applyJitter(ttlDays);

      final data = <String, dynamic>{
        "title": newTitle,
        "description": newDescription,
        "image": newImage,
        "url": fetched.url ?? url,
        "consecutiveUnchanged": consecutiveUnchanged,
        "ttlDays": ttlDays,
      };

      await MetadataCache.set(url, data);
      MetadataCache.clearFailure(url);
      return data;
    } catch (e) {
      MetadataCache.recordFailure(url);
      return null;
    } finally {
      MetadataCache.stopFetching(url);
      _releaseSlot();
    }
  }

  /// Get cached metadata; if missing or stale, fetch fresh from web and cache it.
  ///
  /// At most [_maxConcurrent] fetches run in parallel; extras are queued.
  /// Requests to the same domain are throttled by [_domainDelay].
  static Future<Map<String, dynamic>?> getOrFetch(String url) async {
    final cached = await MetadataCache.get(url);
    if (cached != null) return cached;

    if (MetadataCache.isFetching(url)) return null;
    if (!MetadataCache.shouldRetry(url)) return null;

    await _acquireSlot();
    return _fetchAndCache(url);
  }

  /// Force a fresh fetch, ignoring cache and failure history.
  ///
  /// Used for manual "refresh metadata" actions. Unlike the original
  /// implementation, this no longer removes old data before fetching —
  /// `_fetchAndCache` reads the old entry for change comparison to
  /// update the adaptive TTL. If the fetch fails, the stale entry
  /// remains in persistence but `_isFresh` will still return false
  /// for it, so callers won't see stale data.
  static Future<Map<String, dynamic>?> forceFetch(String url) async {
    MetadataCache.clearFailure(url);

    await _acquireSlot();
    final result = await _fetchAndCache(url);
    if (result != null) {
      lastRefreshedUrl.value = null;
      lastRefreshedUrl.value = url;
    }
    return result;
  }

  /// Whether a background refresh is currently running.
  static bool _isRefreshing = false;

  /// Run a background refresh of all expired cache entries.
  ///
  /// Called once on app startup. Processes expired entries in priority
  /// order, rate-limited, using the existing concurrency pool.
  /// Safe to call multiple times — subsequent calls are no-ops while
  /// a refresh is already running.
  static Future<void> refreshStaleEntries() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final persistence = MetadataCache.persistence;
      if (persistence == null) return;

      await RefreshScheduler.processQueue(
        persistence: persistence,
        refreshOne: (url) async {
          if (MetadataCache.isFetching(url)) return true; // skip, not an error
          if (!MetadataCache.shouldRetry(url)) return true; // skip failed URLs

          await _acquireSlot();
          final result = await _fetchAndCache(url);
          return result != null; // false = probably rate limited, stop
        },
      );
    } finally {
      _isRefreshing = false;
    }
  }
}
