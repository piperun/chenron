import "package:chenron/models/created_ids.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/database/extensions/folder/remove.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/database/database.dart";

import "package:chenron/test_support/path_provider_fake.dart";
import "package:chenron/test_support/logger_setup.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  group("removeFolder tests", () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase(
          databaseName: "test_db", setupOnInit: true, debugMode: true);

      final folders = database.folders;
      await database.delete(folders).go();
      final items = database.items;
      await database.delete(items).go();
      final metadataRecords = database.metadataRecords;
      await database.delete(metadataRecords).go();
    });

    tearDown(() async {
      await database.close();
    });

    test("Remove folder without tags", () async {
      // Create a test folder
      final folderInfo = FolderDraft(
        title: "Test Folder",
        description: "Test Description",
      );
      final FolderResultIds createdIds =
          await database.createFolder(folderInfo: folderInfo);

      expect(createdIds.folderId, isNotNull);

      // Remove the folder
      await database.removeFolder(createdIds.folderId);

      // Check if the folder is removed
      final result = await database.folders
          .findById(createdIds.folderId)
          .getSingleOrNull();
      expect(result, isNull);
    });

    test("Remove folder with tags", () async {
      // Create a test folder with tags
      final folderInfo = FolderDraft(
        title: "Test Folder with Tags",
        description: "Test Description",
      );
      final tags = [
        Metadata(value: "tag1", type: MetadataTypeEnum.tag),
        Metadata(value: "tag2", type: MetadataTypeEnum.tag),
      ];
      final FolderResultIds createdIds =
          await database.createFolder(folderInfo: folderInfo, tags: tags);

      expect(createdIds.folderId, isNotNull);

      // Remove the folder
      await database.removeFolder(createdIds.folderId);

      // Check if the folder is removed
      final folderResult = await database.folders
          .findById(createdIds.folderId)
          .getSingleOrNull();
      expect(folderResult, isNull);

      // Check if folder tags are removed
      final metadataRecords = database.metadataRecords;
      final tagResult = await (database.select(metadataRecords)
            ..where((tbl) => tbl.itemId.equals(createdIds.folderId)))
          .get();
      expect(tagResult, isEmpty);
    });

    test("Remove folder with items", () async {
      // Create a test folder with items
      final folderInfo = FolderDraft(
        title: "Test Folder with Items",
        description: "Test Description",
      );
      final link = FolderItem(
          type: FolderItemType.link,
          content: const StringContent(value: "https://example.com"));
      final document = FolderItem(
          type: FolderItemType.document,
          content: const MapContent(
              value: {"title": "Test Document", "body": "Test Content"}));

      final FolderResultIds createdIds = await database
          .createFolder(folderInfo: folderInfo, items: [link, document]);

      expect(createdIds.folderId, isNotNull);

      // Remove the folder
      await database.removeFolder(createdIds.folderId);

      // Check if the folder is removed
      final folderResult = await database.folders
          .findById(createdIds.folderId)
          .getSingleOrNull();
      expect(folderResult, isNull);

      // Check if folder links are removed
      final items = database.items;
      final linkResult = await (database.select(items)
            ..where((tbl) => tbl.folderId.equals(createdIds.folderId)))
          .get();
      expect(linkResult, isEmpty);

      // Check if folder documents are removed
      final items2 = database.items;
      final documentResult = await (database.select(items2)
            ..where((tbl) => tbl.folderId.equals(createdIds.folderId)))
          .get();
      expect(documentResult, isEmpty);
    });

    test("Remove non-existent folder", () async {
      // Try to remove a folder that doesn't exist
      final result = await database.removeFolder("non_existent_id");

      // The function should return false since no folder was removed
      expect(result, isFalse);
    });
  });
}
