import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/link/create.dart";
import "package:chenron/database/extensions/link/remove.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:chenron/database/extensions/id.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/models/item.dart";

import "package:chenron/test_support/path_provider_fake.dart";
import "package:chenron/test_support/logger_setup.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(
        databaseName: "test_db", setupOnInit: true, debugMode: true);
  });

  tearDown(() async {
    await database.delete(database.links).go();
    await database.delete(database.metadataRecords).go();
    await database.delete(database.tags).go();
    await database.delete(database.items).go();
    await database.close();
  });

  group("removeLink() - Basic Operations", () {
    test("delete link without tags", () async {
      // Create link
      final result = await database.createLink(link: "https://example.com");

      // Delete link
      final deleted = await database.removeLink(result.linkId);

      expect(deleted, isTrue);

      // Verify link is deleted
      final linkResult = await database.getLink(linkId: result.linkId);
      expect(linkResult, isNull);
    });

    test("delete link with tags", () async {
      // Create link with tags
      final result = await database.createLink(
        link: "https://flutter.dev",
        tags: [
          Metadata(value: "flutter", type: MetadataTypeEnum.tag),
          Metadata(value: "dart", type: MetadataTypeEnum.tag),
        ],
      );

      // Delete link
      final deleted = await database.removeLink(result.linkId);

      expect(deleted, isTrue);

      // Verify link is deleted
      final linkResult = await database.getLink(linkId: result.linkId);
      expect(linkResult, isNull);

      // Verify metadata records are deleted
      final metadataResult = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.linkId)))
          .get();
      expect(metadataResult, isEmpty);

      // Tags should still exist (they might be used by other links)
      final tagResults = await database.select(database.tags).get();
      expect(tagResults.length, equals(2));
    });

    test("delete non-existent link returns false", () async {
      final deleted = await database.removeLink("non_existent_id");

      expect(deleted, isFalse);
    });

    test("delete link twice returns false on second attempt", () async {
      // Create link
      final result = await database.createLink(link: "https://example.com");

      // Delete first time
      final deleted1 = await database.removeLink(result.linkId);
      expect(deleted1, isTrue);

      // Delete second time
      final deleted2 = await database.removeLink(result.linkId);
      expect(deleted2, isFalse);
    });
  });

  group("removeLink() - Cascading Deletes", () {
    test("deleting link removes its metadata records", () async {
      // Create link with tags
      final result = await database.createLink(
        link: "https://example.com",
        tags: [
          Metadata(value: "tag1", type: MetadataTypeEnum.tag),
          Metadata(value: "tag2", type: MetadataTypeEnum.tag),
        ],
      );

      // Verify metadata records exist
      final metadataBefore = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.linkId)))
          .get();
      expect(metadataBefore.length, equals(2));

      // Delete link
      await database.removeLink(result.linkId);

      // Verify metadata records are deleted
      final metadataAfter = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.linkId)))
          .get();
      expect(metadataAfter, isEmpty);
    });

    test("deleting link removes item associations", () async {
      // Create link
      final result = await database.createLink(link: "https://example.com");

      // Manually create an item association (simulating folder containment)
      await database.into(database.items).insert(
            ItemsCompanion.insert(
              id: database.generateId(),
              folderId: "test_folder_id",
              itemId: result.linkId,
              typeId: FolderItemType.link.index,
            ),
          );

      // Verify item exists
      final itemsBefore = await (database.select(database.items)
            ..where((tbl) => tbl.itemId.equals(result.linkId)))
          .get();
      expect(itemsBefore.length, equals(1));

      // Delete link
      await database.removeLink(result.linkId);

      // Verify item association is deleted
      final itemsAfter = await (database.select(database.items)
            ..where((tbl) => tbl.itemId.equals(result.linkId)))
          .get();
      expect(itemsAfter, isEmpty);
    });

    test("deleting link does not affect other links with same tags", () async {
      // Create two links with same tag
      final result1 = await database.createLink(
        link: "https://link1.com",
        tags: [Metadata(value: "shared", type: MetadataTypeEnum.tag)],
      );

      final result2 = await database.createLink(
        link: "https://link2.com",
        tags: [Metadata(value: "shared", type: MetadataTypeEnum.tag)],
      );

      // Delete first link
      await database.removeLink(result1.linkId);

      // Verify second link still exists with its tag
      final link2Result = await database.getLink(
        linkId: result2.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(link2Result, isNotNull);
      expect(link2Result!.tags.length, equals(1));
      expect(link2Result.tags.first.name, equals("shared"));
    });
  });

  group("removeLinksBatch() - Batch Operations", () {
    test("delete multiple links at once", () async {
      // Create multiple links
      final result1 = await database.createLink(link: "https://link1.com");
      final result2 = await database.createLink(link: "https://link2.com");
      final result3 = await database.createLink(link: "https://link3.com");

      // Batch delete
      final deletedCount = await database
          .removeLinksBatch([result1.linkId, result2.linkId, result3.linkId]);

      expect(deletedCount, greaterThan(0));

      // Verify all links are deleted
      final allLinks = await database.getAllLinks();
      expect(allLinks, isEmpty);
    });

    test("batch delete with some non-existent links", () async {
      // Create one link
      final result = await database.createLink(link: "https://example.com");

      // Batch delete with mix of existing and non-existing IDs
      final deletedCount = await database.removeLinksBatch([
        result.linkId,
        "non_existent_1",
        "non_existent_2",
      ]);

      expect(deletedCount, greaterThan(0));

      // Verify link is deleted
      final linkResult = await database.getLink(linkId: result.linkId);
      expect(linkResult, isNull);
    });

    test("batch delete empty list returns zero", () async {
      final deletedCount = await database.removeLinksBatch([]);

      expect(deletedCount, equals(0));
    });

    test("batch delete removes all metadata records", () async {
      // Create links with tags
      final result1 = await database.createLink(
        link: "https://link1.com",
        tags: [Metadata(value: "tag1", type: MetadataTypeEnum.tag)],
      );
      final result2 = await database.createLink(
        link: "https://link2.com",
        tags: [Metadata(value: "tag2", type: MetadataTypeEnum.tag)],
      );

      // Verify metadata exists
      final metadataBefore =
          await database.select(database.metadataRecords).get();
      expect(metadataBefore.length, equals(2));

      // Batch delete links
      await database.removeLinksBatch([result1.linkId, result2.linkId]);

      // Verify metadata is deleted
      final metadataAfter =
          await database.select(database.metadataRecords).get();
      expect(metadataAfter, isEmpty);
    });

    test("batch delete handles duplicate IDs gracefully", () async {
      // Create link
      final result = await database.createLink(link: "https://example.com");

      // Batch delete with duplicate IDs
      final deletedCount = await database.removeLinksBatch([
        result.linkId,
        result.linkId,
        result.linkId,
      ]);

      expect(deletedCount, greaterThan(0));

      // Verify link is deleted only once
      final linkResult = await database.getLink(linkId: result.linkId);
      expect(linkResult, isNull);
    });
  });

  group("removeLink() - Transaction Safety", () {
    test("delete is atomic - all or nothing", () async {
      // Create link with tags
      final result = await database.createLink(
        link: "https://example.com",
        tags: [Metadata(value: "test", type: MetadataTypeEnum.tag)],
      );

      // Delete should be atomic
      final deleted = await database.removeLink(result.linkId);
      expect(deleted, isTrue);

      // Check all related data is deleted
      final linkExists = await (database.select(database.links)
            ..where((tbl) => tbl.id.equals(result.linkId)))
          .getSingleOrNull();
      expect(linkExists, isNull);

      final metadataExists = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.linkId)))
          .get();
      expect(metadataExists, isEmpty);

      final itemsExist = await (database.select(database.items)
            ..where((tbl) => tbl.itemId.equals(result.linkId)))
          .get();
      expect(itemsExist, isEmpty);
    });
  });

  group("removeLink() - Edge Cases", () {
    test("delete link with very long URL", () async {
      final longUrl = "https://example.com/${"a" * 2000}";
      final result = await database.createLink(link: longUrl);

      final deleted = await database.removeLink(result.linkId);

      expect(deleted, isTrue);

      final linkResult = await database.getLink(linkId: result.linkId);
      expect(linkResult, isNull);
    });

    test("delete multiple links leaving some intact", () async {
      // Create multiple links
      final result1 = await database.createLink(link: "https://delete1.com");
      final result2 = await database.createLink(link: "https://keep.com");
      final result3 = await database.createLink(link: "https://delete2.com");

      // Delete some links
      await database.removeLink(result1.linkId);
      await database.removeLink(result3.linkId);

      // Verify correct links are deleted/kept
      final allLinks = await database.getAllLinks();
      expect(allLinks.length, equals(1));
      expect(allLinks.first.data.id, equals(result2.linkId));
      expect(allLinks.first.data.path, equals("https://keep.com"));
    });

    test("delete link and verify tag cleanup is isolated", () async {
      // Create links with shared and unique tags
      final result1 = await database.createLink(
        link: "https://link1.com",
        tags: [
          Metadata(value: "shared", type: MetadataTypeEnum.tag),
          Metadata(value: "unique1", type: MetadataTypeEnum.tag),
        ],
      );

      final result2 = await database.createLink(
        link: "https://link2.com",
        tags: [
          Metadata(value: "shared", type: MetadataTypeEnum.tag),
          Metadata(value: "unique2", type: MetadataTypeEnum.tag),
        ],
      );

      // Get tag count before deletion
      final tagsBefore = await database.select(database.tags).get();
      expect(tagsBefore.length, equals(3)); // shared, unique1, unique2

      // Delete first link
      await database.removeLink(result1.linkId);

      // Tags should still exist (not auto-deleted)
      final tagsAfter = await database.select(database.tags).get();
      expect(tagsAfter.length, equals(3)); // Tags remain

      // But metadata records for link1 should be gone
      final metadataLink1 = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result1.linkId)))
          .get();
      expect(metadataLink1, isEmpty);

      // Metadata records for link2 should remain
      final metadataLink2 = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result2.linkId)))
          .get();
      expect(metadataLink2.length, equals(2));
    });
  });
}
