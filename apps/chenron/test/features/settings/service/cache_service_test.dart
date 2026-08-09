// Transitional Task 6 adapter behavior is exercised throughout this file.
// ignore_for_file: deprecated_member_use

import "dart:async";
import "dart:io";

import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get_it/get_it.dart";

import "package:chenron/features/settings/service/cache_service.dart";

/// In-memory typed persistence for [MetadataCache] tests.
class FakeMetadataPersistence implements MetadataPersistence {
  final Map<String, Metadata> _store = {};

  @override
  Future<Metadata?> get(String url) async => _store[url];

  @override
  Future<void> set(Metadata metadata) async {
    _store[metadata.url] = metadata;
  }

  @override
  Future<void> remove(String url) async => _store.remove(url);

  @override
  Future<void> clearAll() async => _store.clear();

  @override
  Future<int> count() async => _store.length;

  @override
  Future<List<Metadata>> getExpiredEntries() async {
    final now = DateTime.now();
    return _store.values
        .where((m) => now.difference(m.fetchedAt).inDays >= m.ttlDays)
        .toList();
  }
}

/// Models Drift's serialized executor while allowing the first retry write to
/// stay active long enough to queue a transactional clear behind it.
class OrderedMetadataPersistence
    implements MetadataPersistence, MetadataRefreshPersistence {
  final Map<String, Metadata> metadata = {};
  final Map<String, MetadataRefreshRecord> refreshRecords = {};
  final Completer<void> firstRefreshWriteStarted = Completer<void>();
  final Completer<void> releaseFirstRefreshWrite = Completer<void>();
  Future<void> _tail = Future<void>.value();
  int _refreshWrites = 0;

  Future<void> _serialize(Future<void> Function() operation) {
    final next = _tail.then((_) => operation());
    _tail = next;
    return next;
  }

  @override
  Future<void> clearAll() => _serialize(() async {
        metadata.clear();
        refreshRecords.clear();
      });

  @override
  Future<void> clearAllRefreshRecords() =>
      _serialize(() async => refreshRecords.clear());

  @override
  Future<int> count() async => metadata.length;

  @override
  Future<Metadata?> get(String url) async => metadata[url];

  @override
  Future<List<Metadata>> getExpiredEntries() async => const [];

  @override
  Future<MetadataRefreshRecord?> getRefreshRecord(String url) async =>
      refreshRecords[url];

  @override
  Future<void> remove(String url) =>
      _serialize(() async => metadata.remove(url));

  @override
  Future<void> removeRefreshRecord(String url) =>
      _serialize(() async => refreshRecords.remove(url));

  @override
  Future<void> set(Metadata value) =>
      _serialize(() async => metadata[value.url] = value);

  @override
  Future<void> setRefreshRecord(MetadataRefreshRecord record) {
    final writeNumber = ++_refreshWrites;
    return _serialize(() async {
      if (writeNumber == 1) {
        firstRefreshWriteStarted.complete();
        await releaseFirstRefreshWrite.future;
      }
      refreshRecords[record.url] = record;
    });
  }
}

void main() {
  late Directory tempDir;
  late FakeMetadataPersistence fakePersistence;
  bool imageCacheManagerCleared = false;

  Metadata buildMetadata(String url, {String? title}) {
    return Metadata(
      url: url,
      title: title,
      fetchedAt: DateTime.now(),
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp("cache_service_test_");
    fakePersistence = FakeMetadataPersistence();
    if (GetIt.I.isRegistered<MetadataCache>()) {
      await GetIt.I<MetadataCache>().clearAll();
      GetIt.I.unregister<MetadataCache>();
    }
    if (GetIt.I.isRegistered<FailureTracker>()) {
      GetIt.I<FailureTracker>().clearAll();
      GetIt.I.unregister<FailureTracker>();
    }
    GetIt.I.registerSingleton<MetadataCache>(
      MetadataCache(persistence: fakePersistence),
    );
    GetIt.I.registerSingleton<FailureTracker>(FailureTracker());
    imageCacheManagerCleared = false;
  });

  tearDown(() async {
    if (GetIt.I.isRegistered<MetadataCache>()) {
      final cache = GetIt.I<MetadataCache>();
      await cache.clearAll();
      GetIt.I.unregister<MetadataCache>();
    }
    if (GetIt.I.isRegistered<FailureTracker>()) {
      GetIt.I<FailureTracker>().clearAll();
      GetIt.I.unregister<FailureTracker>();
    }
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
      await fakePersistence.set(buildMetadata("https://a.com", title: "A"));
      await fakePersistence.set(buildMetadata("https://b.com", title: "B"));
      expect(await fakePersistence.count(), 2);

      await service.clearMetadataCache();

      expect(await fakePersistence.count(), 0);
    });

    test("also wipes the failure tracker", () async {
      final service = createService();
      final tracker = GetIt.I<FailureTracker>();
      tracker.recordFailure("https://err.com");
      tracker.recordFailure("https://err.com");
      expect(tracker.failureCount("https://err.com"), 2);

      await service.clearMetadataCache();

      expect(tracker.failureCount("https://err.com"), 0);
    });

    test("invalidates queued retry writes before the atomic clear", () async {
      const url = "https://err.com/queued";
      final persistence = OrderedMetadataPersistence();
      GetIt.I.unregister<MetadataCache>();
      GetIt.I.unregister<FailureTracker>();
      GetIt.I.registerSingleton<MetadataCache>(
        MetadataCache(persistence: persistence),
      );
      GetIt.I.registerSingleton<FailureTracker>(
        FailureTracker(persistence: persistence),
      );
      final tracker = GetIt.I<FailureTracker>();
      final first = tracker.recordFailure(url);
      final second = tracker.recordFailure(url);
      await persistence.firstRefreshWriteStarted.future;

      final clear = createService().clearMetadataCache();
      persistence.releaseFirstRefreshWrite.complete();
      await Future.wait([first, second, clear]);

      expect(persistence.refreshRecords[url], isNull);
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
      await fakePersistence.set(buildMetadata("https://x.com", title: "X"));
      await fakePersistence.set(buildMetadata("https://y.com", title: "Y"));
      await fakePersistence.set(buildMetadata("https://z.com", title: "Z"));

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
