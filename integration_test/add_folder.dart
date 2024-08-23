import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder_ext.dart';
import 'package:chenron/database/types/data_types.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    await database.close();
  });

  group('addFolder', () {
    test('adds folder with tags and items', () async {
      final folderData = FolderDataType(
        title: 'Test Folder',
        description: 'Test Description',
      );
      final tags = ['tag1', 'tag2'];
      final items = [
        LinkDataType(url: 'https://example.com'),
        DocumentDataType(title: 'Test Doc', content: "test"),
      ];

      await database.addFolder(
          folderData: folderData, tags: tags, items: items);

      final folderResult = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(folderData.id)))
          .get();

      expect(folderResult.first.title, 'Test Folder');

      final tagResult = await database.select(database.tags).get();

      expect(tagResult.length, 2);

      final linkResult = await (database.select(database.folderLinks)
            ..where(
              (tbl) => tbl.folderId.equals(folderData.id),
            ))
          .get();

      expect(linkResult.first.folderId, folderData.id);
      expect(linkResult.length, 1);

      final docResult = await (database.select(database.folderDocuments)
            ..where((tbl) => tbl.documentId.equals(items[1].id)))
          .get();

      expect(docResult.first.documentId, items[1].id);
      expect(docResult.first.folderId, folderData.id);
    });

    test('adds folder without tags and items', () async {
      final folderData = FolderDataType(
        title: 'Empty Folder',
        description: 'No tags or items',
      );

      await database.addFolder(folderData: folderData);

      final folderResult = await (database.select(database.folders)
            ..where(
              (tbl) => tbl.id.equals(folderData.id),
            ))
          .get();
      expect(folderResult.length, 1);
      expect(folderResult.first.title, 'Empty Folder');

      final tagResult = await (database.select(database.folderTags)
            ..where(
              (tbl) => tbl.folderId.equals(folderResult.first.id),
            ))
          .get();
      expect(tagResult.length, 0);

      final linkResult = await (database.select(database.folderLinks)
            ..where(
              (tbl) => tbl.folderId.equals(folderResult.first.id),
            ))
          .get();
      expect(linkResult.length, 0);

      final docResult = await (database.select(database.folderDocuments)
            ..where(
              (tbl) => tbl.folderId.equals(folderResult.first.id),
            ))
          .get();
      expect(docResult.length, 0);
    });

    test('throws error for invalid item type', () async {
      final folderData = FolderDataType(
        title: 'Invalid Item Folder',
        description: 'Contains invalid item',
      );
      final invalidItem = TagDataType(name: 'Invalid Item');

      expect(
        () => database.addFolder(folderData: folderData, items: [invalidItem]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
