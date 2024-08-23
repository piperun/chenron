import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder_ext.dart';
import 'package:chenron/database/types/data_types.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('removeFolder tests', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase();
      /*
      await database.delete(database.folders).go();
      await database.delete(database.folderTags).go();
      await database.delete(database.folderLinks).go();
      await database.delete(database.folderDocuments).go();
      await database.delete(database.folderTrees).go();
      */
    });

    tearDown(() async {
      await database.close();
    });

    test('Remove folder without tags', () async {
      // Create a test folder
      final folder = FolderDataType(
        title: 'Test Folder',
        description: 'Test Description',
      );
      await database.addFolder(folderData: folder);

      // Remove the folder
      await database.removeFolder(folder.id);

      // Check if the folder is removed
      final result =
          await database.folders.findById(folder.id).getSingleOrNull();
      expect(result, isNull);
    });

    test('Remove folder with tags', () async {
      // Create a test folder with tags
      final folder = FolderDataType(
        title: 'Test Folder with Tags',
        description: 'Test Description',
      );
      final tags = ['tag1', 'tag2'];
      await database.addFolder(folderData: folder, tags: tags);

      // Remove the folder
      await database.removeFolder(folder.id);

      // Check if the folder is removed
      final folderResult =
          await database.folders.findById(folder.id).getSingleOrNull();
      expect(folderResult, isNull);

      // Check if folder tags are removed
      final tagResult = await (database.select(database.folderTags)
            ..where((tbl) => tbl.folderId.equals(folder.id)))
          .get();
      expect(tagResult, isEmpty);
    });

    test('Remove folder with items', () async {
      // Create a test folder with items
      final folder = FolderDataType(
        title: 'Test Folder with Items',
        description: 'Test Description',
      );
      final link = LinkDataType(url: 'https://example.com');
      final document =
          DocumentDataType(title: 'Test Document', content: 'Test Content');
      await database.addFolder(folderData: folder, items: [link, document]);

      // Remove the folder
      await database.removeFolder(folder.id);

      // Check if the folder is removed
      final folderResult =
          await database.folders.findById(folder.id).getSingleOrNull();
      expect(folderResult, isNull);

      // Check if folder links are removed
      final linkResult = await (database.select(database.folderLinks)
            ..where((tbl) => tbl.folderId.equals(folder.id)))
          .get();
      expect(linkResult, isEmpty);

      // Check if folder documents are removed
      final documentResult = await (database.select(database.folderDocuments)
            ..where((tbl) => tbl.folderId.equals(folder.id)))
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
