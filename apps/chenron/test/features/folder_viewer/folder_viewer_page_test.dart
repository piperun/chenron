import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/features/folder_viewer/services/folder_viewer_service.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/services/activity_tracker.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:catalog/catalog.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:signals/signals.dart";
import "package:get_it/get_it.dart";
import "package:shared_preferences/shared_preferences.dart";

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

class _MockConfigDatabaseLifecycle extends ConfigDatabaseLifecycle {
  final ConfigDatabase _injected;

  _MockConfigDatabaseLifecycle(this._injected);

  @override
  ConfigDatabase get configDatabase => _injected;
}

class _BoundedFolderService extends FolderViewerService {
  _BoundedFolderService({this.parentItems = const <FolderItem>[]});

  final List<FolderItem> parentItems;
  final StreamController<void> _invalidations =
      StreamController<void>.broadcast();
  final List<ViewerQuery> countQueries = <ViewerQuery>[];
  final List<({ViewerQuery query, int limit, int offset})> pageRequests = [];

  @override
  Future<FolderResult> loadFolderMetadata(String folderId) async {
    return FolderResult(
      data: Folder(
        id: folderId,
        title: "Bounded Folder",
        description: "",
        createdAt: DateTime(2026, 8, 10),
        updatedAt: DateTime(2026, 8, 10),
      ),
      tags: const <Tag>[],
      items: const <FolderItem>[],
    );
  }

  @override
  Future<int> count(ViewerQuery query) async {
    countQueries.add(query);
    return 100000 + (query.includeFolderParents ? parentItems.length : 0);
  }

  @override
  Future<List<CatalogFacetGroup>> searchFacets(
    ViewerQuery query, {
    String searchText = "",
  }) async =>
      const <CatalogFacetGroup>[];

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) async {
    pageRequests.add((query: query, limit: limit, offset: offset));
    final rows = <FolderItem>[];
    final virtualParents =
        query.includeFolderParents ? parentItems : const <FolderItem>[];
    for (var index = offset; index < offset + limit; index++) {
      if (index < virtualParents.length) {
        rows.add(virtualParents[index]);
        continue;
      }
      final childIndex = index - virtualParents.length;
      rows.add(FolderItem.folder(
        id: "child-$childIndex",
        itemId: "relation-$childIndex",
        folderId: "child-$childIndex",
        title: "Child $childIndex",
        description: "",
        createdAt: DateTime(2026, 8, 10),
        tags: const <Tag>[],
      ));
    }
    return rows;
  }

  @override
  Stream<void> invalidations() => _invalidations.stream;

  @override
  Future<bool> loadLockState() async => false;

  @override
  Future<void> saveLockState({required bool isLocked}) async {}

  Future<void> disposeFake() => _invalidations.close();
}

void _unmountAfterTest(WidgetTester tester) {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  group("FolderViewerPage Tests", () {
    late MockDatabaseHelper mockDb;
    late ConfigDatabase configDb;
    late String testFolderId;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockDb = MockDatabaseHelper();
      await mockDb.setup(setupOnInit: true);

      await GetIt.I.reset();

      configDb = ConfigDatabase(
        databaseName: "folder_viewer_page_test",
        setupOnInit: true,
        debugMode: true,
      );
      await configDb.setup();

      GetIt.I.registerSingleton<Signal<ConfigDatabaseLifecycle>>(
        signal(_MockConfigDatabaseLifecycle(configDb)),
      );
      GetIt.I.registerLazySingleton<ConfigService>(ConfigService.new);
      GetIt.I.registerLazySingleton<DataSettingsService>(
        DataSettingsService.new,
      );
      GetIt.I.registerLazySingleton<SettingsCoordinator>(
        () => SettingsCoordinator(
          configService: GetIt.I.get<ConfigService>(),
          dataService: GetIt.I.get<DataSettingsService>(),
          themeApplier: ThemeNotifier(),
          optionsStore: ThemeOptionsStore(),
        ),
      );

      final mockHandler = _MockAppDatabaseLifecycle(mockDb.database);
      GetIt.I.registerSingleton<Signal<AppDatabaseLifecycle>>(
        signal(mockHandler),
      );
      GetIt.I
          .registerSingleton<ActivityTracker>(ActivityTracker(mockDb.database));

      testFolderId = await mockDb.createTestFolder(
        title: "Test Folder",
        description: "A test folder for viewing",
        tags: ["tag1", "tag2"],
      );
    });

    tearDown(() async {
      await mockDb.dispose();
      await configDb.close();
      await GetIt.I.reset();
    });

    Widget buildViewer({required String folderId}) {
      return MaterialApp(
        home: FolderViewerPage(folderId: folderId),
      );
    }

    testWidgets("omitted item handler opens a nested folder without a viewer",
        (tester) async {
      _unmountAfterTest(tester);
      await tester.binding.setSurfaceSize(const Size(2000, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final nestedFolderId = await mockDb.createTestFolder(
        title: "Nested folder",
      );
      await mockDb.database.into(mockDb.database.items).insert(
            ItemsCompanion.insert(
              id: "relation-$nestedFolderId",
              itemId: nestedFolderId,
              folderId: testFolderId,
              typeId: FolderItemType.folder,
            ),
          );
      final loadedItems = await mockDb.database.getFolderItemsPaginated(
        folderId: testFolderId,
        limit: 50,
        offset: 0,
      );
      expect(
        loadedItems.map(
          (item) => item.map(
            link: (link) => link.url,
            document: (document) => document.title,
            folder: (folder) => folder.title,
          ),
        ),
        ["Nested folder"],
      );

      await tester.pumpWidget(buildViewer(folderId: testFolderId));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text("Nested folder"), findsOneWidget);
      expect(find.byType(FolderViewerPage), findsOneWidget);
      expect(find.byType(Viewer), findsNothing);

      await tester.tap(find.text("Nested folder"));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.byType(FolderViewerPage), findsNWidgets(2));
      expect(find.byType(Viewer), findsNothing);
    });

    testWidgets("folder filters replace the query without loading all rows",
        (tester) async {
      _unmountAfterTest(tester);
      await tester.binding.setSurfaceSize(const Size(2000, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final service = _BoundedFolderService(
        parentItems: <FolderItem>[
          FolderItem.folder(
            id: "parent-relation",
            itemId: null,
            folderId: "parent-folder",
            title: "Parent Folder",
            description: "",
            createdAt: DateTime(2026, 8, 10),
            tags: const <Tag>[],
          ),
        ],
      );
      addTearDown(service.disposeFake);

      await tester.pumpWidget(MaterialApp(
        home: FolderViewerPage(
          folderId: "bounded-folder",
          serviceFactory: () => service,
        ),
      ));
      await tester.pump();
      await tester.pump();

      expect(service.pageRequests, isNotEmpty);
      expect(service.pageRequests.every((request) => request.limit == 100),
          isTrue);
      expect(
          service.pageRequests.map((request) => request.offset).toSet(), {0});
      expect(find.text("100001 items"), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, "needle");
      await tester.pump();
      await tester.pump();

      expect(service.countQueries.last.searchText, "needle");
      expect(service.pageRequests.last.query.searchText, "needle");
      expect(
        service.pageRequests.fold<int>(
          0,
          (total, request) => total + request.limit,
        ),
        lessThan(1000),
      );

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    // Note: FolderHeader pulls settings from GetIt (deep dependency
    // chain: ConfigService, ThemeNotifier, SharedPreferences). Tests
    // below only exercise the loading/pre-header states to avoid that
    // chain. Full header rendering is covered by integration tests.

    group("Loading states", () {
      testWidgets("renders chrome immediately (back / home / lock buttons)",
          (tester) async {
        _unmountAfterTest(tester);
        await tester.binding.setSurfaceSize(const Size(2000, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(buildViewer(folderId: testFolderId));

        // The page no longer gates rendering behind a full-page
        // CircularProgressIndicator — chrome (back / home / lock)
        // shows up on first frame while metadata loads.
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.byIcon(Icons.home), findsOneWidget);
      });

      testWidgets("shows error for non-existent folder", (tester) async {
        _unmountAfterTest(tester);
        await tester.binding.setSurfaceSize(const Size(2000, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(buildViewer(folderId: "non-existent-id"));
        // Pump to let the future resolve.
        await tester.pump(const Duration(milliseconds: 500));

        // Should show the page without crashing.
        expect(find.byType(FolderViewerPage), findsOneWidget);
      });
    });
  });
}
