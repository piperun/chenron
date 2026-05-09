import "package:cache_manager/cache_manager.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/features/settings/models/settings_category.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/settings/ui/data/data_settings.dart";
import "package:chenron/locator.dart";

import "data_settings_test.mocks.dart";

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

  @override
  Future<List<Map<String, dynamic>>> getExpiredEntries() async => [];
}

class FakeDataSettingsService extends Fake implements DataSettingsService {
  String? customPath;

  @override
  Future<String?> getCustomDatabasePath() async => customPath;

  @override
  Future<String> getDefaultDatabasePath() async => "/tmp/default";

  @override
  Future<void> setCustomDatabasePath(String? path) async {
    customPath = path;
  }
}

@GenerateMocks([ConfigController])
void main() {
  group("SettingsCategory.data", () {
    test("is a top-level category", () {
      expect(SettingsCategory.data.isTopLevel, true);
    });

    test("has no parent", () {
      expect(SettingsCategory.data.parent, isNull);
    });

    test("has no children", () {
      expect(SettingsCategory.data.children, isEmpty);
    });

    test("is a leaf", () {
      expect(SettingsCategory.data.isLeaf, true);
    });

    test("has correct label", () {
      expect(SettingsCategory.data.label, "Data");
    });

    test("appears in topLevel list", () {
      expect(SettingsCategory.topLevel, contains(SettingsCategory.data));
    });
  });

  group("DataSettings widget — Metadata Cache section", () {
    late MockConfigController mockController;
    late FakeMetadataPersistence fakePersistence;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Register service that DataSettings reads from the locator.
      if (locator.isRegistered<DataSettingsService>()) {
        await locator.unregister<DataSettingsService>();
      }
      locator.registerSingleton<DataSettingsService>(FakeDataSettingsService());

      fakePersistence = FakeMetadataPersistence();
      MetadataCache.init(fakePersistence);

      mockController = MockConfigController();
      when(mockController.appDatabasePath).thenReturn(signal<String?>(null));
      when(mockController.savedAppDatabasePath).thenReturn(null);
    });

    tearDown(() async {
      await MetadataCache.clearAll();
      if (locator.isRegistered<DataSettingsService>()) {
        await locator.unregister<DataSettingsService>();
      }
    });

    Widget buildPage() {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DataSettings(controller: mockController),
          ),
        ),
      );
    }

    testWidgets("renders Metadata Cache section with current entry count",
        (tester) async {
      await fakePersistence.set("https://a.com", {"title": "A"});
      await fakePersistence.set("https://b.com", {"title": "B"});

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text("Metadata Cache"), findsAtLeastNWidgets(1));
      expect(find.text("2 entries"), findsOneWidget);
    });

    testWidgets("singular grammar for one entry", (tester) async {
      await fakePersistence.set("https://only.com", {"title": "Only"});

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text("1 entry"), findsOneWidget);
    });

    testWidgets("Clear Metadata opens confirmation dialog", (tester) async {
      await fakePersistence.set("https://a.com", {"title": "A"});

      await tester.pumpWidget(buildPage());
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
      await fakePersistence.set("https://a.com", {"title": "A"});
      await fakePersistence.set("https://b.com", {"title": "B"});

      await tester.pumpWidget(buildPage());
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
      await fakePersistence.set("https://a.com", {"title": "A"});

      await tester.pumpWidget(buildPage());
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
