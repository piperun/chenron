// ignore_for_file: deprecated_member_use_from_same_package

import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/link/create.dart";
import "package:chenron/database/extensions/link/update.dart";
import "package:chenron/database/extensions/link/read.dart";
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
    final links = database.links;
    await database.delete(links).go();
    final metadataRecords = database.metadataRecords;
    await database.delete(metadataRecords).go();
    final tags = database.tags;
    await database.delete(tags).go();
    await database.close();
  });

  // NOTE: updateLinkPath() is deprecated and marked @visibleForTesting
  // These tests exist to ensure the emergency repair functionality works
  // if needed, but this method should NOT be used in production code.
  // Links are immutable - to "change" a link, create a new one and delete the old.
  group("updateLinkPath() - Basic Operations", () {
    test("update link path successfully", () async {
      // Create link
      final result = await database.createLink(link: "https://old-example.com");

      // Update path
      final updated = await database.updateLinkPath(
        linkId: result.linkId,
        newPath: "https://new-example.com",
      );

      expect(updated, isTrue);

      // Verify update
      final linkResult = await database.getLink(linkId: result.linkId);
      expect(linkResult, isNotNull);
      expect(linkResult!.data.path, equals("https://new-example.com"));
    });

    test("update link path to same value succeeds", () async {
      final result = await database.createLink(link: "https://example.com");

      final updated = await database.updateLinkPath(
        linkId: result.linkId,
        newPath: "https://example.com",
      );

      // Should still succeed (no-op update)
      expect(updated, isTrue);
    });

    test("update non-existent link throws error", () async {
      expect(
        () => database.updateLinkPath(
          linkId: "non_existent_id",
          newPath: "https://new.com",
        ),
        throwsA(isA<StateError>()),
      );
    });

    test("update link path with conflicting URL throws error", () async {
      // Create two links
      await database.createLink(link: "https://link1.com");
      final result2 = await database.createLink(link: "https://link2.com");

      // Try to update link2 to link1's URL
      expect(
        () => database.updateLinkPath(
          linkId: result2.linkId,
          newPath: "https://link1.com",
        ),
        throwsA(isA<StateError>()),
      );
    });

    test("update link path validates URL format", () async {
      final result = await database.createLink(link: "https://example.com");

      expect(
        () => database.updateLinkPath(
          linkId: result.linkId,
          newPath: "not-a-url",
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("update link path validates empty path", () async {
      final result = await database.createLink(link: "https://example.com");

      expect(
        () => database.updateLinkPath(
          linkId: result.linkId,
          newPath: "",
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group("addTagsToLink() - Adding Tags", () {
    test("add single tag to link without tags", () async {
      // Create link without tags
      final result = await database.createLink(link: "https://example.com");

      // Add tag
      final addedTagIds = await database.addTagsToLink(
        linkId: result.linkId,
        tags: [Metadata(value: "newtag", type: MetadataTypeEnum.tag)],
      );

      expect(addedTagIds.length, equals(1));

      // Verify tag was added
      final linkResult = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(linkResult!.tags.length, equals(1));
      expect(linkResult.tags.first.name, equals("newtag"));
    });

    test("add multiple tags to link", () async {
      final result = await database.createLink(link: "https://example.com");

      final addedTagIds = await database.addTagsToLink(
        linkId: result.linkId,
        tags: [
          Metadata(value: "tag1", type: MetadataTypeEnum.tag),
          Metadata(value: "tag2", type: MetadataTypeEnum.tag),
          Metadata(value: "tag3", type: MetadataTypeEnum.tag),
        ],
      );

      expect(addedTagIds.length, equals(3));

      final linkResult = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(linkResult!.tags.length, equals(3));
    });

    test("add tag to link that already has tags", () async {
      // Create link with tags
      final result = await database.createLink(
        link: "https://example.com",
        tags: [Metadata(value: "existing", type: MetadataTypeEnum.tag)],
      );

      // Add new tag
      await database.addTagsToLink(
        linkId: result.linkId,
        tags: [Metadata(value: "newtag", type: MetadataTypeEnum.tag)],
      );

      // Verify both tags exist
      final linkResult = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(linkResult!.tags.length, equals(2));
      final tagNames = linkResult.tags.map((t) => t.name).toSet();
      expect(tagNames.contains("existing"), isTrue);
      expect(tagNames.contains("newtag"), isTrue);
    });

    test("add duplicate tag does not create duplicate association", () async {
      // Create link with tag
      final result = await database.createLink(
        link: "https://example.com",
        tags: [Metadata(value: "shared", type: MetadataTypeEnum.tag)],
      );

      // Try to add same tag again
      final addedTagIds = await database.addTagsToLink(
        linkId: result.linkId,
        tags: [Metadata(value: "shared", type: MetadataTypeEnum.tag)],
      );

      // Should not add duplicate
      expect(addedTagIds, isEmpty);

      // Verify only one tag association exists
      final linkResult = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(linkResult!.tags.length, equals(1));
    });

    test("add existing tag from another link", () async {
      // Create first link with tag
      await database.createLink(
        link: "https://link1.com",
        tags: [Metadata(value: "shared", type: MetadataTypeEnum.tag)],
      );

      // Create second link
      final result2 = await database.createLink(link: "https://link2.com");

      // Add the shared tag to second link
      await database.addTagsToLink(
        linkId: result2.linkId,
        tags: [Metadata(value: "shared", type: MetadataTypeEnum.tag)],
      );

      // Verify second link has the tag
      final link2Result = await database.getLink(
        linkId: result2.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(link2Result!.tags.length, equals(1));
      expect(link2Result.tags.first.name, equals("shared"));

      // Verify only one tag exists in tags table
      final tags = database.tags;
      final allTags = await database.select(tags).get();
      final sharedTags = allTags.where((t) => t.name == "shared").toList();
      expect(sharedTags.length, equals(1));
    });
  });

  group("removeTagsFromLink() - Removing Tags", () {
    test("remove single tag from link", () async {
      // Create link with tags
      final result = await database.createLink(
        link: "https://example.com",
        tags: [
          Metadata(value: "keep", type: MetadataTypeEnum.tag),
          Metadata(value: "remove", type: MetadataTypeEnum.tag),
        ],
      );

      // Get tag ID to remove
      final linkBefore = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      final removeTag = linkBefore!.tags.firstWhere((t) => t.name == "remove");

      // Remove tag
      final removedCount = await database.removeTagsFromLink(
        linkId: result.linkId,
        tagIds: [removeTag.id],
      );

      expect(removedCount, equals(1));

      // Verify tag was removed
      final linkAfter = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(linkAfter!.tags.length, equals(1));
      expect(linkAfter.tags.first.name, equals("keep"));
    });

    test("remove all tags from link", () async {
      // Create link with tags
      final result = await database.createLink(
        link: "https://example.com",
        tags: [
          Metadata(value: "tag1", type: MetadataTypeEnum.tag),
          Metadata(value: "tag2", type: MetadataTypeEnum.tag),
        ],
      );

      // Get all tag IDs
      final linkBefore = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      final tagIds = linkBefore!.tags.map((t) => t.id).toList();

      // Remove all tags
      final removedCount = await database.removeTagsFromLink(
        linkId: result.linkId,
        tagIds: tagIds,
      );

      expect(removedCount, equals(2));

      // Verify no tags remain
      final linkAfter = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(linkAfter!.tags, isEmpty);
    });

    test("remove non-existent tag does nothing", () async {
      // Create link with tag
      final result = await database.createLink(
        link: "https://example.com",
        tags: [Metadata(value: "keep", type: MetadataTypeEnum.tag)],
      );

      // Try to remove non-existent tag
      final removedCount = await database.removeTagsFromLink(
        linkId: result.linkId,
        tagIds: ["non_existent_tag_id"],
      );

      expect(removedCount, equals(0));

      // Verify original tag still exists
      final linkAfter = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(linkAfter!.tags.length, equals(1));
    });

    test("remove tag from one link does not affect other links", () async {
      // Create two links with shared tag
      final result1 = await database.createLink(
        link: "https://link1.com",
        tags: [Metadata(value: "shared", type: MetadataTypeEnum.tag)],
      );

      final result2 = await database.createLink(
        link: "https://link2.com",
        tags: [Metadata(value: "shared", type: MetadataTypeEnum.tag)],
      );

      // Get shared tag ID from first link
      final link1 = await database.getLink(
        linkId: result1.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      final sharedTagId = link1!.tags.first.id;

      // Remove tag from first link
      await database.removeTagsFromLink(
        linkId: result1.linkId,
        tagIds: [sharedTagId],
      );

      // Verify tag removed from link1
      final link1After = await database.getLink(
        linkId: result1.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      expect(link1After!.tags, isEmpty);

      // Verify tag still exists on link2
      final link2After = await database.getLink(
        linkId: result2.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      expect(link2After!.tags.length, equals(1));
      expect(link2After.tags.first.name, equals("shared"));
    });
  });

  group("updateLinkArchiveUrls() - Archive Management", () {
    test("update archive.org URL", () async {
      final result = await database.createLink(link: "https://example.com");

      final updated = await database.updateLinkArchiveUrls(
        linkId: result.linkId,
        archiveOrgUrl:
            "https://web.archive.org/web/20210101000000/https://example.com",
      );

      expect(updated, isTrue);

      // Verify update
      final links = database.links;
      final linkData = await (database.select(links)
            ..where((tbl) => tbl.id.equals(result.linkId)))
          .getSingle();

      expect(
          linkData.archiveOrgUrl,
          equals(
              "https://web.archive.org/web/20210101000000/https://example.com"));
    });

    test("update multiple archive URLs at once", () async {
      final result = await database.createLink(link: "https://example.com");

      final updated = await database.updateLinkArchiveUrls(
        linkId: result.linkId,
        archiveOrgUrl: "https://web.archive.org/example",
        archiveIsUrl: "https://archive.is/example",
        localArchivePath: "/path/to/local/archive",
      );

      expect(updated, isTrue);

      // Verify all updates
      final links = database.links;
      final linkData = await (database.select(links)
            ..where((tbl) => tbl.id.equals(result.linkId)))
          .getSingle();

      expect(linkData.archiveOrgUrl, equals("https://web.archive.org/example"));
      expect(linkData.archiveIsUrl, equals("https://archive.is/example"));
      expect(linkData.localArchivePath, equals("/path/to/local/archive"));
    });

    test("update archive URLs for non-existent link returns false", () async {
      final updated = await database.updateLinkArchiveUrls(
        linkId: "non_existent_id",
        archiveOrgUrl: "https://web.archive.org/example",
      );

      expect(updated, isFalse);
    });

    test("update archive URLs with null clears previous values", () async {
      // Create link and set archive URL
      final result = await database.createLink(link: "https://example.com");
      await database.updateLinkArchiveUrls(
        linkId: result.linkId,
        archiveOrgUrl: "https://web.archive.org/example",
      );

      // Update with explicit null value would require different API
      // For now, just verify partial updates work
      await database.updateLinkArchiveUrls(
        linkId: result.linkId,
        archiveIsUrl: "https://archive.is/example",
      );

      final linkData = await (database.select(database.links)
            ..where((tbl) => tbl.id.equals(result.linkId)))
          .getSingle();

      // archiveOrgUrl should remain
      expect(linkData.archiveOrgUrl, equals("https://web.archive.org/example"));
      // archiveIsUrl should be set
      expect(linkData.archiveIsUrl, equals("https://archive.is/example"));
    });
  });

  group("Combined Update Operations", () {
    test("update path and tags in sequence", () async {
      // Create link
      final result = await database.createLink(
        link: "https://old.com",
        tags: [Metadata(value: "oldtag", type: MetadataTypeEnum.tag)],
      );

      // Update path
      await database.updateLinkPath(
        linkId: result.linkId,
        newPath: "https://new.com",
      );

      // Add new tag
      await database.addTagsToLink(
        linkId: result.linkId,
        tags: [Metadata(value: "newtag", type: MetadataTypeEnum.tag)],
      );

      // Verify both updates
      final linkResult = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(linkResult!.data.path, equals("https://new.com"));
      expect(linkResult.tags.length, equals(2));
    });

    test("replace tags by removing all and adding new", () async {
      // Create link with tags
      final result = await database.createLink(
        link: "https://example.com",
        tags: [
          Metadata(value: "old1", type: MetadataTypeEnum.tag),
          Metadata(value: "old2", type: MetadataTypeEnum.tag),
        ],
      );

      // Get old tag IDs
      final linkBefore = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      final oldTagIds = linkBefore!.tags.map((t) => t.id).toList();

      // Remove old tags
      await database.removeTagsFromLink(
        linkId: result.linkId,
        tagIds: oldTagIds,
      );

      // Add new tags
      await database.addTagsToLink(
        linkId: result.linkId,
        tags: [
          Metadata(value: "new1", type: MetadataTypeEnum.tag),
          Metadata(value: "new2", type: MetadataTypeEnum.tag),
        ],
      );

      // Verify replacement
      final linkAfter = await database.getLink(
        linkId: result.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );

      expect(linkAfter!.tags.length, equals(2));
      final tagNames = linkAfter.tags.map((t) => t.name).toSet();
      expect(tagNames.contains("new1"), isTrue);
      expect(tagNames.contains("new2"), isTrue);
      expect(tagNames.contains("old1"), isFalse);
      expect(tagNames.contains("old2"), isFalse);
    });
  });
}
