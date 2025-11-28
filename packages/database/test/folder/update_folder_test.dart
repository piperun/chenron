import "package:core/patterns/include_options.dart";
import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/cud.dart";
import "package:database/models/folder.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/src/features/folder/create.dart";
import "package:database/src/features/folder/read.dart";
import "package:database/src/features/folder/update.dart";
import "package:database/src/features/tag/create.dart";
import "package:drift/drift.dart";
import "package:flutter_test/flutter_test.dart" as matcher;
import "package:flutter_test/flutter_test.dart";
import "package:chenron_mockups/chenron_mockups.dart";

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
    final folders = database.folders;
    await database.delete(folders).go();
    final items = database.items;
    await database.delete(items).go();
    final metadataRecords = database.metadataRecords;
    await database.delete(metadataRecords).go();
    final tags = database.tags;
    await database.delete(tags).go();
    final links = database.links;
    await database.delete(links).go();
    final documents = database.documents;
    await database.delete(documents).go();
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

    test("should update folder color", () async {
      // Set initial color
      final colorValue = 0xFF2196F3;
      await database.updateFolder(
        createdIds.folderId,
        color: Value(colorValue),
      );

      var updatedFolder =
          await database.folders.findById(createdIds.folderId).getSingle();
      expect(updatedFolder.color, equals(colorValue));

      // Remove color (set to null)
      await database.updateFolder(
        createdIds.folderId,
        color: const Value(null),
      );

      updatedFolder =
          await database.folders.findById(createdIds.folderId).getSingle();
      expect(updatedFolder.color, matcher.isNull);
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
        const FolderItem.link(
            url: "https://example.com",
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
      final itemUpdates = CUD<FolderItem>(
          create: [const FolderItem.link(url: "https://example.com")]);

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

  group("Update Folder Exceptions", () {
    test("fails to update folder with short title", () async {
      expect(
        () => database.updateFolder(
          createdIds.folderId,
          title: "Short", // Less than 6 chars
        ),
        throwsA(isA<Exception>()),
      );
    });

    test("fails to update folder with long title", () async {
      expect(
        () => database.updateFolder(
          createdIds.folderId,
          title:
              "This title is definitely way too long for the limit", // > 30 chars
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
        "updateFolder completes without error for non-existent folder (Idempotent)",
        () async {
      // The current implementation does not throw if the folder doesn't exist.
      // It attempts the update and returns the ID.
      await database.updateFolder(
        "non-existent-id",
        title: "New Title",
      );
    });
  });
}
