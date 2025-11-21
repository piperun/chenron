import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Manages image caching using flutter_cache_manager
class ImageCacheManager {
  static CacheManager? _cacheManager;
  static String? _currentCachePath;

  /// Initialize or update the cache manager with a custom path
  /// If [customPath] is null, uses system temp directory
  static Future<void> initialize({String? customPath}) async {
    final cachePath = customPath ?? await _getDefaultCachePath();

    // Only recreate if path changed
    if (_currentCachePath != cachePath) {
      _currentCachePath = cachePath;
      _cacheManager = CacheManager(
        Config(
          'chenron_images',
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 200,
          fileService: HttpFileService(),
          // Use custom path or default temp dir
        ),
      );
    }
  }

  /// Get default cache path (system temp directory)
  static Future<String> _getDefaultCachePath() async {
    final tempDir = await getTemporaryDirectory();
    return path.join(tempDir.path, 'chenron_images');
  }

  /// Get the cache manager instance
  static Future<CacheManager> get instance async {
    if (_cacheManager == null) {
      await initialize();
    }
    return _cacheManager!;
  }

  /// Clear all cached images
  static Future<void> clearAll() async {
    final manager = await instance;
    await manager.emptyCache();
  }

  /// Get cache size in bytes by iterating through cache directory
  static Future<int> getCacheSize() async {
    try {
      if (_currentCachePath == null) {
        await initialize();
      }

      final cacheDir = Directory(_currentCachePath!);

      if (!await cacheDir.exists()) {
        return 0;
      }

      int totalSize = 0;

      // Recursively calculate size of all files in cache directory
      await for (final entity
          in cacheDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            totalSize += stat.size;
          } catch (e) {
            // Skip files that can't be accessed
            continue;
          }
        }
      }

      return totalSize;
    } catch (e) {
      // If we can't access the cache directory, return 0
      return 0;
    }
  }

  /// Remove a specific image from cache
  static Future<void> removeFile(String url) async {
    final manager = await instance;
    await manager.removeFile(url);
  }

  /// Get current cache directory path
  static Future<String> getCacheDirectory() async {
    if (_currentCachePath == null) {
      await initialize();
    }
    return _currentCachePath!;
  }
}
