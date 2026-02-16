import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'dart:collection';

final _logger = Logger('MetadataCache');

/// Manages persistent caching of metadata using SharedPreferences with LRU eviction
class MetadataCache {
  static SharedPreferences? _prefs;
  static final _LRUCache<String, Map<String, dynamic>> _memoryCache = _LRUCache(maxSize: 100);
  static final Map<String, DateTime> _failedAttempts = {};
  static final Map<String, int> _failureCount = {};
  static final Set<String> _fetchingUrls = {};

  static Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get metadata from cache (memory first, then persistent)
  static Future<Map<String, dynamic>?> get(String url) async {
    // Check memory cache first (LRU automatically updates access order)
    final cachedData = _memoryCache.get(url);
    if (cachedData != null) {
      if (_isFresh(cachedData)) {
        _logger.fine('Memory cache HIT (FRESH) for: $url | Title: ${cachedData['title'] ?? 'N/A'}');
        return cachedData;
      } else {
        _logger.fine('Memory cache HIT (STALE) for: $url | Title: ${cachedData['title'] ?? 'N/A'}');
        // Remove stale entry from memory cache
        _memoryCache.remove(url);
        return null; // Stale data, return null to trigger refetch
      }
    }

    // Check persistent cache
    try {
      final prefs = await _sharedPrefs;
      final key = 'metadata_$url';
      final cached = prefs.getString(key);
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        if (_isFresh(json)) {
          // Load into LRU memory cache
          _memoryCache.put(url, json);
          _logger.fine('Persistent cache HIT (FRESH) for: $url | Title: ${json['title'] ?? 'N/A'}');
          return json;
        } else {
          _logger.fine('Persistent cache HIT (STALE) for: $url | Title: ${json['title'] ?? 'N/A'} | Needs refetch');
          return null; // Stale data, return null to trigger refetch
        }
      } else {
        _logger.fine('Cache MISS for: $url');
      }
    } catch (e) {
      _logger.warning('Cache error for: $url | Error: $e');
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
    _logger.info('Cached metadata for: $url | Title: ${metadata['title'] ?? 'N/A'}');
    
    try {
      final prefs = await _sharedPrefs;
      final key = 'metadata_$url';
      final json = jsonEncode(metadataWithTimestamp);
      await prefs.setString(key, json);
    } catch (e) {
      _logger.warning('Failed to persist cache for: $url | Error: $e');
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
    return DateTime.now().difference(lastAttempt).inMinutes >= backoffMinutes[index];
  }

  /// Record a failed fetch attempt
  static void recordFailure(String url) {
    _failedAttempts[url] = DateTime.now();
    _failureCount[url] = (_failureCount[url] ?? 0) + 1;
  }

  /// Clear failure record on successful fetch
  static void clearFailure(String url) {
    _failedAttempts.remove(url);
    _failureCount.remove(url);
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
      final prefs = await _sharedPrefs;
      await prefs.remove('metadata_$url');
    } catch (_) {}
  }

  /// Clear all cached metadata
  static Future<void> clearAll() async {
    _memoryCache.clear();
    _failedAttempts.clear();
    _failureCount.clear();
    _fetchingUrls.clear();
    
    try {
      final prefs = await _sharedPrefs;
      final keys = prefs.getKeys().where((key) => key.startsWith('metadata_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Log error if needed
    }
  }

  /// Check if cached metadata is fresh (less than 7 days old)
  static bool _isFresh(Map<String, dynamic> metadata) {
    final fetchedAtStr = metadata['fetchedAt'] as String?;
    if (fetchedAtStr == null) {
      // Old cache format without timestamp - consider stale
      return false;
    }
    
    try {
      final fetchedAt = DateTime.parse(fetchedAtStr);
      final age = DateTime.now().difference(fetchedAt);
      final isFresh = age.inDays < 7;
      return isFresh;
    } catch (e) {
      // Invalid timestamp - consider stale
      return false;
    }
  }

  /// Get cache size information
  static Future<int> getCacheSize() async {
    try {
      final prefs = await _sharedPrefs;
      final keys = prefs.getKeys().where((key) => key.startsWith('metadata_'));
      int totalSize = 0;
      for (final key in keys) {
        final value = prefs.getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }
      return totalSize;
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
