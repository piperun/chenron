import "dart:collection";

import "package:app_logger/app_logger.dart";
import "package:cache_manager/src/metadata.dart";
import "package:cache_manager/src/metadata_persistence.dart";
import "package:cache_manager/src/metadata_refresh.dart";

const _source = "MetadataCache";

/// A verified cached snapshot paired with its freshness at lookup time.
class MetadataCacheLookup {
  final Metadata data;
  final MetadataFreshness freshness;

  const MetadataCacheLookup(this.data, this.freshness);
}

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

  /// Look up any verified snapshot and report whether it is fresh or stale.
  ///
  /// Both persistence hits and memory hits remain in the bounded LRU. A stale
  /// snapshot is still useful while its refresh is pending or unsuccessful,
  /// so expiration alone never deletes it.
  Future<MetadataCacheLookup?> lookup(String url, {DateTime? now}) async {
    final lookupTime = now ?? DateTime.now();
    final cached = _memoryCache.get(url);
    if (cached != null) {
      final freshness = _freshness(cached, lookupTime);
      loggerGlobal.fine(
        _source,
        "Memory cache HIT (${freshness.name.toUpperCase()}) for: $url | "
        "Title: ${cached.title ?? 'N/A'}",
      );
      return MetadataCacheLookup(cached, freshness);
    }

    if (_persistence == null) return null;
    try {
      final persisted = await _persistence!.get(url);
      if (persisted == null) {
        loggerGlobal.fine(_source, "Cache MISS for: $url");
        return null;
      }

      _memoryCache.put(url, persisted);
      final freshness = _freshness(persisted, lookupTime);
      loggerGlobal.fine(
        _source,
        "Persistent cache HIT (${freshness.name.toUpperCase()}) for: $url | "
        "Title: ${persisted.title ?? 'N/A'}",
      );
      return MetadataCacheLookup(persisted, freshness);
    } catch (e) {
      loggerGlobal.warning(_source, "Cache error for: $url | Error: $e");
      return null;
    }
  }

  /// Transitional fresh-only adapter for callers migrated in Task 6.
  @Deprecated("Use lookup; remove this adapter after Task 6 caller migration.")
  Future<Metadata?> get(String url) async {
    final result = await lookup(url);
    return result?.freshness == MetadataFreshness.fresh ? result!.data : null;
  }

  /// Transitional adapter that returns the snapshot regardless of freshness.
  Future<Metadata?> getStale(String url) async => (await lookup(url))?.data;

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
  bool isFresh(Metadata metadata) =>
      _freshness(metadata, DateTime.now()) == MetadataFreshness.fresh;

  MetadataFreshness _freshness(Metadata metadata, DateTime now) {
    final age = now.difference(metadata.fetchedAt);
    return age.inDays < metadata.ttlDays
        ? MetadataFreshness.fresh
        : MetadataFreshness.stale;
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
