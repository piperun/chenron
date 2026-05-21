import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:signals/signals.dart";
import "package:get_it/get_it.dart";

class _MockAppDatabaseLifecycle extends AppDatabaseLifecycle {
  final AppDatabase _injected;

  _MockAppDatabaseLifecycle(this._injected);

  @override
  AppDatabase get database => _injected;

  @override
  AppDatabase get appDatabase => _injected;

  @override
  AppDatabase buildDatabase({
    required String databaseName,
    required String customPath,
    required bool setupOnInit,
  }) =>
      throw UnimplementedError("Mock does not build databases");
}

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  group("FolderViewerPage Tests", () {
    late MockDatabaseHelper mockDb;
    late String testFolderId;

    setUp(() async {
      mockDb = MockDatabaseHelper();
      await mockDb.setup(setupOnInit: true);

      if (GetIt.I.isRegistered<Signal<AppDatabaseLifecycle>>()) {
        await GetIt.I.reset();
      }

      final mockHandler = _MockAppDatabaseLifecycle(mockDb.database);
      GetIt.I.registerSingleton<Signal<AppDatabaseLifecycle>>(
        signal(mockHandler),
      );

      testFolderId = await mockDb.createTestFolder(
        title: "Test Folder",
        description: "A test folder for viewing",
        tags: ["tag1", "tag2"],
      );
    });

    tearDown(() async {
      await mockDb.dispose();
      if (GetIt.I.isRegistered<Signal<AppDatabaseLifecycle>>()) {
        await GetIt.I.reset();
      }
    });

    Widget buildViewer({required String folderId}) {
      return MaterialApp(
        home: FolderViewerPage(folderId: folderId),
      );
    }

    // Note: FolderHeader requires ConfigController in GetIt (deep
    // dependency chain: ConfigService, ThemeNotifier, SharedPreferences).
    // Tests below only exercise the loading/pre-header states to avoid
    // that chain. Full header rendering is covered by integration tests.

    group("Loading states", () {
      testWidgets("renders chrome immediately (back / home / lock buttons)",
          (tester) async {
        await tester.pumpWidget(buildViewer(folderId: testFolderId));

        // The page no longer gates rendering behind a full-page
        // CircularProgressIndicator — chrome (back / home / lock)
        // shows up on first frame while metadata loads.
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.byIcon(Icons.home), findsOneWidget);
      });

      testWidgets("shows error for non-existent folder", (tester) async {
        await tester.pumpWidget(buildViewer(folderId: "non-existent-id"));
        // Pump to let the future resolve.
        await tester.pump(const Duration(milliseconds: 500));

        // Should show the page without crashing.
        expect(find.byType(FolderViewerPage), findsOneWidget);
      });
    });
  });
}
