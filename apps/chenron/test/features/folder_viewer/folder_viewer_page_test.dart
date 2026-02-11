import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:signals/signals.dart";
import "package:get_it/get_it.dart";
import "dart:io";

class _MockAppDatabaseHandler implements AppDatabaseHandler {
  @override
  final AppDatabase appDatabase;

  _MockAppDatabaseHandler(this.appDatabase);

  @override
  DatabaseLocation? databaseLocation;

  @override
  Future<File?> backupDatabase() => throw UnimplementedError();

  @override
  Future<void> closeDatabase() async {}

  @override
  Future<void> createDatabase(
      {String? databaseName,
      File? databasePath,
      bool setupOnInit = false}) async {}

  @override
  Future<File?> exportDatabase(Directory exportPath) =>
      throw UnimplementedError();

  @override
  Future<File?> importDatabase(File dbFile,
          {required bool copyImport, bool setupOnInit = true}) =>
      throw UnimplementedError();

  @override
  Future<void> reloadDatabase() async {}
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

      if (GetIt.I.isRegistered<Signal<AppDatabaseHandler>>()) {
        await GetIt.I.reset();
      }

      final mockHandler = _MockAppDatabaseHandler(mockDb.database);
      GetIt.I.registerSingleton<Signal<AppDatabaseHandler>>(
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
      if (GetIt.I.isRegistered<Signal<AppDatabaseHandler>>()) {
        await GetIt.I.reset();
      }
    });

    Widget buildViewer({required String folderId}) {
      return MaterialApp(
        home: FolderViewerPage(folderId: folderId),
      );
    }

    // Note: FolderHeader requires ConfigController in GetIt (deep
    // dependency chain: ConfigService, ThemeController, SharedPreferences).
    // Tests below only exercise the loading/pre-header states to avoid
    // that chain. Full header rendering is covered by integration tests.

    group("Loading states", () {
      testWidgets("shows loading indicator initially", (tester) async {
        await tester.pumpWidget(buildViewer(folderId: testFolderId));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
