import "dart:io";

import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron/features/settings/service/cache_service.dart";

/// In-memory fake persistence for MetadataCache tests.
class FakeMetadataPersistence implements MetadataPersistence {
  final Map<String, Map<String, dynamic>> _store = {};

  @override
  Future<Map<String, dynamic>?> get(String url) async => _store[url];

  @override
  Future<void> set(String url, Map<String, dynamic> metadata) async {
    _store[url] = metadata;
  }

  @override
  Future<void> remove(String url) async => _store.remove(url);

  @override
  Future<void> clearAll() async => _store.clear();

  @override
  Future<int> count() async => _store.length;
}

void main() {
  late Directory tempDir;
  late FakeMetadataPersistence fakePersistence;
  bool imageCacheManagerCleared = false;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp("cache_service_test_");
    fakePersistence = FakeMetadataPersistence();
    MetadataCache.init(fakePersistence);
    imageCacheManagerCleared = false;
  });

  tearDown(() async {
    await MetadataCache.clearAll();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  CacheService createService() {
    return CacheService(
      resolveCachePath: () async => tempDir.path,
      clearImageCacheManager: () async {
        imageCacheManagerCleared = true;
      },
    );
  }

  /// Helper to create dummy files in the temp directory.
  Future<void> seedFiles(Map<String, List<int>> files) async {
    for (final entry in files.entries) {
      final file = File("${tempDir.path}/${entry.key}");
      await file.parent.create(recursive: true);
      await file.writeAsBytes(entry.value);
    }
  }

  group("clearImageCache", () {
    test("deletes files and recreates empty directory", () async {
      final service = createService();
      await seedFiles({
        "image1.jpg": List.filled(100, 0),
        "image2.png": List.filled(200, 0),
        "subdir/image3.webp": List.filled(50, 0),
      });

      await service.clearImageCache();

      expect(tempDir.existsSync(), isTrue);
      final remaining = tempDir.listSync(recursive: true);
      expect(remaining, isEmpty);
    });

    test("calls ImageCacheManager.clearAll", () async {
      final service = createService();
      await seedFiles({"img.jpg": [1, 2, 3]});

      await service.clearImageCache();

      expect(imageCacheManagerCleared, isTrue);
    });

    test("does not throw when directory does not exist", () async {
      await tempDir.delete(recursive: true);
      final service = createService();

      // Should still call clearImageCacheManager without throwing
      await service.clearImageCache();

      expect(imageCacheManagerCleared, isTrue);
    });
  });

  group("clearMetadataCache", () {
    test("clears persistent metadata entries", () async {
      final service = createService();
      await fakePersistence.set("https://a.com", {"title": "A"});
      await fakePersistence.set("https://b.com", {"title": "B"});
      expect(await fakePersistence.count(), 2);

      await service.clearMetadataCache();

      expect(await fakePersistence.count(), 0);
    });
  });

  group("getImageCacheSize", () {
    test("returns total bytes of all files", () async {
      final service = createService();
      await seedFiles({
        "a.jpg": List.filled(100, 0),
        "b.png": List.filled(250, 0),
      });

      final size = await service.getImageCacheSize();

      expect(size, 350);
    });

    test("includes files in subdirectories", () async {
      final service = createService();
      await seedFiles({
        "top.jpg": List.filled(10, 0),
        "sub/deep.png": List.filled(20, 0),
      });

      final size = await service.getImageCacheSize();

      expect(size, 30);
    });

    test("returns 0 for empty directory", () async {
      final service = createService();

      final size = await service.getImageCacheSize();

      expect(size, 0);
    });

    test("returns 0 when directory does not exist", () async {
      await tempDir.delete(recursive: true);
      final service = createService();

      final size = await service.getImageCacheSize();

      expect(size, 0);
    });
  });

  group("getMetadataCacheEntryCount", () {
    test("returns count from persistent storage", () async {
      final service = createService();
      await fakePersistence.set("https://x.com", {"title": "X"});
      await fakePersistence.set("https://y.com", {"title": "Y"});
      await fakePersistence.set("https://z.com", {"title": "Z"});

      final count = await service.getMetadataCacheEntryCount();

      expect(count, 3);
    });

    test("returns 0 when empty", () async {
      final service = createService();

      final count = await service.getMetadataCacheEntryCount();

      expect(count, 0);
    });
  });
}
