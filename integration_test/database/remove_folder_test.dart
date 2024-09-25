import 'package:chenron/data_struct/folder.dart';
import 'package:chenron/data_struct/item.dart';
import 'package:chenron/data_struct/metadata.dart';
import 'package:chenron/database/extensions/folder/create.dart';
import 'package:chenron/database/extensions/folder/remove.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chenron/database/database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('removeFolder tests', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase(databaseName: "test_db");

      await database.delete(database.folders).go();
      await database.delete(database.items).go();
      await database.delete(database.metadataRecords).go();
    });

    tearDown(() async {
      await database.close();
    });

    test('Remove folder without tags', () async {
      // Create a test folder
      final folderInfo = FolderInfo(
        title: 'Test Folder',
        description: 'Test Description',
      );
      await database.createFolder(folderInfo: folderInfo);

      // Remove the folder
      await database.removeFolder(folderInfo.id);

      // Check if the folder is removed
      final result =
          await database.folders.findById(folderInfo.id).getSingleOrNull();
      expect(result, isNull);
    });

    test('Remove folder with tags', () async {
      // Create a test folder with tags
      final folderInfo = FolderInfo(
        title: 'Test Folder with Tags',
        description: 'Test Description',
      );
      final tags = [
        Metadata(value: 'tag1', type: MetadataTypeEnum.tag),
        Metadata(value: 'tag2', type: MetadataTypeEnum.tag),
      ];
      await database.createFolder(folderInfo: folderInfo, tags: tags);

      // Remove the folder
      await database.removeFolder(folderInfo.id);

      // Check if the folder is removed
      final folderResult =
          await database.folders.findById(folderInfo.id).getSingleOrNull();
      expect(folderResult, isNull);

      // Check if folder tags are removed
      final tagResult = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(folderInfo.id)))
          .get();
      expect(tagResult, isEmpty);
    });

    test('Remove folder with items', () async {
      // Create a test folder with items
      final folderInfo = FolderInfo(
        title: 'Test Folder with Items',
        description: 'Test Description',
      );
      final link = FolderItem(
          type: FolderItemType.link,
          content: StringContent('https://example.com'));
      final document = FolderItem(
          type: FolderItemType.document,
          content:
              MapContent({'title': 'Test Document', "body": 'Test Content'}));
      await database
          .createFolder(folderInfo: folderInfo, items: [link, document]);

      // Remove the folder
      await database.removeFolder(folderInfo.id);

      // Check if the folder is removed
      final folderResult =
          await database.folders.findById(folderInfo.id).getSingleOrNull();
      expect(folderResult, isNull);

      // Check if folder links are removed
      final linkResult = await (database.select(database.items)
            ..where((tbl) => tbl.folderId.equals(folderInfo.id)))
          .get();
      expect(linkResult, isEmpty);

      // Check if folder documents are removed
      final documentResult = await (database.select(database.items)
            ..where((tbl) => tbl.folderId.equals(folderInfo.id)))
          .get();
      expect(documentResult, isEmpty);
    });

    test('Remove non-existent folder', () async {
      // Try to remove a folder that doesn't exist
      final result = await database.removeFolder('non_existent_id');

      // The function should return false since no folder was removed
      expect(result, isFalse);
    });
  });
}
