import "package:chenron/models/created_ids.dart";
import "package:chenron/models/item.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/utils/test_lib/folder_factory.dart";

import "package:chenron/test_support/path_provider_fake.dart";
import "package:chenron/test_support/logger_setup.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });
  late AppDatabase database;
  setUp(() {
    database = AppDatabase(
        databaseName: "test_db", setupOnInit: true, debugMode: true);
  });
  tearDown(() async {
    await database.close();
  });

  group("createFolder", () {
    test("create folder without tags and items", () async {
      final folderData = FolderTestDataFactory.create(
        title: "Empty Folder",
        description: "No tags or items",
        tagValues: [],
        itemsData: [],
      );
      final result = await database.createFolder(folderInfo: folderData.folder);

      final folders = database.folders;
      final folderResult = await (database.select(folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .get();
      expect(folderResult.length, 1);
      expect(folderResult.first.title, "Empty Folder");

      final metadataRecords = database.metadataRecords;
      final tagResult = await (database.select(metadataRecords)
            ..where(
              (tbl) => tbl.itemId.equals(folderResult.first.id),
            ))
          .get();
      expect(tagResult.length, 0);

      final items = database.items;
      final linkResult = await (database.select(items)
            ..where(
              (tbl) => tbl.folderId.equals(folderResult.first.id),
            ))
          .get();
      expect(linkResult.length, 0);

      final docResult = await (database.select(items)
            ..where(
              (tbl) => tbl.folderId.equals(folderResult.first.id),
            ))
          .get();
      expect(docResult.length, 0);
    });

    test("create folder with tags only", () async {
      final folderData = FolderTestDataFactory.create(
        title: "Tagged Folder",
        description: "Folder with tags only",
        tagValues: ["tag1", "tag2", "tag3"],
        itemsData: [],
      );

      final createdFolderResult = await database.createFolder(
          folderInfo: folderData.folder, tags: folderData.tags);

      final folders = database.folders;
      final folderResult = await (database.select(folders)
            ..where((tbl) => tbl.id.equals(createdFolderResult.folderId)))
          .get();
      expect(folderResult.length, 1);
      expect(folderResult.first.title, "Tagged Folder");

      final metadataRecords = database.metadataRecords;
      final metadataResults = await (database.select(metadataRecords)
            ..where((tbl) => tbl.itemId.equals(createdFolderResult.folderId)))
          .get();

      expect(metadataResults.length, 3);
      // Check if all metadataIds from the result are in the database
      for (final metadataId in createdFolderResult.tagIds!) {
        expect(
            metadataResults
                .any((metadata) => metadata.metadataId == metadataId.tagId),
            isTrue);
      }

      // Check if all tagIds from the result are in the database
      final tagIds = metadataResults.map((tag) => tag.metadataId).toList();
      for (final tagId in createdFolderResult.tagIds!) {
        expect(tagIds.contains(tagId.tagId), isTrue);
      }

      final items = database.items;
      final itemResult = await (database.select(items)
            ..where((tbl) => tbl.folderId.equals(createdFolderResult.folderId)))
          .get();
      expect(itemResult.length, 0);
    });

    test("create folder with tags and items", () async {
      final folderData = FolderTestDataFactory.create(
        title: "Item folder",
        description: "Testing if we can create folder with tags and items",
        tagValues: ["tag1", "tag2"],
        itemsData: [
          {"type": "link", "content": "https://example.com"},
          {
            "type": "document",
            "content": {"title": "Test document", "body": "Blablabla"}
          },
        ],
      );

      final result = await database.createFolder(
          folderInfo: folderData.folder,
          tags: folderData.tags,
          items: folderData.items);

      final folders = database.folders;
      final folderResult = await (database.select(folders)
            ..where((tbl) => tbl.id.equals(result.folderId)))
          .getSingleOrNull();

      expect(folderResult?.title, folderData.folder.title);
      expect(folderResult?.description, folderData.folder.description);

      final metadataRecords = database.metadataRecords;
      final tagResult = await (database.select(metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.folderId)))
          .get();
      expect(tagResult.length, 2);

      for (final item in folderData.items) {
        switch (item) {
          case final StringContent content:
            final links = database.links;
            final linkResult = await (database.select(links)
                  ..where(
                    (tbl) => tbl.path.equals(content.value),
                  ))
                .get();
            expect(linkResult.first.id, item.itemId);
            expect(linkResult.length, 1);
            break;
          case final MapContent content:
            final documents = database.documents;
            final documentResult = await (database.select(documents)
                  ..where(
                    (tbl) => tbl.path.equals(content.value["body"]!),
                  ))
                .get();
            expect(documentResult.first.id, item.itemId);
            expect(documentResult.length, 1);
            break;
        }
      }

      final items = database.items;
      final itemResults = await (database.select(items)
            ..where((tbl) => tbl.folderId.equals(result.folderId)))
          .get();
      expect(itemResults.length, 2);
      _verifyItemIds(itemResults, result.itemIds ?? []);
    });
  });
}

void _verifyItemIds(
    List<Item> fetchResults, List<ItemResultIds> returnResults) {
  final fetchedIds = {
    "linkIds": fetchResults
        .where((item) => item.typeId == FolderItemType.link.index)
        .map((item) => item.itemId)
        .toSet(),
    "documentIds": fetchResults
        .where((item) => item.typeId == FolderItemType.document.index)
        .map((item) => item.itemId)
        .toSet(),
    "itemIds": fetchResults.map((item) => item.id).toSet(),
  };

  final expectedIds = {
    "linkIds": returnResults
        .map((result) => result.linkId)
        .whereType<String>()
        .toSet(),
    "documentIds": returnResults
        .map((result) => result.documentId)
        .whereType<String>()
        .toSet(),
    "itemIds": returnResults
        .map((result) => result.itemId)
        .whereType<String>()
        .toSet(),
  };

  for (final idType in ["linkIds", "documentIds", "itemIds"]) {
    expect(fetchedIds[idType], equals(expectedIds[idType]),
        reason: "Mismatch in $idType.\n"
            'Expected: ${expectedIds[idType]!.join(", ")}\n'
            'Actual: ${fetchedIds[idType]!.join(", ")}');
  }
}
