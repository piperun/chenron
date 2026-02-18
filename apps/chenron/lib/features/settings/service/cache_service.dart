import "dart:io";

import "package:cache_manager/cache_manager.dart";

/// Service for clearing image and metadata caches independently.
class CacheService {
  final Future<String> Function() _resolveCachePath;
  final Future<void> Function() _clearImageCacheManager;

  CacheService({
    required Future<String> Function() resolveCachePath,
    Future<void> Function()? clearImageCacheManager,
  })  : _resolveCachePath = resolveCachePath,
        _clearImageCacheManager =
            clearImageCacheManager ?? ImageCacheManager.clearAll;

  /// Delete downloaded image files and reset flutter_cache_manager state.
  Future<void> clearImageCache() async {
    final path = await _resolveCachePath();
    final cacheDir = Directory(path);
    if (cacheDir.existsSync()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create(recursive: true);
    }
    await _clearImageCacheManager();
  }

  /// Clear in-memory LRU, failure tracking, and persistent metadata table.
  Future<void> clearMetadataCache() async {
    await MetadataCache.clearAll();
  }

  /// Total bytes used by the image cache directory.
  Future<int> getImageCacheSize() async {
    try {
      final path = await _resolveCachePath();
      final cacheDir = Directory(path);
      if (!cacheDir.existsSync()) return 0;

      int total = 0;
      await for (final entity
          in cacheDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            total += entity.statSync().size;
          } catch (_) {
            continue;
          }
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Number of metadata entries in persistent storage.
  Future<int> getMetadataCacheEntryCount() async {
    return MetadataCache.getCacheEntryCount();
  }
}
