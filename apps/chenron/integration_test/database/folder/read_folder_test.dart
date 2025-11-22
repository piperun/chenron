// ignore_for_file: avoid_print

import "package:chenron/models/created_ids.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/models/item.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/utils/test_lib/folder_factory.dart";

import "package:chenron/test_support/path_provider_fake.dart";
import "package:chenron/test_support/logger_setup.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });
  late AppDatabase database;
  late FolderTestData activeFolder;
  late FolderTestData inactiveFolder;
  late FolderResultIds activeFolderResultIds;
  late FolderResultIds unusedFolderResultIds;

  setUp(() async {
    database = AppDatabase(databaseName: "test_db", debugMode: true);

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

    activeFolderResultIds = await database.createFolder(
      folderInfo: activeFolder.folder,
      tags: activeFolder.tags,
      items: activeFolder.items,
    );

    unusedFolderResultIds = await database.createFolder(
      folderInfo: inactiveFolder.folder,
      tags: inactiveFolder.tags,
      items: inactiveFolder.items,
    );
  });
  tearDown(() async {
    final folders = database.folders;
    await database.delete(folders).go();
    final items = database.items;
    await database.delete(items).go();
    final metadataRecords = database.metadataRecords;
    await database.delete(metadataRecords).go();
    final tags = database.tags;
    await database.delete(tags).go();
    final links = database.links;
    await database.delete(links).go();
    final documents = database.documents;
    await database.delete(documents).go();
    await database.close();
  });

  group("getFolder() Operations", () {
    test("returns null when folder is not found", () async {
      final result = await database.getFolder(folderId: "non_existent_id");

      expect(result, isNull);
    });
    test("should get a single folder with no tags or items", () async {
      final retrievedFolder =
          await database.getFolder(folderId: activeFolderResultIds.folderId);

      expect(retrievedFolder, isNotNull);
      expect(retrievedFolder!.data.id, equals(activeFolderResultIds.folderId));
      expect(retrievedFolder.data.title, equals("Active Folder"));
      expect(
          retrievedFolder.data.description, equals("This is an active folder"));
    });

    test("should get folder with only tags", () async {
      final folderWithTags = await database.getFolder(
          folderId: activeFolderResultIds.folderId,
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));

      expect(folderWithTags, isNotNull);
      expect(folderWithTags!.tags, isNotNull);
      expect(folderWithTags.tags.length, equals(2));

      expect(folderWithTags.tags.map((tag) => tag.name).toSet(),
          equals({"tag1", "tag2"}));
    });
    test("should get folder with only items", () async {
      final folderWithItems = await database.getFolder(
          folderId: activeFolderResultIds.folderId,
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.items}));

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
      final folderWithAll = await database.getFolder(
        folderId: activeFolderResultIds.folderId,
        includeOptions: const IncludeOptions<AppDataInclude>(
            {AppDataInclude.items, AppDataInclude.tags}),
      );
      print(folderWithAll!.data.title);
      for (var element in folderWithAll.items) {
        print("item's id: ${element.id}");
        print("itemid: ${element.itemId}");
        print("type: ${element.type}");
      }

      expect(folderWithAll, isNotNull);
      expect(folderWithAll.items, isNotNull);
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
      final allFolders = await database.getAllFolders();

      expect(allFolders, isNotEmpty);
      for (var folder in allFolders) {
        expect(folder.data.id, isNotNull);
        expect(folder.data.title, isNotNull);
        expect(folder.data.description, isNotNull);
        expect(folder.data.createdAt, isNotNull);
        expect(folder.items, isEmpty);
        expect(folder.tags, isEmpty);
      }
    });
    test("should get all folders with only tags", () async {
      final allFolders = await database.getAllFolders(
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));

      expect(allFolders.length, equals(2));

      final testFolders = [activeFolder, inactiveFolder];
      final testFoldersResults = [activeFolderResultIds, unusedFolderResultIds];

      for (int i = 0; i < allFolders.length; i++) {
        final retrievedFolder = allFolders[i];
        final expectedFolder = testFolders[i];
        final folderResults = testFoldersResults[i];

        expect(retrievedFolder.data.id, equals(folderResults.folderId));
        expect(retrievedFolder.data.title, equals(expectedFolder.folder.title));
        expect(retrievedFolder.data.description,
            equals(expectedFolder.folder.description));
        expect(retrievedFolder.data.createdAt, isNotNull);
        expect(retrievedFolder.items, isEmpty);
        expect(retrievedFolder.tags, isNotEmpty);

        expect(retrievedFolder.tags.map((tag) => tag.name).toSet(),
            equals(Set.from(expectedFolder.tags.map((tag) => tag.value))));
      }
    });
    test("should get all folders with only items", () async {
      final allFolders = await database.getAllFolders(
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.items}));

      expect(allFolders.length, equals(2));

      final testFolders = [activeFolder, inactiveFolder];
      final testFoldersResults = [activeFolderResultIds, unusedFolderResultIds];

      for (int i = 0; i < allFolders.length; i++) {
        final retrievedFolder = allFolders[i];
        final expectedFolder = testFolders[i];
        final folderResults = testFoldersResults[i];

        expect(retrievedFolder.data.id, equals(folderResults.folderId));
        expect(retrievedFolder.data.title, equals(expectedFolder.folder.title));
        expect(retrievedFolder.data.description,
            equals(expectedFolder.folder.description));
        expect(retrievedFolder.data.createdAt, isNotNull);
        expect(retrievedFolder.items, isNotEmpty);
        expect(retrievedFolder.tags, isEmpty);

        expect(
            retrievedFolder.items.length, equals(expectedFolder.items.length));
      }
    });
    test("should get all folders with both items and tags", () async {
      final allFolders = await database.getAllFolders(
          includeOptions: const IncludeOptions<AppDataInclude>(
              {AppDataInclude.items, AppDataInclude.tags}));

      expect(allFolders.length, equals(2));

      final testFolders = [activeFolder, inactiveFolder];
      final testFoldersResults = [activeFolderResultIds, unusedFolderResultIds];

      for (int i = 0; i < allFolders.length; i++) {
        final retrievedFolder = allFolders[i];
        final expectedFolder = testFolders[i];
        final folderResults = testFoldersResults[i];

        expect(retrievedFolder.data.id, equals(folderResults.folderId));
        expect(retrievedFolder.data.title, equals(expectedFolder.folder.title));
        expect(retrievedFolder.data.description,
            equals(expectedFolder.folder.description));
        expect(retrievedFolder.data.createdAt, isNotNull);
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
      final stream =
          database.watchFolder(folderId: activeFolderResultIds.folderId);

      expect(
          stream,
          emitsThrough(predicate<FolderResult>((result) =>
              result.data.id == activeFolderResultIds.folderId &&
              result.data.title == "Active Folder" &&
              result.data.description == "This is an active folder" &&
              result.tags.isEmpty &&
              result.items.isEmpty)));
    });

    test("should watch folder with only tags", () async {
      final stream = database.watchFolder(
          folderId: activeFolderResultIds.folderId,
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));

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
          folderId: activeFolderResultIds.folderId,
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.items}));

      await expectLater(
        stream,
        emitsThrough(predicate<FolderResult>((result) {
          return result.items.length == 2 &&
              result.items.any((item) => item.type == FolderItemType.link) &&
              result.items
                  .any((item) => item.type == FolderItemType.document) &&
              result.tags.isEmpty;
        })),
      );
    });

    test("should watch folder with both items and tags", () async {
      final stream = database.watchFolder(
          folderId: activeFolderResultIds.folderId,
          includeOptions: const IncludeOptions<AppDataInclude>(
              {AppDataInclude.items, AppDataInclude.tags}));

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
    test("should watch all folders with no items or tags", () async {
      final stream = database.watchAllFolders();

      expect(
          stream,
          emitsThrough(predicate<List<FolderResult>>((folders) =>
              folders.length == 2 &&
              folders.every(
                  (folder) => folder.items.isEmpty && folder.tags.isEmpty))));
    });

    test("should watch all folders with only tags", () async {
      final stream = database.watchAllFolders(
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));

      expect(
          stream,
          emitsThrough(predicate<List<FolderResult>>((folders) =>
              folders.length == 2 &&
              folders[0].tags.length == 2 &&
              folders[1].tags.length == 2 &&
              folders.every((folder) => folder.items.isEmpty))));
    });

    test("should watch all folders with only items", () async {
      final stream = database.watchAllFolders(
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.items}));

      expect(
        stream,
        emitsThrough(predicate<List<FolderResult>>((folders) =>
            folders.length == 2 &&
            folders[0].items.length == 2 &&
            folders[1].items.length == 2 &&
            folders.every((folder) => folder.tags.isEmpty))),
      );
      stream.listen((folders) {
        print("Folders emitted: ${folders.length}");
        for (var folder in folders) {
          print("Folder ID: ${folder.data.id}");
          print("Tags: ${folder.tags.length}");
          print("Items: ${folder.items.length}");
        }
      });
    });

    test("should watch all folders with both items and tags", () async {
      final stream = database.watchAllFolders(
          includeOptions: const IncludeOptions<AppDataInclude>(
              {AppDataInclude.items, AppDataInclude.tags}));

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

  group("searchFolders() Operations", () {
    test("should find multiple folders matching query", () async {
      final results = await database.searchFolders(query: "Folder");

      expect(results.length, equals(2));
      expect(results.map((r) => r.data.title).toList(),
          containsAll(["Active Folder", "Inactive Folder"]));
    });

    test("should return empty list for no matches", () async {
      final results = await database.searchFolders(query: "NonExistent");

      expect(results, isEmpty);
    });

    test("should respect IncludeOptions modes", () async {
      final resultsWithItems = await database.searchFolders(
          query: "Active",
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.items}));
      expect(resultsWithItems[0].items, isNotEmpty);
      expect(resultsWithItems[0].tags, isEmpty);

      final resultsWithTags = await database.searchFolders(
          query: "Active",
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));
      expect(resultsWithTags[0].items, isEmpty);
      expect(resultsWithTags[0].tags, isNotEmpty);
    });
  });
}
