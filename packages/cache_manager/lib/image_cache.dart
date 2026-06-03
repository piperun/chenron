import 'dart:io';
import 'package:file/file.dart' as fs;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// [FileSystem] for `flutter_cache_manager` that stores cached files under an
/// explicit base directory instead of `flutter_cache_manager`'s default
/// (`getTemporaryDirectory()/cacheKey`). Wiring this into the [Config] makes
/// the directory the manager actually writes to match the directory
/// [ImageCacheManager] reports via [ImageCacheManager.getCacheDirectory] and
/// measures via [ImageCacheManager.getCacheSize].
class _BaseDirFileSystem implements FileSystem {
  _BaseDirFileSystem(this._basePath);

  final String _basePath;
  static const _local = LocalFileSystem();

  @override
  Future<fs.File> createFile(String name) async {
    final directory = _local.directory(_basePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.childFile(name);
  }
}

/// Manages image caching using `flutter_cache_manager`.
///
/// One instance models the app's single on-disk image cache. Register it as
/// a singleton (chenron does, in its locator) rather than constructing
/// ad-hoc instances, so every caller shares the same lazily-built
/// [CacheManager] and the same reported directory. Tests construct their own
/// instance for isolation instead of resetting shared state.
class ImageCacheManager {
  /// Default cache namespace key passed to `flutter_cache_manager`. Apps
  /// embedding this package can override via [initialize] to keep their
  /// caches isolated from a generic `images` namespace.
  static const String defaultCacheKey = "chenron_images";

  CacheManager? _cacheManager;
  String? _currentCachePath;
  String _currentCacheKey = defaultCacheKey;

  /// Initialize or update the cache manager with a custom path and/or
  /// namespace key. If [customPath] is null, uses the system temp
  /// directory under [cacheKey].
  Future<void> initialize({
    String? customPath,
    String cacheKey = defaultCacheKey,
  }) async {
    final cachePath = customPath ?? await _getDefaultCachePath(cacheKey);

    // Only recreate if path or key changed
    if (_currentCachePath != cachePath || _currentCacheKey != cacheKey) {
      _currentCachePath = cachePath;
      _currentCacheKey = cacheKey;
      _cacheManager = CacheManager(
        Config(
          cacheKey,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 200,
          fileService: HttpFileService(),
          // Store files under the resolved path so the directory the manager
          // writes to is the same one getCacheDirectory()/getCacheSize()
          // report. Without this the manager would fall back to
          // getTemporaryDirectory()/cacheKey and reporting would describe a
          // different folder than where the bytes actually land.
          fileSystem: _BaseDirFileSystem(cachePath),
        ),
      );
    }
  }

  /// Get default cache path (system temp directory under [cacheKey])
  Future<String> _getDefaultCachePath(String cacheKey) async {
    final tempDir = await getTemporaryDirectory();
    return path.join(tempDir.path, cacheKey);
  }

  /// Get the cache manager instance (async, initializes if needed)
  Future<CacheManager> get instance async {
    if (_cacheManager == null) {
      await initialize();
    }
    return _cacheManager!;
  }

  /// Clear all cached images
  Future<void> clearAll() async {
    final manager = await instance;
    await manager.emptyCache();
  }

  /// Get cache size in bytes by iterating through cache directory
  Future<int> getCacheSize() async {
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
  Future<void> removeFile(String url) async {
    final manager = await instance;
    await manager.removeFile(url);
  }

  /// Get current cache directory path
  Future<String> getCacheDirectory() async {
    if (_currentCachePath == null) {
      await initialize();
    }
    return _currentCachePath!;
  }
}
