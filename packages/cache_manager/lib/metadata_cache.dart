import 'package:app_logger/app_logger.dart';
import 'package:cache_manager/src/metadata_persistence.dart';
import 'dart:collection';

const _source = 'MetadataCache';

/// Manages caching of metadata with an in-memory LRU layer and a
/// pluggable persistent backend ([MetadataPersistence]).
///
/// Call [init] once at startup to enable persistent storage.
/// Without it, only the in-memory LRU cache is active.
class MetadataCache {
  static MetadataPersistence? _persistence;
  static final _LRUCache<String, Map<String, dynamic>> _memoryCache =
      _LRUCache(maxSize: 100);
  static final Map<String, DateTime> _failedAttempts = {};
  static final Map<String, int> _failureCount = {};
  static final Set<String> _fetchingUrls = {};

  /// Inject the persistent storage backend. Call once at startup.
  static void init(MetadataPersistence persistence) {
    _persistence = persistence;
  }

  /// Get metadata from cache (memory first, then persistent)
  static Future<Map<String, dynamic>?> get(String url) async {
    // Check memory cache first (LRU automatically updates access order)
    final cachedData = _memoryCache.get(url);
    if (cachedData != null) {
      if (_isFresh(cachedData)) {
        loggerGlobal.fine(_source,
            'Memory cache HIT (FRESH) for: $url | Title: ${cachedData['title'] ?? 'N/A'}');
        return cachedData;
      } else {
        loggerGlobal.fine(_source,
            'Memory cache HIT (STALE) for: $url | Title: ${cachedData['title'] ?? 'N/A'}');
        // Remove stale entry from memory cache
        _memoryCache.remove(url);
        return null; // Stale data, return null to trigger refetch
      }
    }

    // Check persistent cache
    if (_persistence == null) return null;
    try {
      final cached = await _persistence!.get(url);
      if (cached != null) {
        if (_isFresh(cached)) {
          // Load into LRU memory cache
          _memoryCache.put(url, cached);
          loggerGlobal.fine(_source,
              'Persistent cache HIT (FRESH) for: $url | Title: ${cached['title'] ?? 'N/A'}');
          return cached;
        } else {
          loggerGlobal.fine(_source,
              'Persistent cache HIT (STALE) for: $url | Title: ${cached['title'] ?? 'N/A'} | Needs refetch');
          return null; // Stale data, return null to trigger refetch
        }
      } else {
        loggerGlobal.fine(_source, 'Cache MISS for: $url');
      }
    } catch (e) {
      loggerGlobal.warning(_source, 'Cache error for: $url | Error: $e');
    }
    return null;
  }

  /// Save metadata to cache (both memory and persistent)
  static Future<void> set(String url, Map<String, dynamic> metadata) async {
    // Add fetchedAt timestamp
    final metadataWithTimestamp = {
      ...metadata,
      'fetchedAt': DateTime.now().toIso8601String(),
    };

    // Store in LRU memory cache (automatically handles eviction)
    _memoryCache.put(url, metadataWithTimestamp);
    loggerGlobal.info(_source,
        'Cached metadata for: $url | Title: ${metadata['title'] ?? 'N/A'}');

    if (_persistence == null) return;
    try {
      await _persistence!.set(url, metadataWithTimestamp);
    } catch (e) {
      loggerGlobal.warning(
          _source, 'Failed to persist cache for: $url | Error: $e');
    }
  }

  /// Check if we should retry fetching based on failure history.
  ///
  /// Uses exponential backoff: 2min, 10min, 1hr, 6hr, 24hr (capped).
  /// Never permanently gives up — everything eventually retries.
  static bool shouldRetry(String url) {
    if (!_failedAttempts.containsKey(url)) return true;

    final lastAttempt = _failedAttempts[url]!;
    final failureCount = _failureCount[url] ?? 0;

    const backoffMinutes = [2, 10, 60, 360, 1440];
    final index = failureCount.clamp(0, backoffMinutes.length - 1);
    return DateTime.now().difference(lastAttempt).inMinutes >=
        backoffMinutes[index];
  }

  /// Record a failed fetch attempt
  static void recordFailure(String url) {
    _failedAttempts[url] = DateTime.now();
    _failureCount[url] = (_failureCount[url] ?? 0) + 1;
  }

  /// Number of consecutive failures recorded for [url].
  static int getFailureCount(String url) => _failureCount[url] ?? 0;

  /// Clear failure record on successful fetch
  static void clearFailure(String url) {
    _failedAttempts.remove(url);
    _failureCount.remove(url);
  }

  /// Remove failure records older than 30 days to prevent unbounded growth.
  static void cleanupStaleFailures() {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    _failedAttempts.removeWhere((_, time) => time.isBefore(cutoff));
    _failureCount.removeWhere((url, _) => !_failedAttempts.containsKey(url));
  }

  /// Check if URL is currently being fetched
  static bool isFetching(String url) => _fetchingUrls.contains(url);

  /// Mark URL as being fetched
  static void startFetching(String url) => _fetchingUrls.add(url);

  /// Mark URL as no longer being fetched
  static void stopFetching(String url) => _fetchingUrls.remove(url);

  /// Remove a single URL from both memory and persistent cache.
  static Future<void> remove(String url) async {
    _memoryCache.remove(url);
    try {
      await _persistence?.remove(url);
    } catch (_) {}
  }

  /// Clear all cached metadata
  static Future<void> clearAll() async {
    _memoryCache.clear();
    _failedAttempts.clear();
    _failureCount.clear();
    _fetchingUrls.clear();

    try {
      await _persistence?.clearAll();
    } catch (e) {
      loggerGlobal.warning(_source, 'Failed to clear persistent cache: $e');
    }
  }

  /// Check if cached metadata is fresh based on its per-entry TTL.
  ///
  /// Falls back to 7 days if the entry has no ttlDays field (pre-migration
  /// data).
  static bool _isFresh(Map<String, dynamic> metadata) {
    final fetchedAtStr = metadata['fetchedAt'] as String?;
    if (fetchedAtStr == null) return false;

    try {
      final fetchedAt = DateTime.parse(fetchedAtStr);
      final ttlDays = (metadata['ttlDays'] as int?) ?? 7;
      final age = DateTime.now().difference(fetchedAt);
      return age.inDays < ttlDays;
    } catch (e) {
      return false;
    }
  }

  /// Read cached metadata regardless of freshness.
  ///
  /// Used for change comparison during refresh — we need the old data
  /// to decide whether to escalate or reset the adaptive TTL.
  /// Does NOT promote into memory cache (the entry is stale).
  static Future<Map<String, dynamic>?> getStale(String url) async {
    // Check memory cache (may have been evicted or removed as stale)
    final memCached = _memoryCache.get(url);
    if (memCached != null) return memCached;

    if (_persistence == null) return null;
    try {
      return await _persistence!.get(url);
    } catch (e) {
      loggerGlobal.warning(_source, 'getStale error for: $url | Error: $e');
      return null;
    }
  }

  /// Access the persistence backend (for use by RefreshScheduler).
  /// Returns null if [init] has not been called.
  static MetadataPersistence? get persistence => _persistence;

  /// Get the number of persistently cached entries.
  static Future<int> getCacheEntryCount() async {
    try {
      return await _persistence?.count() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get memory cache statistics
  static Map<String, int> getMemoryCacheStats() {
    return {
      'size': _memoryCache.length,
      'maxSize': _memoryCache.maxSize,
    };
  }
}

/// Simple LRU (Least Recently Used) cache implementation
class _LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();

  _LRUCache({required this.maxSize});

  /// Get value from cache and update access order
  V? get(K key) {
    if (!_cache.containsKey(key)) return null;

    // Move to end (most recently used)
    final value = _cache.remove(key)!;
    _cache[key] = value;
    return value;
  }

  /// Put value into cache, evicting LRU entry if necessary
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      // Remove to update position
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // Remove least recently used (first entry)
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Remove entry from cache
  void remove(K key) {
    _cache.remove(key);
  }

  /// Check if key exists in cache
  bool containsKey(K key) {
    return _cache.containsKey(key);
  }

  /// Get current cache size
  int get length => _cache.length;

  /// Clear all entries
  void clear() {
    _cache.clear();
  }
}
