import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/update.dart';
import 'package:chenron/database/extensions/tags/create.dart';
import 'package:chenron/models/cud.dart';
import 'package:chenron/models/folder.dart';
import 'package:chenron/models/item.dart';
import 'package:chenron/models/metadata.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late FolderInfo testFolder;

  setUp(() async {
    database = AppDatabase(databaseName: "test_db");
    await database.delete(database.folders).go();
    //await database.delete(database.items).go();
    //await database.delete(database.metadataRecords).go();
    //await database.delete(database.tags).go();
    testFolder = FolderInfo(
        title: "update folder",
        description: "this folder is only for testing updateFolder");
    await database.folders.insertOne(FoldersCompanion.insert(
        id: testFolder.id,
        title: testFolder.title,
        description: testFolder.description));
  });

  tearDown(() async {
    await database.close();
  });

  group('Update Folder: Create', () {
    test('should create and add new tags to folder', () async {
      database.addTag("NewTag1");
      database.addTag("NewTag2");

      final newTag1 = await (database.select(database.tags)
            ..where((tbl) => tbl.name.equalsNullable('NewTag1')))
          .getSingleOrNull();

      //await database.tags.findByName('name', 'NewTag1').getSingle();
      final newTag2 =
          await database.tags.findByName('name', 'NewTag2').getSingleOrNull();

      final tagUpdates = CUD<Metadata>(
        update: [
          Metadata(type: MetadataTypeEnum.tag, metadataId: newTag1?.id),
          Metadata(type: MetadataTypeEnum.tag, metadataId: newTag2?.id),
        ],
      );

      await database.updateFolder(testFolder.id, tagUpdates: tagUpdates);

      final folderTags = await (database.metadataRecords.select()
            ..where((t) => t.itemId.equals(testFolder.id))
            ..where((tbl) => tbl.metadataId.isIn([newTag1!.id, newTag2!.id])))
          .get();

      expect(folderTags.length, equals(2),
          reason: 'Both tags should be added to the folder');

      expect(
        folderTags.any((ft) => ft.metadataId == newTag1!.id),
        isTrue,
        reason: 'NewTag1 should be associated with the folder',
      );
      expect(
        folderTags.any((ft) => ft.metadataId == newTag2!.id),
        isTrue,
        reason: 'NewTag2 should be associated with the folder',
      );
    });
    test('should create and add new items to folder', () async {
      final folderItems = CUD<FolderItem>(
        create: [
          FolderItem(
              type: FolderItemType.link,
              content: StringContent(
                  'https://${DateTime.now().millisecondsSinceEpoch}.com')),
          FolderItem(
              type: FolderItemType.document,
              content:
                  MapContent({"title": 'New Document', "body": 'Content'})),
        ],
      );

      await database.updateFolder(testFolder.id, itemUpdates: folderItems);

      final folderItemsResult = await (database.items.select()
            ..where((item) =>
                item.folderId.equals(testFolder.id) &
                item.id.isIn(folderItems.create.map((i) => i.id))))
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
        testFolder.id,
        title: 'new folder title',
        description:
            'Updated Description, this folder is only for testing updateFolder',
      );

      final updatedFolder =
          await database.folders.findById(testFolder.id).getSingle();
      expect(updatedFolder.title, equals('new folder title'));
      expect(
          updatedFolder.description,
          equals(
              'Updated Description, this folder is only for testing updateFolder'));
    });
    test('should update folder with an existing item', () async {
      // First, add an item to the folder
      final itemUpdates = CUD<FolderItem>(update: [
        FolderItem(
            type: FolderItemType.link,
            content: StringContent('https://example.com'),
            itemId: "nayscsy4hk75zwg83qxhddtct04ut8")
      ]);

      await database.updateFolder(testFolder.id, itemUpdates: itemUpdates);

      final updatedFolderItem = await (database.items.select()
            ..where((tbl) => tbl.folderId.equals(testFolder.id))
            ..where(
                (tbl) => tbl.itemId.equals(itemUpdates.update.first.itemId)))
          .getSingleOrNull();

      expect(updatedFolderItem != null, true);
      expect(
          updatedFolderItem!.itemId, equals(itemUpdates.update.first.itemId));
    });
  });
  group('Update Folder: Remove', () {
    test('should remove tags from folder', () async {
      final CUD<Metadata> cudTags = CUD<Metadata>(create: [
        Metadata(type: MetadataTypeEnum.tag, value: "deleteMeTag1"),
        Metadata(type: MetadataTypeEnum.tag, value: "deleteMeTag2"),
      ]);

      final folderTagQueryResult = [];

      folderTagsQuery(searchId) {
        return (database.metadataRecords.select()
              ..where((tbl) => tbl.metadataId.equals(searchId))
              ..where((t) => t.itemId.equals(testFolder.id)))
            .get();
      }

      for (final tag in cudTags.create) {
        folderTagQueryResult.add(await folderTagsQuery(tag.id));
      }
      expect(folderTagQueryResult.length, equals(2),
          reason: "Two tags should have been added\n ");
      folderTagQueryResult.clear();
      await database.updateFolder(testFolder.id, tagUpdates: cudTags);

      for (final tag in cudTags.create) {
        cudTags.remove.add(tag.metadataId);
      }

      await database.updateFolder(testFolder.id, tagUpdates: cudTags);
      for (final tag in cudTags.create) {
        var temp = await folderTagsQuery(tag.id);
        if (temp.isNotEmpty) {
          folderTagQueryResult.add(temp);
        }
      }
      expect(folderTagQueryResult.length, equals(0),
          reason: "Two tags should have been removed");
    });

    test('should create, add and remove items from folder', () async {
      // First, add some items
      final itemUpdates = CUD<FolderItem>(create: [
        FolderItem(
            type: FolderItemType.link,
            content: StringContent('https://example.com'))
      ]);
      await database.updateFolder(testFolder.id, itemUpdates: itemUpdates);

      itemUpdates.remove.add(itemUpdates.create[0].itemId);
      await database.updateFolder(testFolder.id, itemUpdates: itemUpdates);

      final folderLinks = await (database.items.select()
            ..where((tbl) => tbl.folderId.equals(testFolder.id))
            ..where((tbl) => tbl.itemId.equals(itemUpdates.create[0].itemId)))
          .get();
      expect(folderLinks.length, equals(0));
    });
  });
}
