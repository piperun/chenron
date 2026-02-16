import "dart:async";
import "dart:collection";

import "package:chenron/utils/metadata.dart";
import "package:cache_manager/cache_manager.dart";

class MetadataFactory {
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

  /// Perform the actual network fetch (caller must hold a slot).
  static Future<Map<String, dynamic>?> _fetchAndCache(String url) async {
    try {
      await _throttleDomain(url);
      MetadataCache.startFetching(url);
      final fetched = await MetadataFetcher.fetch(url);
      final data = <String, dynamic>{
        "title": fetched.title,
        "description": fetched.description,
        "image": fetched.image,
        "url": fetched.url ?? url,
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
  /// Used for manual "refresh metadata" actions.
  static Future<Map<String, dynamic>?> forceFetch(String url) async {
    MetadataCache.clearFailure(url);
    await MetadataCache.remove(url);

    await _acquireSlot();
    return _fetchAndCache(url);
  }
}
