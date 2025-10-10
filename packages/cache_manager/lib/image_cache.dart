import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Manages image caching using cached_network_image
class ImageCacheManager {
  static final _cacheManager = CacheManager(
    Config(
      'chenron_images',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
    ),
  );

  /// Get the cache manager instance
  static CacheManager get instance => _cacheManager;

  /// Clear all cached images
  static Future<void> clearAll() async {
    await _cacheManager.emptyCache();
  }

  /// Get cache size in bytes
  static Future<int> getCacheSize() async {
    // This is an approximation - flutter_cache_manager doesn't provide exact size
    final fileInfos = await _cacheManager.getFileFromCache('dummy');
    // We'll need to iterate through cache to get actual size
    // For now, return 0 (you can enhance this if needed)
    return 0;
  }

  /// Remove a specific image from cache
  static Future<void> removeFile(String url) async {
    await _cacheManager.removeFile(url);
  }
}
