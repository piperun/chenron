import "dart:io";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/cache_service.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/settings/ui/cache/cache_settings.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/locator.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";

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

/// Tracks calls to clearImageCache.
class FakeCacheService extends CacheService {
  int clearImageCalls = 0;
  int imageCacheSize;

  FakeCacheService({this.imageCacheSize = 1024})
      : super(
          resolveCachePath: () async => "",
          clearImageCacheManager: () async {},
        );

  @override
  Future<void> clearImageCache() async {
    clearImageCalls++;
    imageCacheSize = 0;
  }

  @override
  Future<int> getImageCacheSize() async => imageCacheSize;
}

@GenerateMocks([ConfigService, DataSettingsService, ThemeNotifier])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockConfigService mockConfigService;
  late MockDataSettingsService mockDataService;
  late MockThemeNotifier mockThemeApplier;
  late FakeCacheService fakeCacheService;
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync("cache_settings_test_");
    PathProviderPlatform.instance = _FakePathProvider(
      temp: tempDir.path,
      support: tempDir.path,
    );

    if (locator.isRegistered<SettingsCoordinator>()) {
      await locator.reset();
    }

    mockConfigService = MockConfigService();
    mockDataService = MockDataSettingsService();
    mockThemeApplier = MockThemeNotifier();

    locator.registerSingleton<SettingsCoordinator>(SettingsCoordinator(
      configService: mockConfigService,
      dataService: mockDataService,
      themeApplier: mockThemeApplier,
    ));

    fakeCacheService = FakeCacheService(imageCacheSize: 1024 * 500); // 500 KB
  });

  tearDown(() async {
    if (locator.isRegistered<SettingsCoordinator>()) {
      await locator.reset();
    }
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Widget buildWidget({FakeCacheService? service}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CacheSettings(cacheService: service ?? fakeCacheService),
        ),
      ),
    );
  }

  testWidgets("renders image cache size", (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text("Image Cache"), findsOneWidget);
    expect(find.text("500.0 KB"), findsOneWidget);
    expect(find.text("Metadata Cache"), findsNothing);
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

  testWidgets("confirming image clear calls service and refreshes display",
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Clear Images"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Clear"));
    await tester.pumpAndSettle();

    expect(fakeCacheService.clearImageCalls, 1);
    expect(find.text("0 B"), findsOneWidget);
  });

  testWidgets("cancelling dialog does not clear cache", (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text("Clear Images"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();

    expect(fakeCacheService.clearImageCalls, 0);
    expect(find.text("500.0 KB"), findsOneWidget);
  });
}
