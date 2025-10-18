import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logging/logging.dart';

final _logger = Logger('MetadataCache');

/// Manages persistent caching of metadata using SharedPreferences
class MetadataCache {
  static SharedPreferences? _prefs;
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _failedAttempts = {};
  static final Map<String, int> _failureCount = {};
  static final Set<String> _fetchingUrls = {};

  static Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get metadata from cache (memory first, then persistent)
  static Future<Map<String, dynamic>?> get(String url) async {
    // Check memory cache first
    if (_memoryCache.containsKey(url)) {
      final data = _memoryCache[url] as Map<String, dynamic>?;
      if (data != null && _isFresh(data)) {
        _logger.fine('Memory cache HIT (FRESH) for: $url | Title: ${data['title'] ?? 'N/A'}');
        return data;
      } else if (data != null) {
        _logger.fine('Memory cache HIT (STALE) for: $url | Title: ${data['title'] ?? 'N/A'}');
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
          _memoryCache[url] = json;
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
    
    _memoryCache[url] = metadataWithTimestamp;
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

  /// Check if we should retry fetching based on failure history
  static bool shouldRetry(String url) {
    if (!_failedAttempts.containsKey(url)) return true;
    
    final lastAttempt = _failedAttempts[url]!;
    final failureCount = _failureCount[url] ?? 0;
    
    // After 3 failures, mark as permanently failed
    if (failureCount >= 3) {
      return false;
    }
    
    // Exponential backoff: 1min, 5min, 15min
    final backoffMinutes = [1, 5, 15][failureCount.clamp(0, 2)];
    final shouldRetry = DateTime.now().difference(lastAttempt).inMinutes >= backoffMinutes;
    
    return shouldRetry;
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
}
