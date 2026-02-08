import "package:database/main.dart";
import "package:database/models/metadata.dart";
import "package:database/src/features/document/update.dart";
import "package:database/src/features/folder/read.dart";
import "package:database/src/features/folder/update.dart";
import "package:database/src/features/link/update.dart";
import "package:database/src/features/link/remove.dart";
import "package:database/src/features/backup_settings/update.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  group("AppDatabase: operations on non-existent IDs", () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase(
        databaseName: "test_db",
        setupOnInit: true,
        debugMode: true,
      );

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
    });

    tearDown(() async {
      await database.close();
    });

    // -- Folder --

    test("updateFolder on non-existent ID updates zero rows silently",
        () async {
      final (folderIds, _, _) = await database.updateFolder(
        "non_existent_folder",
        title: "Updated Title",
      );

      // Returns the same ID back, no error thrown
      expect(folderIds.folderId, equals("non_existent_folder"));

      // No folder was actually created
      final folder = await database.getFolder(folderId: "non_existent_folder");
      expect(folder, isNull);
    });

    // -- Document --

    test("updateDocument on non-existent ID throws ArgumentError", () async {
      await expectLater(
        database.updateDocument(
          documentId: "non_existent_doc",
          title: "New Title",
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    // -- Link --

    test("updateLinkArchiveUrls on non-existent ID returns false", () async {
      final result = await database.updateLinkArchiveUrls(
        linkId: "non_existent_link",
        archiveOrgUrl: "https://web.archive.org/web/test",
      );

      expect(result, isFalse);
    });

    test("removeTagsFromLink on non-existent link returns 0", () async {
      final deletedCount = await database.removeTagsFromLink(
        linkId: "non_existent_link",
        tagIds: ["some_tag_id"],
      );

      expect(deletedCount, equals(0));
    });

    test("removeTagsFromDocument on non-existent document returns 0",
        () async {
      final deletedCount = await database.removeTagsFromDocument(
        documentId: "non_existent_doc",
        tagIds: ["some_tag_id"],
      );

      expect(deletedCount, equals(0));
    });

    test("removeLink on non-existent ID returns false", () async {
      final result = await database.removeLink("non_existent_link");

      expect(result, isFalse);
    });

    // -- Cross-entity: add tags to non-existent entity --

    test("addTagsToLink with non-existent link throws ArgumentError",
        () async {
      await expectLater(
        database.addTagsToLink(
          linkId: "non_existent_link",
          tags: [Metadata(value: "orphan-tag", type: MetadataTypeEnum.tag)],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("addTagsToDocument with non-existent document throws ArgumentError",
        () async {
      await expectLater(
        database.addTagsToDocument(
          documentId: "non_existent_doc",
          tags: [Metadata(value: "orphan-tag2", type: MetadataTypeEnum.tag)],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group("ConfigDatabase: operations on non-existent IDs", () {
    late ConfigDatabase database;

    setUp(() async {
      database = ConfigDatabase(
        databaseName: "test_config_db",
        setupOnInit: true,
        debugMode: true,
      );
    });

    tearDown(() async {
      final userConfigs = database.userConfigs;
      await database.delete(userConfigs).go();
      final backupSettingsTable = database.backupSettings;
      await database.delete(backupSettingsTable).go();
      await database.close();
    });

    test("updateBackupSettings on non-existent ID completes without error",
        () async {
      // Updates 0 rows silently — no error thrown
      await expectLater(
        database.updateBackupSettings(
          id: "non_existent_backup_settings",
          backupInterval: "0 0 */4 * * *",
        ),
        completes,
      );
    });
  });
}
