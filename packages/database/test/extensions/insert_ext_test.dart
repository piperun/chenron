import "package:database/main.dart";

import "package:database/models/created_ids.dart";
import "package:database/models/document_file_type.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/src/core/handlers/relation_handler.dart";
import "package:database/src/core/id.dart";
import "package:database/src/features/document/handlers/insert_handler.dart";
import "package:database/src/features/link/handlers/insert_handler.dart";
import "package:database/src/features/tag/handlers/insert_handler.dart";
import "package:database/src/features/user_theme/handlers/insert_handler.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
      databaseName: "test_db",
      setupOnInit: true,
      debugMode: true,
    );
  });

  tearDown(() async {
    await database.delete(database.links).go();
    await database.delete(database.documents).go();
    await database.delete(database.tags).go();
    await database.delete(database.items).go();
    await database.delete(database.metadataRecords).go();
    await database.close();
  });

  group("InsertionExtensions.insertLinks()", () {
    test("inserts single link", () async {
      late List<LinkResultIds> results;
      await database.batch((batch) async {
        results = await database.insertLinks(
          batch: batch,
          urls: ["https://example.com"],
        );
      });

      expect(results.length, equals(1));
      expect(results.first.linkId, isNotEmpty);

      // Verify link in database
      final links = await database.select(database.links).get();
      expect(links.length, equals(1));
      expect(links.first.path, equals("https://example.com"));
    });

    test("inserts multiple links", () async {
      late List<LinkResultIds> results;
      await database.batch((batch) async {
        results = await database.insertLinks(
          batch: batch,
          urls: [
            "https://flutter.dev",
            "https://dart.dev",
            "https://pub.dev",
          ],
        );
      });

      expect(results.length, equals(3));

      final links = await database.select(database.links).get();
      expect(links.length, equals(3));

      final paths = links.map((l) => l.path).toSet();
      expect(
          paths,
          equals({
            "https://flutter.dev",
            "https://dart.dev",
            "https://pub.dev",
          }));
    });

    test("handles empty URL list", () async {
      late List<LinkResultIds> results;
      await database.batch((batch) async {
        results = await database.insertLinks(
          batch: batch,
          urls: [],
        );
      });

      expect(results, isEmpty);
    });

    test("removes trailing slashes from URLs", () async {
      await database.batch((batch) async {
        await database.insertLinks(
          batch: batch,
          urls: ["https://example.com/", "https://test.com/path/"],
        );
      });

      final links = await database.select(database.links).get();
      expect(links.any((l) => l.path == "https://example.com"), isTrue);
      expect(links.any((l) => l.path == "https://test.com/path"), isTrue);
    });

    test("reuses existing links", () async {
      // Insert first link
      late List<LinkResultIds> results1;
      await database.batch((batch) async {
        results1 = await database.insertLinks(
          batch: batch,
          urls: ["https://duplicate.com"],
        );
      });

      // Insert same link again
      late List<LinkResultIds> results2;
      await database.batch((batch) async {
        results2 = await database.insertLinks(
          batch: batch,
          urls: ["https://duplicate.com"],
        );
      });

      // Should return same link ID
      expect(results1.first.linkId, equals(results2.first.linkId));

      // Should only have one link in database
      final links = await database.select(database.links).get();
      expect(links.length, equals(1));
    });

    test("handles mix of new and existing links", () async {
      // Insert initial links
      await database.batch((batch) async {
        await database.insertLinks(
          batch: batch,
          urls: ["https://existing1.com", "https://existing2.com"],
        );
      });

      // Insert mix of new and existing
      late List<LinkResultIds> results;
      await database.batch((batch) async {
        results = await database.insertLinks(
          batch: batch,
          urls: [
            "https://existing1.com",
            "https://new.com",
            "https://existing2.com",
          ],
        );
      });

      expect(results.length, equals(3));

      final links = await database.select(database.links).get();
      expect(links.length, equals(3)); // 2 existing + 1 new
    });
  });

  group("InsertionExtensions.insertDocuments()", () {
    test("inserts single document", () async {
      late List<DocumentResultIds> results;
      await database.batch((batch) async {
        results = database.insertDocuments(
          batch: batch,
          docs: [
            const FolderItem.document(
              title: "Test Doc",
              filePath: "documents/temp1.md",
            ) as DocumentItem
          ],
        );
      });

      expect(results.length, equals(1));
      expect(results.first.documentId, isNotEmpty);
    });

    test("inserts multiple documents", () async {
      late List<DocumentResultIds> results;
      await database.batch((batch) async {
        results = database.insertDocuments(
          batch: batch,
          docs: [
            const FolderItem.document(
              title: "Document 1",
              filePath: "documents/doc1.md",
            ) as DocumentItem,
            const FolderItem.document(
              title: "Document 2",
              filePath: "documents/doc2.md",
            ) as DocumentItem,
            const FolderItem.document(
              title: "Document 3",
              filePath: "documents/doc3.md",
            ) as DocumentItem,
          ],
        );
      });

      expect(results.length, equals(3));

      final docs = await database.select(database.documents).get();
      expect(docs.length, equals(3));
    });

    test("handles empty document list", () async {
      late List<DocumentResultIds> results;
      await database.batch((batch) async {
        results = database.insertDocuments(
          batch: batch,
          docs: [],
        );
      });

      expect(results, isEmpty);
    });

    test("handles empty body with valid titles", () async {
      late List<DocumentResultIds> results;
      await database.batch((batch) {
        results = database.insertDocuments(
          batch: batch,
          docs: [
            const FolderItem.document(
              title: "EmptyBody",
              filePath: "",
            ) as DocumentItem,
            const FolderItem.document(
              title: "Valid1",
              filePath: "body-2",
            ) as DocumentItem,
            const FolderItem.document(
              title: "Valid2",
              filePath: "body-3",
            ) as DocumentItem,
          ],
        );
      });

      expect(results.length, equals(3));

      final docs = await database.select(database.documents).get();

      // Verify all three documents were inserted
      expect(docs[0].title, equals("EmptyBody"));
      expect(docs[0].filePath, equals(""));

      expect(docs[1].title, equals("Valid1"));
      expect(docs[1].filePath, equals("body-2"));

      expect(docs[2].title, equals("Valid2"));
      expect(docs[2].filePath, equals("body-3"));
    });
  });

  group("InsertionExtensions.insertTags()", () {
    test("inserts single tag", () async {
      late List<TagResultIds> results;
      await database.batch((batch) async {
        results = await database.insertTags(
          batch: batch,
          tagMetadata: [
            Metadata(value: "flutter", type: MetadataTypeEnum.tag),
          ],
        );
      });

      expect(results.length, equals(1));
      expect(results.first.tagId, isNotEmpty);

      final tags = await database.select(database.tags).get();
      expect(tags.length, equals(1));
      expect(tags.first.name, equals("flutter"));
    });

    test("inserts multiple tags", () async {
      late List<TagResultIds> results;
      await database.batch((batch) async {
        results = await database.insertTags(
          batch: batch,
          tagMetadata: [
            Metadata(value: "dart", type: MetadataTypeEnum.tag),
            Metadata(value: "flutter", type: MetadataTypeEnum.tag),
            Metadata(value: "mobile", type: MetadataTypeEnum.tag),
          ],
        );
      });

      expect(results.length, equals(3));

      final tags = await database.select(database.tags).get();
      expect(tags.length, equals(3));
    });

    test("reuses existing tags", () async {
      // Insert first tag
      late List<TagResultIds> results1;
      await database.batch((batch) async {
        results1 = await database.insertTags(
          batch: batch,
          tagMetadata: [
            Metadata(value: "reusable", type: MetadataTypeEnum.tag),
          ],
        );
      });

      // Insert same tag again
      late List<TagResultIds> results2;
      await database.batch((batch) async {
        results2 = await database.insertTags(
          batch: batch,
          tagMetadata: [
            Metadata(value: "reusable", type: MetadataTypeEnum.tag),
          ],
        );
      });

      // Should return same tag ID
      expect(results1.first.tagId, equals(results2.first.tagId));

      // Should only have one tag in database
      final tags = await database.select(database.tags).get();
      expect(tags.length, equals(1));
    });

    test("handles empty tag list", () async {
      late List<TagResultIds> results;
      await database.batch((batch) async {
        results = await database.insertTags(
          batch: batch,
          tagMetadata: [],
        );
      });

      expect(results, isEmpty);
    });

    test("handles large number of tags (chunking)", () async {
      // Create 1000 tags to test chunking logic (max query size is 500)
      final tagMetadata = List.generate(
        1000,
        (i) => Metadata(value: "tag_$i", type: MetadataTypeEnum.tag),
      );

      late List<TagResultIds> results;
      await database.batch((batch) async {
        results = await database.insertTags(
          batch: batch,
          tagMetadata: tagMetadata,
        );
      });

      expect(results.length, equals(1000));

      final tags = await database.select(database.tags).get();
      expect(tags.length, equals(1000));
    });
  });

  group("InsertionExtensions.insertItemRelation()", () {
    test("inserts link item relation", () async {
      final folderId = database.generateId();
      final linkId = database.generateId();

      // Create folder and link first
      await database.batch((batch) {
        batch.insert(
          database.folders,
          FoldersCompanion.insert(
              id: folderId, title: "Test Folder", description: ""),
        );
        batch.insert(
          database.links,
          LinksCompanion.insert(id: linkId, path: "https://test.com"),
        );
      });

      late ItemResultIds result;
      await database.batch((batch) async {
        result = database.insertItemRelation(
          batch: batch,
          entityId: linkId,
          folderId: folderId,
          type: FolderItemType.link,
        );
      });

      expect(result.itemId, isNotEmpty);
      expect(result.folderId, equals(folderId));
      expect(result.linkId, equals(linkId));
      expect(result.documentId, isNull);

      final items = await database.select(database.items).get();
      expect(items.length, equals(1));
      expect(items.first.typeId, equals(FolderItemType.link.index));
    });

    test("inserts document item relation", () async {
      final folderId = database.generateId();
      final docId = database.generateId();

      // Create folder and document first
      await database.batch((batch) {
        batch.insert(
          database.folders,
          FoldersCompanion.insert(
              id: folderId, title: "Test Folder", description: ""),
        );
        batch.insert(
          database.documents,
          DocumentsCompanion.insert(
            id: docId,
            title: "Test Doc",
            filePath: "documents/$docId.md",
            fileType: DocumentFileType.markdown,
          ),
        );
      });

      late ItemResultIds result;
      await database.batch((batch) async {
        result = database.insertItemRelation(
          batch: batch,
          entityId: docId,
          folderId: folderId,
          type: FolderItemType.document,
        );
      });

      expect(result.itemId, isNotEmpty);
      expect(result.folderId, equals(folderId));
      expect(result.documentId, equals(docId));
      expect(result.linkId, isNull);

      final items = await database.select(database.items).get();
      expect(items.first.typeId, equals(FolderItemType.document.index));
    });
  });

  group("InsertionExtensions.insertMetadataRelation()", () {
    test("inserts tag metadata relation", () async {
      final itemId = database.generateId();
      final tagId = database.generateId();

      // Create link and tag first
      await database.batch((batch) {
        batch.insert(
          database.links,
          LinksCompanion.insert(id: itemId, path: "https://test.com"),
        );
        batch.insert(
          database.tags,
          TagsCompanion.insert(id: tagId, name: "test-tag"),
        );
      });

      late MetadataResultIds result;
      await database.batch((batch) async {
        result = database.insertMetadataRelation(
          batch: batch,
          itemId: itemId,
          metadataId: tagId,
          type: MetadataTypeEnum.tag,
        );
      });

      expect(result.metadataId, isNotEmpty);
      expect(result.itemId, equals(itemId));

      final metadata = await database.select(database.metadataRecords).get();
      expect(metadata.length, equals(1));
      expect(metadata.first.itemId, equals(itemId));
      expect(metadata.first.metadataId, equals(tagId));
      expect(metadata.first.typeId, equals(MetadataTypeEnum.tag.index));
    });

    test("inserts metadata relation with value", () async {
      final itemId = database.generateId();
      final metadataId = database.generateId();

      late MetadataResultIds result;
      await database.batch((batch) async {
        result = database.insertMetadataRelation(
          batch: batch,
          itemId: itemId,
          metadataId: metadataId,
          type: MetadataTypeEnum.tag,
          value: "custom-value",
        );
      });

      expect(result.metadataId, isNotEmpty);

      final metadata = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.id.equals(result.metadataId)))
          .getSingleOrNull();

      expect(metadata!.value, equals("custom-value"));
    });
  });

  group("ConfigDatabaseInserts.insertUserThemes()", () {
    late ConfigDatabase configDb;

    setUpAll(() {
      configDb = ConfigDatabase(
        databaseName: "test_config_db",
        debugMode: true,
      );
    });

    tearDown(() async {
      await configDb.delete(configDb.userThemes).go();
      await configDb.delete(configDb.userConfigs).go();
    });

    tearDownAll(() async {
      await configDb.close();
    });

    test("inserts single user theme", () async {
      final userConfigId = configDb.generateId();

      // Create user config first
      await configDb.into(configDb.userConfigs).insert(
            UserConfigsCompanion.insert(id: userConfigId),
          );

      late List<UserThemeResultIds> results;
      await configDb.batch((batch) async {
        results = await configDb.insertUserThemes(
          batch: batch,
          themes: [
            UserTheme(
              id: "",
              userConfigId: userConfigId,
              name: "Test Theme",
              primaryColor: 0xFFFF0000,
              secondaryColor: 0xFF00FF00,
              seedType: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
          userConfigId: userConfigId,
        );
      });

      expect(results.length, equals(1));
      expect(results.first.userThemeId, isNotEmpty);
      expect(results.first.userConfigId, equals(userConfigId));

      final themes = await configDb.select(configDb.userThemes).get();
      expect(themes.length, equals(1));
      expect(themes.first.name, equals("Test Theme"));
    });

    test("inserts multiple user themes", () async {
      final userConfigId = configDb.generateId();

      await configDb.into(configDb.userConfigs).insert(
            UserConfigsCompanion.insert(id: userConfigId),
          );

      late List<UserThemeResultIds> results;
      await configDb.batch((batch) async {
        results = await configDb.insertUserThemes(
          batch: batch,
          themes: [
            UserTheme(
              id: "",
              userConfigId: userConfigId,
              name: "Theme 1",
              primaryColor: 0xFF111111,
              secondaryColor: 0xFF222222,
              seedType: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            UserTheme(
              id: "",
              userConfigId: userConfigId,
              name: "Theme 2",
              primaryColor: 0xFF333333,
              secondaryColor: 0xFF444444,
              seedType: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
          userConfigId: userConfigId,
        );
      });

      expect(results.length, equals(2));

      final themes = await configDb.select(configDb.userThemes).get();
      expect(themes.length, equals(2));
    });

    test("handles empty theme list", () async {
      final userConfigId = configDb.generateId();

      late List<UserThemeResultIds> results;
      await configDb.batch((batch) async {
        results = await configDb.insertUserThemes(
          batch: batch,
          themes: [],
          userConfigId: userConfigId,
        );
      });

      expect(results, isEmpty);
    });
  });
}
