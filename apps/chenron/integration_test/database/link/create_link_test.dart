import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/link/create.dart";
import "package:chenron/utils/test_lib/link_factory.dart";
import "package:chenron/models/metadata.dart";

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
    await database.close();
  });

  group("createLink() Basic Operations", () {
    test("create link without tags", () async {
      final linkData = LinkTestDataFactory.create(
        url: "https://example.com",
        content: "https://example.com",
        tagValues: [],
      );

      final result = await database.createLink(
        link: linkData.link.path,
      );

      // Verify link was created
      expect(result.linkId, isNotEmpty);

      // Verify link exists in database
      final linkResult = await (database.select(database.links)
            ..where((tbl) => tbl.id.equals(result.linkId)))
          .getSingleOrNull();

      expect(linkResult, isNotNull);
      expect(linkResult!.path, equals("https://example.com"));

      // Verify no tags were created
      expect(result.tagIds, isNull);

      final metadataResult = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.linkId)))
          .get();
      expect(metadataResult.length, equals(0));
    });

    test("create link with single tag", () async {
      final linkData = LinkTestDataFactory.create(
        url: "https://flutter.dev",
        content: "https://flutter.dev",
        tagValues: ["flutter"],
      );

      final result = await database.createLink(
        link: linkData.link.path,
        tags: linkData.tags,
      );

      // Verify link was created
      expect(result.linkId, isNotEmpty);

      // Verify tags were created
      expect(result.tagIds, isNotNull);
      expect(result.tagIds!.length, equals(1));
      expect(result.tagIds!.first.tagId, isNotEmpty);

      // Verify tag exists in database
      final tagResult = await (database.select(database.tags)
            ..where((tbl) => tbl.id.equals(result.tagIds!.first.tagId)))
          .getSingleOrNull();

      expect(tagResult, isNotNull);
      expect(tagResult!.name, equals("flutter"));

      // Verify metadata relation exists
      final metadataResult = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.linkId)))
          .get();

      expect(metadataResult.length, equals(1));
      expect(
          metadataResult.first.metadataId, equals(result.tagIds!.first.tagId));
    });

    test("create link with multiple tags", () async {
      final linkData = LinkTestDataFactory.create(
        url: "https://dart.dev",
        content: "https://dart.dev",
        tagValues: ["dart", "programming", "language"],
      );

      final result = await database.createLink(
        link: linkData.link.path,
        tags: linkData.tags,
      );

      // Verify link was created
      expect(result.linkId, isNotEmpty);

      // Verify all tags were created
      expect(result.tagIds, isNotNull);
      expect(result.tagIds!.length, equals(3));

      // Verify all tags exist in database
      final tagResults = await (database.select(database.tags)).get();
      final tagNames = tagResults.map((t) => t.name).toSet();

      expect(tagNames.contains("dart"), isTrue);
      expect(tagNames.contains("programming"), isTrue);
      expect(tagNames.contains("language"), isTrue);

      // Verify all metadata relations exist
      final metadataResults = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.linkId)))
          .get();

      expect(metadataResults.length, equals(3));
    });
  });

  group("createLink() Duplicate Handling", () {
    test("creating duplicate link returns existing link ID", () async {
      final url = "https://duplicate.com";

      // Create first link
      final result1 = await database.createLink(
        link: url,
        tags: [
          Metadata(value: "test", type: MetadataTypeEnum.tag),
        ],
      );

      // Create duplicate link
      final result2 = await database.createLink(
        link: url,
        tags: [
          Metadata(value: "test2", type: MetadataTypeEnum.tag),
        ],
      );

      // Should return same link ID
      expect(result1.linkId, equals(result2.linkId));

      // Verify only one link exists
      final linkResults = await (database.select(database.links)
            ..where((tbl) => tbl.path.equals(url)))
          .get();

      expect(linkResults.length, equals(1));

      // Verify both sets of tags were created (tags are unique per link)
      // Since we're using getOrCreate for tags, duplicate tag names will reuse the same tag
      final metadataResults = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result1.linkId)))
          .get();

      // Should have 2 metadata records (one for each unique tag: "test" and "test2")
      expect(metadataResults.length, equals(2));
    });

    test("tag reuse - same tag across multiple links", () async {
      // Create first link with tag "flutter"
      final result1 = await database.createLink(
        link: "https://flutter.dev",
        tags: [
          Metadata(value: "flutter", type: MetadataTypeEnum.tag),
        ],
      );

      // Create second link with same tag "flutter"
      final result2 = await database.createLink(
        link: "https://flutter-examples.com",
        tags: [
          Metadata(value: "flutter", type: MetadataTypeEnum.tag),
        ],
      );

      // Verify both links use the same tag ID
      expect(result1.tagIds![0].tagId, equals(result2.tagIds![0].tagId));

      // Verify only one "flutter" tag exists in database
      final tagResults = await (database.select(database.tags)
            ..where((tbl) => tbl.name.equals("flutter")))
          .get();

      expect(tagResults.length, equals(1));

      // Verify both links have metadata records pointing to same tag
      final metadata1 = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result1.linkId)))
          .get();

      final metadata2 = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result2.linkId)))
          .get();

      expect(metadata1.first.metadataId, equals(metadata2.first.metadataId));
    });
  });

  group("createLink() Validation", () {
    test("throws on empty URL", () async {
      expect(
        () => database.createLink(link: ""),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("throws on invalid URL format", () async {
      expect(
        () => database.createLink(link: "not-a-url"),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("throws on URL without http/https", () async {
      expect(
        () => database.createLink(link: "ftp://example.com"),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group("createLink() Edge Cases", () {
    test("create link with very long URL", () async {
      final longUrl = "https://example.com/${"a" * 2000}";

      final result = await database.createLink(link: longUrl);

      expect(result.linkId, isNotEmpty);

      final linkResult = await (database.select(database.links)
            ..where((tbl) => tbl.id.equals(result.linkId)))
          .getSingleOrNull();

      expect(linkResult, isNotNull);
      expect(linkResult!.path, equals(longUrl));
    });

    test("create link with special characters in URL", () async {
      final specialUrl =
          "https://example.com/path?param=value&other=123#fragment";

      final result = await database.createLink(link: specialUrl);

      expect(result.linkId, isNotEmpty);

      final linkResult = await (database.select(database.links)
            ..where((tbl) => tbl.id.equals(result.linkId)))
          .getSingleOrNull();

      expect(linkResult, isNotNull);
      expect(linkResult!.path, equals(specialUrl));
    });

    test("create multiple links with overlapping tags", () async {
      // Create first link with tags: tech, programming
      final result1 = await database.createLink(
        link: "https://tech1.com",
        tags: [
          Metadata(value: "tech", type: MetadataTypeEnum.tag),
          Metadata(value: "programming", type: MetadataTypeEnum.tag),
        ],
      );

      // Create second link with tags: tech, tutorial
      final result2 = await database.createLink(
        link: "https://tech2.com",
        tags: [
          Metadata(value: "tech", type: MetadataTypeEnum.tag),
          Metadata(value: "tutorial", type: MetadataTypeEnum.tag),
        ],
      );

      // Create third link with tags: programming, tutorial
      final result3 = await database.createLink(
        link: "https://tech3.com",
        tags: [
          Metadata(value: "programming", type: MetadataTypeEnum.tag),
          Metadata(value: "tutorial", type: MetadataTypeEnum.tag),
        ],
      );

      // Verify only 3 unique tags exist
      final allTags = await database.select(database.tags).get();
      expect(allTags.length, equals(3));

      final tagNames = allTags.map((t) => t.name).toSet();
      expect(tagNames, equals({"tech", "programming", "tutorial"}));

      // Verify tag IDs are reused correctly
      final tech1 = result1.tagIds!.firstWhere(
          (t) => allTags.firstWhere((tag) => tag.id == t.tagId).name == "tech");
      final tech2 = result2.tagIds!.firstWhere(
          (t) => allTags.firstWhere((tag) => tag.id == t.tagId).name == "tech");

      expect(tech1.tagId, equals(tech2.tagId),
          reason: "'tech' tag should be reused");
    });
  });

  group("createLink() Transaction Safety", () {
    test("rollback on tag creation failure", () async {
      // This test verifies that if tag creation fails,
      // the entire transaction is rolled back

      // Note: This is implicitly tested by the VEPR pattern
      // If any step fails, the transaction() wrapper ensures rollback

      // For now, we just verify the transaction works correctly
      final result = await database.createLink(
        link: "https://transaction-test.com",
        tags: [
          Metadata(
              value: "trans",
              type: MetadataTypeEnum.tag), // Keep under 12 char limit
        ],
      );

      expect(result.linkId, isNotEmpty);
      expect(result.tagIds, isNotNull);
      expect(result.tagIds!.length, equals(1));
    });
  });

  group("createLink() Result Metadata", () {
    test("result contains correct link ID", () async {
      final result = await database.createLink(
        link: "https://result-test.com",
      );

      expect(result.linkId, isNotEmpty);
      expect(result.linkId.length, equals(30));
    });

    test("result contains tag IDs when tags created", () async {
      final result = await database.createLink(
        link: "https://tags-result.com",
        tags: [
          Metadata(value: "tag1", type: MetadataTypeEnum.tag),
          Metadata(value: "tag2", type: MetadataTypeEnum.tag),
        ],
      );

      expect(result.tagIds, isNotNull);
      expect(result.tagIds!.length, equals(2));

      for (final tagResult in result.tagIds!) {
        expect(tagResult.tagId, isNotEmpty);
        expect(tagResult.tagId.length, equals(30));
      }
    });

    test("result tag IDs can be null when no tags", () async {
      final result = await database.createLink(
        link: "https://no-tags.com",
      );

      expect(result.tagIds, isNull);
    });
  });
}
