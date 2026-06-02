import "dart:io";

import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as p;
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";

/// Routes path_provider to a temp dir so the real CacheManager /
/// JsonCacheInfoRepository can open headlessly. The cache-info index lands
/// under [support]; the image files land under whatever customPath the test
/// supplies — which is exactly the divergence under test.
class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider({required this.temp, required this.support});

  final String temp;
  final String support;

  @override
  Future<String?> getTemporaryPath() async => temp;
  @override
  Future<String?> getApplicationSupportPath() async => support;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp("image_cache_test");
    PathProviderPlatform.instance = _FakePathProvider(
      temp: tempRoot.path,
      support: tempRoot.path,
    );
    ImageCacheManager.resetForTesting();
  });

  tearDown(() async {
    ImageCacheManager.resetForTesting();
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  group("ImageCacheManager customPath wiring", () {
    test(
        "files written by the cache manager land under the reported "
        "cache directory", () async {
      final customPath = p.join(tempRoot.path, "my_cache");
      await ImageCacheManager.initialize(customPath: customPath);

      final reportedDir = await ImageCacheManager.getCacheDirectory();
      expect(reportedDir, customPath,
          reason: "getCacheDirectory must echo the supplied customPath");

      // Write through the cache manager's own file system — the exact path
      // WebHelper/putFile use to persist downloaded bytes.
      final manager = await ImageCacheManager.instance;
      final file = await manager.config.fileSystem.createFile("probe.file");
      await file.writeAsBytes(List<int>.filled(1234, 7));

      // The physical file must live UNDER the reported directory, otherwise
      // size/dir reporting describes a folder that does not hold the data.
      expect(p.isWithin(reportedDir, file.path), isTrue,
          reason: "stored file ${file.path} must be inside reported "
              "dir $reportedDir");
      expect(await File(file.path).exists(), isTrue);
    });

    test(
        "getCacheSize reflects bytes actually stored via the cache "
        "manager", () async {
      final customPath = p.join(tempRoot.path, "sized_cache");
      await ImageCacheManager.initialize(customPath: customPath);

      expect(await ImageCacheManager.getCacheSize(), 0,
          reason: "fresh custom cache dir starts empty");

      final manager = await ImageCacheManager.instance;
      final file =
          await manager.config.fileSystem.createFile("payload.file");
      await file.writeAsBytes(List<int>.filled(2048, 1));

      // Reporting scans _currentCachePath; storage uses config.fileSystem.
      // With the fix they agree, so the byte count shows up. With the bug
      // (files land in temp/cacheKey, reporting scans customPath) this is 0.
      expect(await ImageCacheManager.getCacheSize(), 2048,
          reason: "size reporting must see the file the cache manager "
              "actually wrote");
    });

    test("default cacheKey path keeps storage and reporting consistent",
        () async {
      // No customPath: resolves to <temp>/<defaultCacheKey>. The fix must
      // also keep the default branch self-consistent.
      await ImageCacheManager.initialize();
      final manager = await ImageCacheManager.instance;
      final reportedDir = await ImageCacheManager.getCacheDirectory();
      expect(reportedDir, p.join(tempRoot.path, ImageCacheManager.defaultCacheKey));

      final file = await manager.config.fileSystem.createFile("d.file");
      await file.writeAsBytes(const [1, 2, 3]);
      expect(p.isWithin(reportedDir, file.path), isTrue);
      expect(await ImageCacheManager.getCacheSize(), 3);
    });
  });
}
