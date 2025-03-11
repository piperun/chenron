import "dart:convert";

import "package:chenron/models/created_ids.dart";
import "package:chenron/models/item.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/utils/test_lib/folder_factory.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
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

      final folderResult = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId!)))
          .get();
      expect(folderResult.length, 1);
      expect(folderResult.first.title, "Empty Folder");

      final tagResult = await (database.select(database.metadataRecords)
            ..where(
              (tbl) => tbl.itemId.equals(folderResult.first.id),
            ))
          .get();
      expect(tagResult.length, 0);

      final linkResult = await (database.select(database.items)
            ..where(
              (tbl) => tbl.folderId.equals(folderResult.first.id),
            ))
          .get();
      expect(linkResult.length, 0);

      final docResult = await (database.select(database.items)
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

      final result = await database.createFolder(
          folderInfo: folderData.folder, tags: folderData.tags);

      final folderResult = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId!)))
          .get();
      expect(folderResult.length, 1);
      expect(folderResult.first.title, "Tagged Folder");

      final metadataResults = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.folderId!)))
          .get();

      expect(metadataResults.length, 3);
      // Check if all metadataIds from the result are in the database
      for (final metadataId in result.typedTags!) {
        expect(metadataResults.any((tag) => tag.id == metadataId.metadataId),
            isTrue);
      }

      // Check if all tagIds from the result are in the database
      final tagIds = metadataResults.map((tag) => tag.metadataId).toList();
      for (final tagId in result.typedTags!) {
        expect(tagIds.contains(tagId.tagId), isTrue);
      }

      final itemResult = await (database.select(database.items)
            ..where((tbl) => tbl.folderId.equals(result.folderId!)))
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

      final folderResult = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(result.folderId!)))
          .getSingleOrNull();

      expect(folderResult?.title, folderData.folder.title);
      expect(folderResult?.description, folderData.folder.description);

      final tagResult = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.folderId!)))
          .get();
      expect(tagResult.length, 2);

      for (final item in folderData.items) {
        switch (item) {
          case StringContent content:
            final linkResult = await (database.select(database.links)
                  ..where(
                    (tbl) => tbl.content.equals(content.value),
                  ))
                .get();
            expect(linkResult.first.id, item.itemId);
            expect(linkResult.length, 1);
            break;
          case MapContent content:
            final documentResult = await (database.select(database.documents)
                  ..where(
                    (tbl) =>
                        tbl.content.equals(utf8.encode(content.value["body"]!)),
                  ))
                .get();
            expect(documentResult.first.id, item.itemId);
            expect(documentResult.length, 1);
            break;
        }
      }

      final itemResults = await (database.select(database.items)
            ..where((tbl) => tbl.folderId.equals(result.folderId!)))
          .get();
      expect(itemResults.length, 2);
      _verifyItemIds(itemResults, result.typedItems!);
    });
  });
}

void _verifyListContains(List<String> fetchedIds, List<String> expectedIds) {
  for (final id in expectedIds) {
    expect(fetchedIds.contains(id), isTrue,
        reason:
            'Expected ID: $id not found in fetched IDs: ${fetchedIds.join(", ")}');
  }
}

void _verifyItemIds(
    List<Item> fetchResults, List<CreatedIds<Item>> returnResults) {
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
