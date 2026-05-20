import "dart:collection";

import "package:app_logger/app_logger.dart";
import "package:cache_manager/src/metadata.dart";
import "package:cache_manager/src/metadata_persistence.dart";

const _source = "MetadataCache";

/// Typed metadata storage with an in-memory LRU layer plus a pluggable
/// persistent backend ([MetadataPersistence]).
///
/// This is intentionally storage-only — failure tracking lives in
/// `FailureTracker` and in-flight coalescing / concurrency live in
/// `MetadataService`. Constructed with the persistence backend (or
/// attached later via [attachPersistence]); without persistence, only
/// the in-memory LRU cache is active.
class MetadataCache {
  MetadataPersistence? _persistence;
  final _LRUCache<String, Metadata> _memoryCache = _LRUCache(maxSize: 100);

  MetadataCache({MetadataPersistence? persistence})
      : _persistence = persistence;

  /// Inject (or replace) the persistent storage backend. Useful when
  /// the persistence layer is only available after database setup.
  void attachPersistence(MetadataPersistence persistence) {
    _persistence = persistence;
  }

  /// Get fresh metadata. Returns `null` on miss OR if cached data is
  /// stale (caller decides whether to re-fetch).
  Future<Metadata?> get(String url) async {
    final cached = _memoryCache.get(url);
    if (cached != null) {
      if (isFresh(cached)) {
        loggerGlobal.fine(
          _source,
          "Memory cache HIT (FRESH) for: $url | Title: ${cached.title ?? 'N/A'}",
        );
        return cached;
      }
      loggerGlobal.fine(
        _source,
        "Memory cache HIT (STALE) for: $url | Title: ${cached.title ?? 'N/A'}",
      );
      _memoryCache.remove(url);
      return null;
    }

    if (_persistence == null) return null;
    try {
      final persisted = await _persistence!.get(url);
      if (persisted == null) {
        loggerGlobal.fine(_source, "Cache MISS for: $url");
        return null;
      }
      if (isFresh(persisted)) {
        _memoryCache.put(url, persisted);
        loggerGlobal.fine(
          _source,
          "Persistent cache HIT (FRESH) for: $url | Title: ${persisted.title ?? 'N/A'}",
        );
        return persisted;
      }
      loggerGlobal.fine(
        _source,
        "Persistent cache HIT (STALE) for: $url | Title: ${persisted.title ?? 'N/A'} | Needs refetch",
      );
      return null;
    } catch (e) {
      loggerGlobal.warning(_source, "Cache error for: $url | Error: $e");
      return null;
    }
  }

  /// Get any cached metadata, even if stale. Used by the fetcher to
  /// compare against new fetches for change detection. Does not promote
  /// into the LRU memory cache (the entry is, by definition, stale).
  Future<Metadata?> getStale(String url) async {
    final memCached = _memoryCache.get(url);
    if (memCached != null) return memCached;

    if (_persistence == null) return null;
    try {
      return await _persistence!.get(url);
    } catch (e) {
      loggerGlobal.warning(_source, "getStale error for: $url | Error: $e");
      return null;
    }
  }

  /// Store fresh metadata in both memory and persistence.
  ///
  /// The URL is taken from [metadata.url].
  Future<void> set(Metadata metadata) async {
    _memoryCache.put(metadata.url, metadata);
    loggerGlobal.info(
      _source,
      "Cached metadata for: ${metadata.url} | Title: ${metadata.title ?? 'N/A'}",
    );

    if (_persistence == null) return;
    try {
      await _persistence!.set(metadata);
    } catch (e) {
      loggerGlobal.warning(
        _source,
        "Failed to persist cache for: ${metadata.url} | Error: $e",
      );
    }
  }

  /// Remove a single URL from both memory and persistent cache.
  Future<void> remove(String url) async {
    _memoryCache.remove(url);
    try {
      await _persistence?.remove(url);
    } catch (_) {}
  }

  /// Clear all cached metadata (memory + persistence).
  Future<void> clearAll() async {
    _memoryCache.clear();
    try {
      await _persistence?.clearAll();
    } catch (e) {
      loggerGlobal.warning(_source, "Failed to clear persistent cache: $e");
    }
  }

  /// Number of persistently cached entries (0 if persistence is
  /// unavailable or the count call fails).
  Future<int> count() async {
    try {
      return await _persistence?.count() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Entries whose per-entry TTL has expired, sourced from persistence.
  Future<List<Metadata>> getExpiredEntries() async {
    if (_persistence == null) return const [];
    try {
      return await _persistence!.getExpiredEntries();
    } catch (e) {
      loggerGlobal.warning(_source, "getExpiredEntries failed: $e");
      return const [];
    }
  }

  /// `true` iff [metadata.fetchedAt] + [metadata.ttlDays] is in the
  /// future. Public so `MetadataService` can decide refresh policy.
  bool isFresh(Metadata metadata) {
    final age = DateTime.now().difference(metadata.fetchedAt);
    return age.inDays < metadata.ttlDays;
  }

  /// Persistence backend (for use by `RefreshScheduler` /
  /// `MetadataService`). `null` if no backend has been attached.
  MetadataPersistence? get persistence => _persistence;

  /// Current size of the in-memory LRU cache.
  int get memoryCacheSize => _memoryCache.length;

  /// Configured capacity of the in-memory LRU cache.
  int get memoryCacheCapacity => _memoryCache.maxSize;
}

/// Simple LRU (Least Recently Used) cache implementation.
class _LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();

  _LRUCache({required this.maxSize});

  /// Get value from cache and update access order.
  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    final value = _cache.remove(key) as V;
    _cache[key] = value;
    return value;
  }

  /// Put value into cache, evicting the LRU entry if necessary.
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Remove entry from cache.
  void remove(K key) {
    _cache.remove(key);
  }

  /// Whether the key is in cache.
  bool containsKey(K key) {
    return _cache.containsKey(key);
  }

  /// Current cache size.
  int get length => _cache.length;

  /// Clear all entries.
  void clear() {
    _cache.clear();
  }
}
