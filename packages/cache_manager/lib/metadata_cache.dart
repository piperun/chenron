import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
      return _memoryCache[url] as Map<String, dynamic>?;
    }

    // Check persistent cache
    try {
      final prefs = await _sharedPrefs;
      final key = 'metadata_$url';
      final cached = prefs.getString(key);
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        _memoryCache[url] = json;
        return json;
      }
    } catch (e) {
      // Log error if needed
    }
    return null;
  }

  /// Save metadata to cache (both memory and persistent)
  static Future<void> set(String url, Map<String, dynamic> metadata) async {
    _memoryCache[url] = metadata;
    
    try {
      final prefs = await _sharedPrefs;
      final key = 'metadata_$url';
      final json = jsonEncode(metadata);
      await prefs.setString(key, json);
    } catch (e) {
      // Log error if needed
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
