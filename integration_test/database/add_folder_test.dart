import 'package:chenron/models/folder.dart';
import 'package:chenron/models/item.dart';
import 'package:chenron/models/metadata.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/create.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(setupOnInit: true, databaseName: "test_db");
  });
  tearDown(() async {
    await database.close();
  });

  group('createFolder', () {
    test('adds folder without tags and items', () async {
      final folderData = FolderInfo(
        title: 'Empty Folder',
        description: 'No tags or items',
      );
      await database.createFolder(folderInfo: folderData);
      final folderResult = await (database.select(database.folders)
            ..where(
              (tbl) => tbl.id.equals(folderData.id),
            ))
          .get();
      expect(folderResult.length, 1);
      expect(folderResult.first.title, 'Empty Folder');

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
    test('adds folder with tags only', () async {
      final folderInfo = FolderInfo(
        title: 'Tagged Folder',
        description: 'Folder with tags only',
      );
      final tags = [
        Metadata(value: 'tag1', type: MetadataTypeEnum.tag),
        Metadata(value: 'tag2', type: MetadataTypeEnum.tag),
        Metadata(value: 'tag3', type: MetadataTypeEnum.tag),
      ];

      await database.createFolder(folderInfo: folderInfo, tags: tags);

      final folderResult = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(folderInfo.id)))
          .get();
      expect(folderResult.length, 1);
      expect(folderResult.first.title, 'Tagged Folder');

      final tagResult = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(folderInfo.id)))
          .get();
      expect(tagResult.length, 3);

      final itemResult = await (database.select(database.items)
            ..where((tbl) => tbl.folderId.equals(folderInfo.id)))
          .get();
      expect(itemResult.length, 0);
    });

    test('adds folder with tags and items', () async {
      final folderInfo = FolderInfo(
        title: 'Item folder',
        description: 'Testing if we can create folder with tags and items',
      );
      final tags = [
        Metadata(value: 'tag1', type: MetadataTypeEnum.tag),
        Metadata(value: 'tag2', type: MetadataTypeEnum.tag),
      ];

      final items = [
        FolderItem(
            type: FolderItemType.link,
            content: StringContent("https://example.com")),
        FolderItem(
            type: FolderItemType.document,
            content:
                MapContent({"title": "Test document", "body": "Blablabla"})),
      ];

      await database.createFolder(
          folderInfo: folderInfo, tags: tags, items: items);

      final folderResult = await (database.select(database.folders)
            ..where((tbl) => tbl.id.equals(folderInfo.id)))
          .get();

      expect(folderResult.first.title, folderInfo.title);

      final tagResult = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(folderInfo.id)))
          .get();
      expect(tagResult.length, 2);

      final linkResult = await (database.select(database.links)
            ..where(
              (tbl) => tbl.id.equals(items.first.itemId),
            ))
          .get();
      expect(linkResult.first.id, items.first.itemId);
      expect(linkResult.length, 1);

      final itemsResults = await (database.select(database.items)
            ..where((tbl) => tbl.folderId.equals(folderInfo.id)))
          .get();

      expect(itemsResults.length, 2);
    });
  });
}
