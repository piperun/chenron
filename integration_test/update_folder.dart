import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/types/data_types.dart';
import 'package:chenron/database/extensions/folder/update.dart';

void main() {
  late AppDatabase database;
  late FolderDataType testFolder;

  setUp(() async {
    database = AppDatabase();
    testFolder = FolderDataType(
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

  group('updateFolder', () {
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

    test('should update new tags to folder', () async {
      database.addTag("NewTag1");
      database.addTag("NewTag2");
      final newTag1 = await (database.select(database.tags)
            ..where((tbl) => tbl.name.equalsNullable('NewTag1')))
          .getSingleOrNull();

      //await database.tags.findByName('name', 'NewTag1').getSingle();
      final newTag2 =
          await database.tags.findByName('name', 'NewTag2').getSingleOrNull();

      final tagUpdates = CUD<Insertable>(
        update: [
          FolderTagsCompanion.insert(
              tagId: newTag1!.id, folderId: testFolder.id),
          FolderTagsCompanion.insert(
              tagId: newTag2!.id, folderId: testFolder.id)
        ],
      );

      await database.updateFolder(testFolder.id, tagUpdates: tagUpdates);

      final folderTags = await (database.folderTags.select()
            ..where((t) => t.folderId.equals(testFolder.id)))
          .get();

      expect(
        folderTags.any(
            (ft) => ft.folderId == testFolder.id && ft.tagId == newTag1.id),
        isTrue,
        reason: 'NewTag1 should be associated with the folder',
      );
      expect(
        folderTags.any(
            (ft) => ft.folderId == testFolder.id && ft.tagId == newTag2.id),
        isTrue,
        reason: 'NewTag2 should be associated with the folder',
      );
    });

    test('should remove tags from folder', () async {
      // First, add some tags
      final tagsToDelete = [
        TagDataType(name: 'deleteMeTag1'),
        TagDataType(name: 'deleteMeTag2')
      ];
      final CUD<Insertable> cudTags = CUD<Insertable>(
        create: [
          tagsToDelete[0],
          tagsToDelete[1],
        ],
      );

      folderTagsQuery(searchId) {
        return (database.folderTags.select()
              ..where((tbl) => tbl.tagId.equals(searchId))
              ..where((t) => t.folderId.equals(testFolder.id)))
            .get();
      }

      final folderTagQueryResult = [];
      for (final tag in cudTags.create) {
        folderTagQueryResult.add(await folderTagsQuery(tag.id));
      }
      expect(folderTagQueryResult.length, equals(2),
          reason: "Two tags should have been added\n ");
      folderTagQueryResult.clear();
      await database.updateFolder(testFolder.id, tagUpdates: cudTags);

      for (final tag in tagsToDelete) {
        cudTags.remove.add(
            FolderTagsCompanion.insert(folderId: testFolder.id, tagId: tag.id));
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

    test('should add new items to folder', () async {
      final dataBaseObjects = CUD<dynamic>(
        create: [
          LinkDataType(url: 'https://example.com'),
          DocumentDataType(title: 'New Document', content: 'Content'),
        ],
      );

      await database.updateFolder(testFolder.id,
          dataBaseObjects: dataBaseObjects);

      final folderLinks = await (database.folderLinks.select()
            ..where((l) => l.folderId.equals(testFolder.id)))
          .get();
      final folderDocuments = await (database.folderDocuments.select()
            ..where((d) => d.folderId.equals(testFolder.id)))
          .get();

      expect(folderLinks.length, equals(1));
      expect(folderDocuments.length, equals(1));
    });

    test('should remove items from folder', () async {
      // First, add some items
      final link = LinkDataType(url: 'https://example.com');
      await database.links.insertOne(
          mode: InsertMode.insertOrIgnore,
          onConflict: DoNothing(),
          LinksCompanion.insert(id: link.id, url: link.url));
      await database.folderLinks.insertOne(FolderLinksCompanion.insert(
        folderId: testFolder.id,
        linkId: link.id,
      ));

      final dataBaseObjects = CUD<dynamic>(
        remove: [
          FolderLinksCompanion(
              folderId: Value(testFolder.id), linkId: Value(link.id))
        ],
      );

      await database.updateFolder(testFolder.id,
          dataBaseObjects: dataBaseObjects);

      final folderLinks = await (database.folderLinks.select()
            ..where((l) => l.folderId.equals(testFolder.id)))
          .get();
      expect(folderLinks.length, equals(0));
    });
  });
}
