import "dart:io";

import "package:cache_manager/cache_manager.dart";
import "package:chenron/locator.dart";
import "package:flutter/foundation.dart";

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

  /// Clear the persistent metadata table + the in-memory LRU, then wipe
  /// the failure tracker so previously-blocked URLs aren't stuck in
  /// back-off after a manual purge.
  Future<void> clearMetadataCache() async {
    await locator.get<MetadataCache>().clearAll();
    locator.get<FailureTracker>().clearAll();
  }

  /// Total bytes used by the image cache directory.
  Future<int> getImageCacheSize() async {
    final path = await _resolveCachePath();
    return compute(_calculateDirSize, path);
  }

  static int _calculateDirSize(String path) {
    final dir = Directory(path);
    if (!dir.existsSync()) return 0;

    int total = 0;
    for (final entity in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          total += entity.statSync().size;
        } catch (_) {
          continue;
        }
      }
    }
    return total;
  }

  /// Number of metadata entries in persistent storage.
  Future<int> getMetadataCacheEntryCount() async {
    return locator.get<MetadataCache>().count();
  }
}
