import "package:chenron/models/folder_results.dart";
import "package:chenron/models/item.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/utils/test_lib/folder_factory.dart";

void main() {
  late AppDatabase database;
  late FolderTestData activeFolder;
  late FolderTestData inactiveFolder;
  late FolderResults activeFolderResult;
  late FolderResults inactiveFolderResult;

  setUp(() async {
    database = AppDatabase(databaseName: "test_db");

    activeFolder = FolderTestDataFactory.create(
      title: "Active Folder",
      description: "This is an active folder",
      tagValues: ["tag1", "tag2"],
      itemsData: [
        {"type": "link", "content": "https://example.com"},
        {
          "type": "document",
          "content": {"title": "Doc Title", "body": "Doc Body"}
        },
      ],
    );

    inactiveFolder = FolderTestDataFactory.create(
      title: "Inactive Folder",
      description: "This is an inactive folder",
      tagValues: ["tag3", "tag4"],
      itemsData: [
        {"type": "link", "content": "https://inactive.com"},
        {
          "type": "document",
          "content": {"title": "Inactive Doc", "body": "Inactive Body"}
        },
      ],
    );

    activeFolderResult = await database.createFolder(
      folderInfo: activeFolder.folder,
      tags: activeFolder.tags,
      items: activeFolder.items,
    );

    inactiveFolderResult = await database.createFolder(
      folderInfo: inactiveFolder.folder,
      tags: inactiveFolder.tags,
      items: inactiveFolder.items,
    );
  });
  tearDown(() async {
    await database.delete(database.folders).go();
    await database.delete(database.items).go();
    await database.delete(database.metadataRecords).go();
    await database.delete(database.tags).go();
    await database.delete(database.links).go();
    await database.delete(database.documents).go();
    await database.close();
  });

  group("getFolder() Operations", () {
    test("returns null when folder is not found", () async {
      final result = await database.getFolder("non_existent_id");

      expect(result, isNull);
    });
    test("should get a single folder with no tags or items", () async {
      final retrievedFolder = await database.getFolder(
          activeFolderResult.folderId!,
          mode: IncludeFolderData.none);

      expect(retrievedFolder, isNotNull);
      expect(retrievedFolder!.folder.id, equals(activeFolderResult.folderId));
      expect(retrievedFolder.folder.title, equals("Active Folder"));
      expect(retrievedFolder.folder.description,
          equals("This is an active folder"));
    });

    test("should get folder with only tags", () async {
      final folderWithTags = await database.getFolder(
          activeFolderResult.folderId!,
          mode: IncludeFolderData.tags);

      expect(folderWithTags, isNotNull);
      expect(folderWithTags!.tags, isNotNull);
      expect(folderWithTags.tags.length, equals(2));

      expect(folderWithTags.tags.map((tag) => tag.name).toSet(),
          equals({"tag1", "tag2"}));
    });
    test("should get folder with only items", () async {
      final folderWithItems = await database.getFolder(
          activeFolderResult.folderId!,
          mode: IncludeFolderData.items);

      expect(folderWithItems, isNotNull);
      expect(folderWithItems!.items, isNotNull);
      expect(folderWithItems.items.length, equals(2));

      expect(
          folderWithItems.items.any((item) => item.type == FolderItemType.link),
          isTrue);
      expect(
          folderWithItems.items
              .any((item) => item.type == FolderItemType.document),
          isTrue);
    });
    test("should get folder with both items and tags", () async {
      final folderWithAll = await database
          .getFolder(activeFolderResult.folderId!, mode: IncludeFolderData.all);

      expect(folderWithAll, isNotNull);
      expect(folderWithAll!.items, isNotNull);
      expect(folderWithAll.items.length, equals(2));
      expect(folderWithAll.tags, isNotNull);
      expect(folderWithAll.tags.length, equals(2));

      expect(folderWithAll.tags.map((tag) => tag.name).toSet(),
          equals({"tag1", "tag2"}));

      expect(
          folderWithAll.items.any((item) => item.type == FolderItemType.link),
          isTrue);
      expect(
          folderWithAll.items
              .any((item) => item.type == FolderItemType.document),
          isTrue);
    });
  });
  group("getAllFolders() Operations", () {
    test("should get all folders with no items or tags", () async {
      final allFolders =
          await database.getAllFolders(mode: IncludeFolderData.none);

      expect(allFolders, isNotEmpty);
      for (var folder in allFolders) {
        expect(folder.folder.id, isNotNull);
        expect(folder.folder.title, isNotNull);
        expect(folder.folder.description, isNotNull);
        expect(folder.folder.createdAt, isNotNull);
        expect(folder.items, isEmpty);
        expect(folder.tags, isEmpty);
      }
    });
    test("should get all folders with only tags", () async {
      final allFolders =
          await database.getAllFolders(mode: IncludeFolderData.tags);

      expect(allFolders.length, equals(2));

      final testFolders = [activeFolder, inactiveFolder];
      final testFoldersResults = [activeFolderResult, inactiveFolderResult];

      for (int i = 0; i < allFolders.length; i++) {
        final retrievedFolder = allFolders[i];
        final expectedFolder = testFolders[i];
        final folderResults = testFoldersResults[i];

        expect(retrievedFolder.folder.id, equals(folderResults.folderId));
        expect(
            retrievedFolder.folder.title, equals(expectedFolder.folder.title));
        expect(retrievedFolder.folder.description,
            equals(expectedFolder.folder.description));
        expect(retrievedFolder.folder.createdAt, isNotNull);
        expect(retrievedFolder.items, isEmpty);
        expect(retrievedFolder.tags, isNotEmpty);

        expect(retrievedFolder.tags.map((tag) => tag.name).toSet(),
            equals(Set.from(expectedFolder.tags.map((tag) => tag.value))));
      }
    });
    test("should get all folders with only items", () async {
      final allFolders =
          await database.getAllFolders(mode: IncludeFolderData.items);

      expect(allFolders.length, equals(2));

      final testFolders = [activeFolder, inactiveFolder];
      final testFoldersResults = [activeFolderResult, inactiveFolderResult];

      for (int i = 0; i < allFolders.length; i++) {
        final retrievedFolder = allFolders[i];
        final expectedFolder = testFolders[i];
        final folderResults = testFoldersResults[i];

        expect(retrievedFolder.folder.id, equals(folderResults.folderId));
        expect(
            retrievedFolder.folder.title, equals(expectedFolder.folder.title));
        expect(retrievedFolder.folder.description,
            equals(expectedFolder.folder.description));
        expect(retrievedFolder.folder.createdAt, isNotNull);
        expect(retrievedFolder.items, isNotEmpty);
        expect(retrievedFolder.tags, isEmpty);

        expect(
            retrievedFolder.items.length, equals(expectedFolder.items.length));
      }
    });
    test("should get all folders with both items and tags", () async {
      final allFolders =
          await database.getAllFolders(mode: IncludeFolderData.all);

      expect(allFolders.length, equals(2));

      final testFolders = [activeFolder, inactiveFolder];
      final testFoldersResults = [activeFolderResult, inactiveFolderResult];

      for (int i = 0; i < allFolders.length; i++) {
        final retrievedFolder = allFolders[i];
        final expectedFolder = testFolders[i];
        final folderResults = testFoldersResults[i];

        expect(retrievedFolder.folder.id, equals(folderResults.folderId));
        expect(
            retrievedFolder.folder.title, equals(expectedFolder.folder.title));
        expect(retrievedFolder.folder.description,
            equals(expectedFolder.folder.description));
        expect(retrievedFolder.folder.createdAt, isNotNull);
        expect(retrievedFolder.items, isNotEmpty);
        expect(retrievedFolder.tags, isNotEmpty);

        expect(retrievedFolder.tags.map((tag) => tag.name).toSet(),
            equals(Set.from(expectedFolder.tags.map((tag) => tag.value))));

        expect(
            retrievedFolder.items.length, equals(expectedFolder.items.length));
      }
    });
  });
  group("watchFolder() Operations", () {
    test("emits null when folder is not found", () async {
      final stream = database.watchFolder(folderId: "non_existent_id");
      expect(stream, emits(null));
    });
    test("should watch a single folder with no tags or items", () async {
      final stream = database.watchFolder(
          folderId: activeFolderResult.folderId!, mode: IncludeFolderData.none);

      expect(
          stream,
          emitsThrough(predicate<FolderResult>((result) =>
              result.folder.id == activeFolderResult.folderId &&
              result.folder.title == "Active Folder" &&
              result.folder.description == "This is an active folder" &&
              result.tags.isEmpty &&
              result.items.isEmpty)));
    });

    test("should watch folder with only tags", () async {
      final stream = database.watchFolder(
          folderId: activeFolderResult.folderId!, mode: IncludeFolderData.tags);

      expect(
          stream,
          emitsThrough(predicate<FolderResult>((result) =>
              result.tags.length == 2 &&
              result.tags
                  .map((tag) => tag.name)
                  .toSet()
                  .containsAll(["tag1", "tag2"]) &&
              result.items.isEmpty)));
    });

    test("should watch folder with only items", () async {
      final stream = database.watchFolder(
          folderId: activeFolderResult.folderId!,
          mode: IncludeFolderData.items);

      expect(
          stream,
          emitsThrough(predicate<FolderResult>((result) =>
              result.items.length == 2 &&
              result.items.any((item) => item.type == FolderItemType.link) &&
              result.items
                  .any((item) => item.type == FolderItemType.document) &&
              result.tags.isEmpty)));
    });

    test("should watch folder with both items and tags", () async {
      final stream = database.watchFolder(
          folderId: activeFolderResult.folderId!, mode: IncludeFolderData.all);

      expect(
          stream,
          emitsThrough(predicate<FolderResult>((result) =>
              result.tags.length == 2 &&
              result.tags
                  .map((tag) => tag.name)
                  .toSet()
                  .containsAll(["tag1", "tag2"]) &&
              result.items.length == 2 &&
              result.items.any((item) => item.type == FolderItemType.link) &&
              result.items
                  .any((item) => item.type == FolderItemType.document))));
    });
  });
  group("watchAllFolders() Operations", () {
    // Implement new tests using the factory-created folders
    test("should watch all folders with no items or tags", () async {
      final stream = database.watchAllFolders(mode: IncludeFolderData.none);

      expect(
          stream,
          emitsThrough(predicate<List<FolderResult>>((folders) =>
              folders.length == 2 &&
              folders.every(
                  (folder) => folder.items.isEmpty && folder.tags.isEmpty))));
    });

    test("should watch all folders with only tags", () async {
      final stream = database.watchAllFolders(mode: IncludeFolderData.tags);

      expect(
          stream,
          emitsThrough(predicate<List<FolderResult>>((folders) =>
              folders.length == 2 &&
              folders[0].tags.length == 2 &&
              folders[1].tags.length == 2 &&
              folders.every((folder) => folder.items.isEmpty))));
    });

    test("should watch all folders with only items", () async {
      final stream = database.watchAllFolders(mode: IncludeFolderData.items);

      expect(
          stream,
          emitsThrough(predicate<List<FolderResult>>((folders) =>
              folders.length == 2 &&
              folders[0].items.length == 2 &&
              folders[1].items.length == 2 &&
              folders.every((folder) => folder.tags.isEmpty))));
    });

    test("should watch all folders with both items and tags", () async {
      final stream = database.watchAllFolders(mode: IncludeFolderData.all);

      expect(
          stream,
          emitsThrough(predicate<List<FolderResult>>((folders) =>
              folders.length == 2 &&
              folders[0].tags.length == 2 &&
              folders[1].tags.length == 2 &&
              folders[0].items.length == 2 &&
              folders[1].items.length == 2)));
    });
  });
}
