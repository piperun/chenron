import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/create.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/database/extensions/folder/update.dart';
import 'package:chenron/database/extensions/tags/create.dart';
import 'package:chenron/models/cud.dart';
import 'package:chenron/models/folder.dart';
import 'package:chenron/models/folder_results.dart';
import 'package:chenron/models/item.dart';
import 'package:chenron/models/metadata.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chenron/test_lib/folder_factory.dart';

void main() {
  late AppDatabase database;
  late FolderTestData testFolderData;
  final List<String> newTagNames = ['NewTags1', 'NewTags2'];
  late List<Metadata> testNewTags;
  final List<String> testNewTagIds = [];
  late FolderResults results;

  setUp(() async {
    database = AppDatabase(databaseName: 'test_db');

    testFolderData = FolderTestDataFactory.create(
      title: 'update folder',
      description: 'this folder is only for testing updateFolder',
      tagValues: [],
      itemsData: [],
    );

    testNewTags = MetadataFactory.createTags(newTagNames);

    results = await database.createFolder(
        folderInfo: FolderInfo(
      title: testFolderData.folder.title,
      description: testFolderData.folder.description,
    ));

    for (int i = 0; i < testNewTags.length; i++) {
      testNewTagIds.add(await database.addTag(testNewTags[i].value));
    }
  });

  tearDown(() async {
    await database.delete(database.folders).go();
    await database.delete(database.items).go();
    await database.delete(database.metadataRecords).go();
    await database.delete(database.tags).go();
    await database.close();
  });

  group('Update Folder: Create', () {
    test('should create and add new items to folder', () async {
      final folderItems = CUD<FolderItem>(
        create: FolderItemFactory.createItems([
          {
            'type': 'link',
            'content': 'https://${DateTime.now().millisecondsSinceEpoch}.com'
          },
          {
            'type': 'document',
            'content': {'title': 'New Document', 'body': 'Content'}
          },
        ]),
      );

      await database.updateFolder(results.folderId!, itemUpdates: folderItems);
      final updateResult = await database.getFolder(results.folderId!,
          mode: IncludeFolderData.items);
      final folderItemsResult = await (database.items.select()
            ..where((item) =>
                item.folderId.equals(results.folderId!) &
                item.id.isIn(updateResult!.items.map((item) => item.itemId!))))
          .get();

      final folderLinks = folderItemsResult
          .where((item) => item.typeId == FolderItemType.link.index)
          .toList();
      final folderDocuments = folderItemsResult
          .where((item) => item.typeId == FolderItemType.document.index)
          .toList();

      expect(folderLinks.length, equals(1));
      expect(folderDocuments.length, equals(1));
    });
  });
  group('Update folder: Update', () {
    test('should update folder title and description', () async {
      await database.updateFolder(
        results.folderId!,
        title: 'new folder title',
        description:
            'Updated Description, this folder is only for testing updateFolder',
      );

      final updatedFolder =
          await database.folders.findById(results.folderId!).getSingle();
      expect(updatedFolder.title, equals('new folder title'));
      expect(
          updatedFolder.description,
          equals(
              'Updated Description, this folder is only for testing updateFolder'));
    });
    test('should update folder with two additional existing Tags', () async {
      Map<String, String> ids = {};
      List<Metadata> connectTags = [];
      for (int i = 0; i < testNewTags.length; i++) {
        ids[testNewTags[i].value] = testNewTagIds[i];
      }

      connectTags = MetadataFactory.createTags(newTagNames, metadataIds: ids);

      final tagUpdates = CUD<Metadata>(update: connectTags);

      await database.updateFolder(results.folderId!, tagUpdates: tagUpdates);

      final folderTags = await (database.metadataRecords.select()
            ..where((t) => t.itemId.equals(results.folderId!))
            ..where((tbl) =>
                tbl.metadataId.isIn(connectTags.map((tag) => tag.metadataId!))))
          .get();

      expect(folderTags.length, equals(2),
          reason: 'Both tags should be added to the folder');

      for (var tag in connectTags) {
        expect(
          folderTags.any((ft) => ft.metadataId == tag.metadataId),
          isTrue,
          reason: '${tag.value} should be associated with the folder',
        );
      }
    });

    test('should update folder with an existing item', () async {
      final itemUpdates = CUD<FolderItem>(update: [
        FolderItem(
            type: FolderItemType.link,
            content: StringContent(value: 'https://example.com'),
            itemId: 'nayscsy4hk75zwg83qxhddtct04ut8')
      ]);

      await database.updateFolder(results.folderId!, itemUpdates: itemUpdates);

      final updatedFolderItem = await (database.items.select()
            ..where((tbl) => tbl.folderId.equals(results.folderId!))
            ..where(
                (tbl) => tbl.itemId.equals(itemUpdates.update.first.itemId!)))
          .getSingleOrNull();

      expect(updatedFolderItem != null, true);
      expect(
          updatedFolderItem!.itemId, equals(itemUpdates.update.first.itemId));
    });
  });
  group('Update Folder: Remove', () {
    test('should remove tags from folder', () async {
      // Create two tags
      final newTags = [
        Metadata(type: MetadataTypeEnum.tag, value: 'deleteMeTag1'),
        Metadata(type: MetadataTypeEnum.tag, value: 'deleteMeTag2'),
      ];

      // Add tags to the folder
      final addTagsCUD = CUD<Metadata>(create: newTags);
      await database.updateFolder(results.folderId!, tagUpdates: addTagsCUD);

      // Check that tags were added correctly
      final addedTags = await database.getFolder(results.folderId!,
          mode: IncludeFolderData.tags);
      expect(addedTags!.tags.length, equals(2));
      expect(addedTags.tags.map((t) => t.name).toSet(),
          equals({'deleteMeTag1', 'deleteMeTag2'}));

      // Prepare tags for removal
      final tagsToRemove = addedTags.tags
          .map((tag) => Metadata(
              id: tag.id,
              metadataId: tag.id,
              value: tag.name,
              type: MetadataTypeEnum.tag))
          .toList();

      // Remove tags from the folder
      final removeTagsCUD =
          CUD<Metadata>(remove: tagsToRemove.map((t) => t.id!).toList());
      await database.updateFolder(results.folderId!, tagUpdates: removeTagsCUD);

      // Check that tags were removed
      final updatedFolder = await database.getFolder(results.folderId!,
          mode: IncludeFolderData.tags);
      expect(updatedFolder!.tags.length, equals(0));
    });

    test('should create, add and remove items from folder', () async {
      final itemUpdates = CUD<FolderItem>(create: [
        FolderItem(
            type: FolderItemType.link,
            content: StringContent(value: 'https://example.com'))
      ]);
      await database.updateFolder(results.folderId!, itemUpdates: itemUpdates);

      itemUpdates.remove.add(itemUpdates.create[0].itemId!);
      await database.updateFolder(results.folderId!, itemUpdates: itemUpdates);

      final folderLinks = await (database.items.select()
            ..where((tbl) => tbl.folderId.equals(results.folderId!))
            ..where((tbl) => tbl.itemId.equals(itemUpdates.create[0].itemId!)))
          .get();
      expect(folderLinks.length, equals(0));
    });
  });
}
