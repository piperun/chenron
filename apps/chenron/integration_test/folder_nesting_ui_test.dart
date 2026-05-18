import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/features/folder_viewer/services/folder_viewer_service.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get_it/get_it.dart";
import "package:integration_test/integration_test.dart";
import "package:signals/signals.dart";

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
      throw UnimplementedError("Test mock — buildDatabase not used.");
}

/// Nested folder + link flow: drives the [FolderViewerService] through a
/// realistic 3-deep folder hierarchy and confirms the [FolderViewerPage]
/// builds without crashing when the data layer returns the structure
/// the UI expects.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late MockDatabaseHelper mockDb;
  late FolderViewerService service;
  late String parentId;
  late String childId;
  late String grandchildId;

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup(setupOnInit: true);

    if (GetIt.I.isRegistered<Signal<AppDatabaseLifecycle>>()) {
      await GetIt.I.reset();
    }
    GetIt.I.registerSingleton<Signal<AppDatabaseLifecycle>>(
      signal(_MockAppDatabaseLifecycle(mockDb.database)),
    );

    service = FolderViewerService();

    // Build a 3-deep hierarchy:
    //   Parent
    //     ├─ Child folder
    //     │    └─ Grandchild folder
    //     │         └─ 1 link
    //     ├─ link A
    //     └─ link B
    final parent = await mockDb.database.createFolder(
      folderInfo: FolderDraft(title: "Parent Folder", description: "root"),
      tags: [Metadata(value: "root", type: MetadataTypeEnum.tag)],
    );
    parentId = parent.folderId;

    final child = await mockDb.database.createFolder(
      folderInfo: FolderDraft(title: "Child Folder", description: "level 1"),
    );
    childId = child.folderId;

    final grandchild = await mockDb.database.createFolder(
      folderInfo: FolderDraft(
        title: "Grandchild Folder",
        description: "level 2",
      ),
    );
    grandchildId = grandchild.folderId;

    final linkA = await mockDb.database.createLink(
      link: "https://example.org/link-a",
    );
    final linkB = await mockDb.database.createLink(
      link: "https://example.org/link-b",
    );
    final deepLink = await mockDb.database.createLink(
      link: "https://example.org/deep-link",
    );

    // Attach children to their parents.
    await mockDb.database.updateFolder(
      parentId,
      itemUpdates: CUD(
        update: [
          FolderItem.folder(
            id: null,
            itemId: childId,
            folderId: childId,
            title: "Child Folder",
          ),
          FolderItem.link(
            id: null,
            itemId: linkA.linkId,
            url: "https://example.org/link-a",
          ),
          FolderItem.link(
            id: null,
            itemId: linkB.linkId,
            url: "https://example.org/link-b",
          ),
        ],
      ),
    );
    await mockDb.database.updateFolder(
      childId,
      itemUpdates: CUD(
        update: [
          FolderItem.folder(
            id: null,
            itemId: grandchildId,
            folderId: grandchildId,
            title: "Grandchild Folder",
          ),
        ],
      ),
    );
    await mockDb.database.updateFolder(
      grandchildId,
      itemUpdates: CUD(
        update: [
          FolderItem.link(
            id: null,
            itemId: deepLink.linkId,
            url: "https://example.org/deep-link",
          ),
        ],
      ),
    );
  });

  tearDown(() async {
    await mockDb.dispose();
    if (GetIt.I.isRegistered<Signal<AppDatabaseLifecycle>>()) {
      await GetIt.I.reset();
    }
  });

  group("Folder + nested links — data flow", () {
    test("parent folder reports correct item count (links + nested folder)",
        () async {
      final count = await service.getFolderItemCount(parentId);
      expect(count, equals(3));
    });

    test("child folder reports a single nested folder item", () async {
      final count = await service.getFolderItemCount(childId);
      expect(count, equals(1));
    });

    test("grandchild folder reports a single link item", () async {
      final count = await service.getFolderItemCount(grandchildId);
      expect(count, equals(1));
    });

    test("loadFolderMetadata returns the folder's tags", () async {
      final result = await service.loadFolderMetadata(parentId);
      expect(result.data.title, equals("Parent Folder"));
      expect(result.tags.map((t) => t.name), contains("root"));
    });

    test("pagination yields all 3 items for parent", () async {
      final items =
          await service.getFolderItemsPaginated(parentId, 50, 0);
      expect(items.length, equals(3));
      // Mix of one folder + two links
      final folderItems = items.whereType<FolderItemNested>().toList();
      final linkItems = items.whereType<LinkItem>().toList();
      expect(folderItems.length, equals(1));
      expect(linkItems.length, equals(2));
      expect(folderItems.first.title, equals("Child Folder"));
    });

    test("child folder loadFolderWithParents includes the parent as an item",
        () async {
      final result = await service.loadFolderWithParents(childId);
      expect(result.data.id, equals(childId));
      // The parent appears as a FolderItem.folder so the UI can render
      // the breadcrumb back-link.
      final nestedParents = result.items.whereType<FolderItemNested>();
      final parentItem =
          nestedParents.where((item) => item.folderId == parentId).firstOrNull;
      expect(parentItem, isNotNull);
      expect(parentItem!.title, equals("Parent Folder"));
    });
  });

  group("Folder + nested links — widget render", () {
    testWidgets("FolderViewerPage builds without throwing for nested data",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: FolderViewerPage(folderId: parentId)),
      );
      // The page mounts with the initial loading state; that alone proves
      // the widget tree + the locator wiring + the service composition all
      // line up. Going further (driving the toggle popup, tapping a link)
      // pulls in `SettingsCoordinator` which has its own dep chain — not
      // worth recreating here.
      expect(find.byType(FolderViewerPage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
