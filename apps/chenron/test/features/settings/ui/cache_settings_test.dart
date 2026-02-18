import "dart:io";

import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/service/cache_service.dart";
import "package:chenron/features/settings/ui/cache/cache_settings.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";
import "package:signals/signals_flutter.dart";

import "cache_settings_test.mocks.dart";

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String temp;
  final String support;

  _FakePathProvider({required this.temp, required this.support});

  @override
  Future<String?> getTemporaryPath() async => temp;

  @override
  Future<String?> getApplicationSupportPath() async => support;
}

/// Tracks calls to clearImageCache and clearMetadataCache.
class FakeCacheService extends CacheService {
  int clearImageCalls = 0;
  int clearMetadataCalls = 0;
  int imageCacheSize;
  int metadataEntryCount;

  FakeCacheService({
    this.imageCacheSize = 1024,
    this.metadataEntryCount = 5,
  }) : super(
          resolveCachePath: () async => "",
          clearImageCacheManager: () async {},
        );

  @override
  Future<void> clearImageCache() async {
    clearImageCalls++;
    imageCacheSize = 0;
  }

  @override
  Future<void> clearMetadataCache() async {
    clearMetadataCalls++;
    metadataEntryCount = 0;
  }

  @override
  Future<int> getImageCacheSize() async => imageCacheSize;

  @override
  Future<int> getMetadataCacheEntryCount() async => metadataEntryCount;
}

@GenerateMocks([ConfigController])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockConfigController mockController;
  late FakeCacheService fakeCacheService;
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync("cache_settings_test_");
    PathProviderPlatform.instance = _FakePathProvider(
      temp: tempDir.path,
      support: tempDir.path,
    );

    mockController = MockConfigController();
    when(mockController.cacheDirectory).thenReturn(signal<String?>(null));

    fakeCacheService = FakeCacheService(
      imageCacheSize: 1024 * 500, // 500 KB
      metadataEntryCount: 42,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget buildWidget({FakeCacheService? service}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CacheSettings(
            controller: mockController,
            cacheService: service ?? fakeCacheService,
          ),
        ),
      ),
    );
  }

  testWidgets("renders image cache size and metadata entry count",
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text("Image Cache"), findsOneWidget);
    expect(find.text("Metadata Cache"), findsOneWidget);
    expect(find.text("500.0 KB"), findsOneWidget);
    expect(find.text("42 entries"), findsOneWidget);
  });

  testWidgets("Clear Images button shows confirmation dialog", (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Clear Images"));
    await tester.pumpAndSettle();

    expect(find.text("Clear Image Cache"), findsOneWidget);
    expect(find.text("Remove downloaded images? "
        "They will be re-downloaded on next view."), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
  });

  testWidgets("Clear Metadata button shows confirmation dialog",
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Clear Metadata"));
    await tester.pumpAndSettle();

    expect(find.text("Clear Metadata Cache"), findsOneWidget);
    expect(find.text("Clear cached page info? "
        "Titles and descriptions will be refetched."), findsOneWidget);
  });

  testWidgets("confirming image clear calls service and refreshes display",
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Open dialog
    await tester.tap(find.text("Clear Images"));
    await tester.pumpAndSettle();

    // Confirm
    await tester.tap(find.text("Clear"));
    await tester.pumpAndSettle();

    expect(fakeCacheService.clearImageCalls, 1);
    expect(find.text("0 B"), findsOneWidget);
  });

  testWidgets("confirming metadata clear calls service and refreshes display",
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Open dialog
    await tester.tap(find.text("Clear Metadata"));
    await tester.pumpAndSettle();

    // Confirm
    await tester.tap(find.text("Clear"));
    await tester.pumpAndSettle();

    expect(fakeCacheService.clearMetadataCalls, 1);
    expect(find.text("0 entries"), findsOneWidget);
  });

  testWidgets("cancelling dialog does not clear cache", (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Open image clear dialog
    await tester.tap(find.text("Clear Images"));
    await tester.pumpAndSettle();

    // Cancel
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();

    expect(fakeCacheService.clearImageCalls, 0);
    expect(find.text("500.0 KB"), findsOneWidget);
  });

  testWidgets("singular entry count uses correct grammar", (tester) async {
    final singleEntryService = FakeCacheService(
      imageCacheSize: 0,
      metadataEntryCount: 1,
    );

    await tester.pumpWidget(buildWidget(service: singleEntryService));
    await tester.pumpAndSettle();

    expect(find.text("1 entry"), findsOneWidget);
  });
}
