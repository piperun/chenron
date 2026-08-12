import "dart:io";

import "package:cache_manager/cache_manager.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/cache_service.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/settings/ui/storage/cache_settings_panel.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
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
  Future<List<Metadata>> getExpiredEntries() async => [];
}

@GenerateMocks([ConfigService, DataSettingsService, ThemeNotifier])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockConfigService mockConfigService;
  late MockDataSettingsService mockDataService;
  late MockThemeNotifier mockThemeApplier;
  late FakeCacheService fakeCacheService;
  late FakeMetadataPersistence fakePersistence;
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
      optionsStore: ThemeOptionsStore(),
    ));

    fakePersistence = FakeMetadataPersistence();
    locator.registerSingleton<MetadataCache>(
      MetadataCache(persistence: fakePersistence),
    );
    locator.registerSingleton<FailureTracker>(FailureTracker());

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

  Metadata buildMetadata(String url, {String? title}) {
    return Metadata(
      url: url,
      title: title,
      fetchedAt: DateTime.now(),
    );
  }

  Widget buildWidget({FakeCacheService? service}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CacheSettingsPanel(cacheService: service ?? fakeCacheService),
        ),
      ),
    );
  }

  group("image cache", () {
    testWidgets("renders image cache size", (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text("Image Cache"), findsOneWidget);
      expect(find.text("500.0 KB"), findsOneWidget);
    });

    testWidgets("Clear Images button shows confirmation dialog",
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text("Clear Images"));
      await tester.pumpAndSettle();

      expect(find.text("Clear Image Cache"), findsOneWidget);
      expect(
          find.text("Remove downloaded images? "
              "They will be re-downloaded on next view."),
          findsOneWidget);
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
  });

  group("metadata cache", () {
    testWidgets("renders Metadata Cache section with current entry count",
        (tester) async {
      await fakePersistence.set(buildMetadata("https://a.com", title: "A"));
      await fakePersistence.set(buildMetadata("https://b.com", title: "B"));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text("Metadata Cache"), findsAtLeastNWidgets(1));
      expect(find.text("2 entries"), findsOneWidget);
    });

    testWidgets("singular grammar for one entry", (tester) async {
      await fakePersistence
          .set(buildMetadata("https://only.com", title: "Only"));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text("1 entry"), findsOneWidget);
    });

    testWidgets("Clear Metadata opens confirmation dialog", (tester) async {
      await fakePersistence.set(buildMetadata("https://a.com", title: "A"));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text("Clear Metadata"));
      await tester.pumpAndSettle();

      expect(find.text("Clear Metadata Cache"), findsOneWidget);
      expect(
        find.text("Clear cached page info? "
            "Titles and descriptions will be refetched."),
        findsOneWidget,
      );
    });

    testWidgets("confirming clear empties MetadataCache and refreshes count",
        (tester) async {
      await fakePersistence.set(buildMetadata("https://a.com", title: "A"));
      await fakePersistence.set(buildMetadata("https://b.com", title: "B"));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text("2 entries"), findsOneWidget);

      await tester.tap(find.text("Clear Metadata"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Clear"));
      await tester.pumpAndSettle();

      expect(await fakePersistence.count(), 0);
      expect(find.text("0 entries"), findsOneWidget);
    });

    testWidgets("cancelling the dialog leaves MetadataCache untouched",
        (tester) async {
      await fakePersistence.set(buildMetadata("https://a.com", title: "A"));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text("Clear Metadata"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      expect(await fakePersistence.count(), 1);
      expect(find.text("1 entry"), findsOneWidget);
    });
  });
}
