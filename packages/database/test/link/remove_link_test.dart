import "package:database/main.dart";
import "package:database/models/metadata.dart";
import "package:flutter_test/flutter_test.dart";

import "package:database/src/features/link/create.dart";
import "package:database/src/features/link/remove.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(
      databaseName: "test_db",
      setupOnInit: true,
      debugMode: true,
    );
  });

  tearDown(() async {
    await database.close();
  });

  group("Link Deletion", () {
    test("remove single link by ID", () async {
      // Create two links
      final result1 = await database.createLink(link: "https://link1.com");
      final result2 = await database.createLink(link: "https://link2.com");

      // Remove the first link
      final deleted = await database.removeLink(result1.linkId);

      expect(deleted, isTrue);

      // Verify link1 was deleted
      final deletedLink = await (database.select(database.links)
            ..where((tbl) => tbl.id.equals(result1.linkId)))
          .getSingleOrNull();

      // Verify link2 still exists
      final remainingLink = await (database.select(database.links)
            ..where((tbl) => tbl.id.equals(result2.linkId)))
          .getSingleOrNull();

      expect(deletedLink, isNull);
      expect(remainingLink, isNotNull);
    });

    test("remove link with tags - tags should remain", () async {
      // Create link with tags
      final result = await database.createLink(
        link: "https://tagged.com",
        tags: [
          Metadata(value: "tag1", type: MetadataTypeEnum.tag),
          Metadata(value: "tag2", type: MetadataTypeEnum.tag),
        ],
      );

      // Verify tags were created
      final tagsBefore = await database.select(database.tags).get();
      expect(tagsBefore.length, equals(2));

      // Verify metadata records were created
      final metadataRecordsBefore =
          await (database.select(database.metadataRecords)
                ..where((tbl) => tbl.itemId.equals(result.linkId)))
              .get();
      expect(metadataRecordsBefore.length, equals(2));

      // Remove the link
      final deleted = await database.removeLink(result.linkId);
      expect(deleted, isTrue);

      // Verify link was deleted
      final deletedLink = await (database.select(database.links)
            ..where((tbl) => tbl.id.equals(result.linkId)))
          .getSingleOrNull();
      expect(deletedLink, isNull);

      // Verify metadata records (many-to-many) were deleted
      final metadataRecordsAfter =
          await (database.select(database.metadataRecords)
                ..where((tbl) => tbl.itemId.equals(result.linkId)))
              .get();
      expect(metadataRecordsAfter.length, equals(0));

      // Verify tags themselves still exist
      final tagsAfter = await database.select(database.tags).get();
      expect(tagsAfter.length, equals(2));
    });

    test("remove non-existent link returns false", () async {
      final deleted = await database.removeLink("nonexistent-id");
      expect(deleted, isFalse);
    });
  });
}
