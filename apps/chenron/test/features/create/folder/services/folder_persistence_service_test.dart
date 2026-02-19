import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:chenron/features/create/folder/services/folder_persistence_service.dart";
import "package:chenron/components/forms/folder_form.dart";

void main() {
  late MockDatabaseHelper mockDb;
  late FolderPersistenceService service;

  setUpAll(installTestLogger);

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup();
    service = FolderPersistenceService.withDeps(appDatabase: mockDb.database);
  });

  tearDown(() async {
    await mockDb.dispose();
  });

  // -------------------------------------------------------------------------
  // saveFolder
  // -------------------------------------------------------------------------
  group("saveFolder()", () {
    test("creates a folder with title and description", () async {
      await service.saveFolder(const FolderFormData(
        title: "My Folder",
        description: "A test folder",
        parentFolderIds: [],
        tags: {},
        items: [],
      ));

      // Verify folder was created by checking database
      final allFolders = await mockDb.database.getAllFolders();
      final created = allFolders.where((f) => f.data.title == "My Folder");
      expect(created, isNotEmpty);
      expect(created.first.data.description, "A test folder");
    });

    test("creates a folder with tags", () async {
      await service.saveFolder(const FolderFormData(
        title: "Tagged Folder",
        description: "",
        parentFolderIds: [],
        tags: {"flutter", "dart"},
        items: [],
      ));

      final allFolders = await mockDb.database.getAllFolders();
      final created =
          allFolders.where((f) => f.data.title == "Tagged Folder");
      expect(created, isNotEmpty);
    });

    test("nests folder inside parent", () async {
      final parentId =
          await mockDb.createTestFolder(title: "Parent Folder");

      await service.saveFolder(FolderFormData(
        title: "Child Folder",
        description: "",
        parentFolderIds: [parentId],
        tags: const {},
        items: const [],
      ));

      final parent = await mockDb.getFolder(parentId);
      expect(parent, isNotNull);
      // Parent should have the child folder as an item
      expect(parent!.items.any((i) => i.type == FolderItemType.folder), isTrue);
    });

    test("nests folder in multiple parents", () async {
      final parentA =
          await mockDb.createTestFolder(title: "Parent Alpha");
      final parentB =
          await mockDb.createTestFolder(title: "Parent Bravo");

      await service.saveFolder(FolderFormData(
        title: "Shared Child",
        description: "",
        parentFolderIds: [parentA, parentB],
        tags: const {},
        items: const [],
      ));

      final a = await mockDb.getFolder(parentA);
      final b = await mockDb.getFolder(parentB);
      expect(
          a!.items.any((i) => i.type == FolderItemType.folder), isTrue);
      expect(
          b!.items.any((i) => i.type == FolderItemType.folder), isTrue);
    });

    test("creates folder with color", () async {
      await service.saveFolder(const FolderFormData(
        title: "Colored Folder",
        description: "",
        color: 0xFF42A5F5,
        parentFolderIds: [],
        tags: {},
        items: [],
      ));

      final allFolders = await mockDb.database.getAllFolders();
      final created =
          allFolders.where((f) => f.data.title == "Colored Folder");
      expect(created, isNotEmpty);
      expect(created.first.data.color, 0xFF42A5F5);
    });
  });

  // -------------------------------------------------------------------------
  // loadFoldersByIds
  // -------------------------------------------------------------------------
  group("loadFoldersByIds()", () {
    test("loads existing folders", () async {
      final id1 = await mockDb.createTestFolder(title: "Folder One");
      final id2 = await mockDb.createTestFolder(title: "Folder Two");

      final folders = await service.loadFoldersByIds([id1, id2]);
      expect(folders.length, 2);
      expect(folders.map((f) => f.title), containsAll(["Folder One", "Folder Two"]));
    });

    test("skips non-existent folder IDs", () async {
      final id1 = await mockDb.createTestFolder(title: "Existing");

      final folders = await service.loadFoldersByIds([id1, "nonexistent-id"]);
      expect(folders.length, 1);
      expect(folders.first.title, "Existing");
    });

    test("returns empty list for empty input", () async {
      final folders = await service.loadFoldersByIds([]);
      expect(folders, isEmpty);
    });

    test("returns empty list when no IDs match", () async {
      final folders =
          await service.loadFoldersByIds(["fake-1", "fake-2"]);
      expect(folders, isEmpty);
    });
  });
}
