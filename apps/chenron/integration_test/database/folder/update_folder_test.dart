import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/create.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/folder/update.dart";
import "package:chenron/database/extensions/tags/create.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/models/created_ids.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:drift/drift.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/utils/test_lib/folder_factory.dart";

import "package:chenron/test_support/path_provider_fake.dart";
import "package:chenron/test_support/logger_setup.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });
  late AppDatabase database;
  late FolderTestData testFolderData;
  final List<String> newTagNames = ["NewTags1", "NewTags2"];
  late List<Metadata> testNewTags;
  final List<String> testNewTagIds = [];
  late FolderResultIds createdIds;

  setUp(() async {
    database = AppDatabase(
        databaseName: "test_db", setupOnInit: true, debugMode: true);

    testFolderData = FolderTestDataFactory.create(
      title: "update folder",
      description: "this folder is only for testing updateFolder",
      tagValues: [],
      itemsData: [],
    );

    testNewTags = MetadataFactory.createTags(newTagNames);

    createdIds = await database.createFolder(
        folderInfo: FolderDraft(
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
    await database.delete(database.links).go();
    await database.delete(database.documents).go();
    await database.close();
  });

  group("Update Folder: Create", () {
    test("should create and add new items to folder", () async {
      final folderItems = CUD<FolderItem>(
        create: FolderItemFactory.createItems([
          {
            "type": "link",
            "content": "https://${DateTime.now().millisecondsSinceEpoch}.com"
          },
          {
            "type": "document",
            "content": {"title": "New Document", "body": "Content"}
          },
        ]),
      );

      await database.updateFolder(createdIds.folderId,
          itemUpdates: folderItems);
      final updateResult = await database.getFolder(
          folderId: createdIds.folderId,
          includeOptions: const IncludeOptions({AppDataInclude.items}));
      final folderItemsResult = await (database.items.select()
            ..where((item) =>
                item.folderId.equals(createdIds.folderId) &
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
  group("Update folder: Update", () {
    test("should update folder title and description", () async {
      await database.updateFolder(
        createdIds.folderId,
        title: "new folder title",
        description:
            "Updated Description, this folder is only for testing updateFolder",
      );

      final updatedFolder =
          await database.folders.findById(createdIds.folderId).getSingle();
      expect(updatedFolder.title, equals("new folder title"));
      expect(
          updatedFolder.description,
          equals(
              "Updated Description, this folder is only for testing updateFolder"));
    });
    test("should update folder with two additional existing Tags", () async {
      final Map<String, String> ids = {};
      List<Metadata> connectTags = [];
      for (int i = 0; i < testNewTags.length; i++) {
        ids[testNewTags[i].value] = testNewTagIds[i];
      }

      connectTags = MetadataFactory.createTags(newTagNames, metadataIds: ids);

      final tagUpdates = CUD<Metadata>(update: connectTags);

      await database.updateFolder(createdIds.folderId, tagUpdates: tagUpdates);

      final folderTags = await (database.metadataRecords.select()
            ..where((t) => t.itemId.equals(createdIds.folderId))
            ..where((tbl) =>
                tbl.metadataId.isIn(connectTags.map((tag) => tag.metadataId!))))
          .get();

      expect(folderTags.length, equals(2),
          reason: "Both tags should be added to the folder");

      for (var tag in connectTags) {
        expect(
          folderTags.any((ft) => ft.metadataId == tag.metadataId),
          isTrue,
          reason: "${tag.value} should be associated with the folder",
        );
      }
    });

    test("should update folder with an existing item", () async {
      final itemUpdates = CUD<FolderItem>(update: [
        FolderItem(
            type: FolderItemType.link,
            content: const StringContent(value: "https://example.com"),
            itemId: "nayscsy4hk75zwg83qxhddtct04ut8")
      ]);

      await database.updateFolder(createdIds.folderId,
          itemUpdates: itemUpdates);

      final updatedFolderItem = await (database.items.select()
            ..where((tbl) => tbl.folderId.equals(createdIds.folderId))
            ..where(
                (tbl) => tbl.itemId.equals(itemUpdates.update.first.itemId!)))
          .getSingleOrNull();

      expect(updatedFolderItem != null, true);
      expect(
          updatedFolderItem!.itemId, equals(itemUpdates.update.first.itemId));
    });
  });
  group("Update Folder: Remove", () {
    test("should remove tags from folder", () async {
      // Create two tags
      final newTags = [
        Metadata(type: MetadataTypeEnum.tag, value: "deleteMeTag1"),
        Metadata(type: MetadataTypeEnum.tag, value: "deleteMeTag2"),
      ];

      // Add tags to the folder
      final addTagsCUD = CUD<Metadata>(create: newTags);
      await database.updateFolder(createdIds.folderId, tagUpdates: addTagsCUD);

      // Check that tags were added correctly
      final addedTags = await database.getFolder(
          folderId: createdIds.folderId,
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));
      expect(addedTags!.tags.length, equals(2));
      expect(addedTags.tags.map((t) => t.name).toSet(),
          equals({"deleteMeTag1", "deleteMeTag2"}));

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
      await database.updateFolder(createdIds.folderId,
          tagUpdates: removeTagsCUD);

      // Check that tags were removed
      final updatedFolder = await database.getFolder(
          folderId: createdIds.folderId,
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));
      expect(updatedFolder!.tags.length, equals(0));
    });

    test("should create, add and remove items from folder", () async {
      // Create a new folder item
      final itemUpdates = CUD<FolderItem>(create: [
        FolderItem(
            type: FolderItemType.link,
            content: const StringContent(value: "https://example.com"))
      ]);

      // Add the item to the folder and get the result
      final result = await database.updateFolder(createdIds.folderId,
          itemUpdates: itemUpdates);

      // Extract the created item ID from the result
      final createdItemId = result.$3["create"]![0].itemId;

      // Create a new CUD object for removal
      final removeUpdates = CUD<FolderItem>();
      removeUpdates.removeItem(createdItemId);

      // Remove the item from the folder
      await database.updateFolder(createdIds.folderId,
          itemUpdates: removeUpdates);

      // Verify the item has been removed
      final folderLinks = await (database.items.select()
            ..where((tbl) => tbl.folderId.equals(createdIds.folderId))
            ..where((tbl) => tbl.itemId.equals(createdItemId)))
          .get();

      expect(folderLinks.length, equals(0));
    });
  });
}
