import "package:chenron/locator.dart";
import "package:chenron/shared/viewer/item_tagging_service.dart";
import "package:database/database.dart";
import "package:database/main.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:signals/signals.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(
      queryExecutor: NativeDatabase.memory(),
      setupOnInit: true,
    );
    await database.setup();

    // Set up locator with a minimal AppDatabaseHandler that exposes our
    // test database.
    await locator.reset();
    locator.registerSingleton<Signal<AppDatabaseHandler>>(
      signal(_TestAppDatabaseHandler(database)),
    );
  });

  tearDown(() async {
    await locator.reset();
    await database.delete(database.links).go();
    await database.delete(database.documents).go();
    await database.delete(database.folders).go();
    await database.delete(database.metadataRecords).go();
    await database.delete(database.tags).go();
    await database.close();
  });

  group("TaggingResult", () {
    test("totalNew sums all per-tag counts", () {
      const result = TaggingResult(
        itemCount: 5,
        newCountPerTag: {"flutter": 3, "dart": 2},
      );
      expect(result.totalNew, equals(5));
    });

    test("totalNew is 0 when all items already had tags", () {
      const result = TaggingResult(
        itemCount: 3,
        newCountPerTag: {"flutter": 0, "dart": 0},
      );
      expect(result.totalNew, equals(0));
    });

    test("totalNew with single tag", () {
      const result = TaggingResult(
        itemCount: 4,
        newCountPerTag: {"mobile": 4},
      );
      expect(result.totalNew, equals(4));
    });
  });

  group("ItemTaggingService.addTagToItems()", () {
    test("adds single tag to single link", () async {
      final linkResult =
          await database.createLink(link: "https://example.com");

      final items = [
        FolderItem.link(
          id: linkResult.linkId,
          itemId: null,
          url: "https://example.com",
        ),
      ];

      final result =
          await ItemTaggingService().addTagToItems(items, ["flutter"]);

      expect(result.itemCount, equals(1));
      expect(result.newCountPerTag["flutter"], equals(1));

      // Verify in database
      final link = await database.getLink(
        linkId: linkResult.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      expect(link!.tags.length, equals(1));
      expect(link.tags.first.name, equals("flutter"));
    });

    test("adds multiple tags to single link", () async {
      final linkResult =
          await database.createLink(link: "https://example.com");

      final items = [
        FolderItem.link(
          id: linkResult.linkId,
          itemId: null,
          url: "https://example.com",
        ),
      ];

      final result = await ItemTaggingService()
          .addTagToItems(items, ["flutter", "dart", "mobile"]);

      expect(result.itemCount, equals(1));
      expect(result.totalNew, equals(3));

      final link = await database.getLink(
        linkId: linkResult.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      expect(link!.tags.length, equals(3));
      final tagNames = link.tags.map((t) => t.name).toSet();
      expect(tagNames, containsAll(["flutter", "dart", "mobile"]));
    });

    test("adds tags to multiple links", () async {
      final link1 =
          await database.createLink(link: "https://example.com/1");
      final link2 =
          await database.createLink(link: "https://example.com/2");
      final link3 =
          await database.createLink(link: "https://example.com/3");

      final items = [
        FolderItem.link(
            id: link1.linkId, itemId: null, url: "https://example.com/1"),
        FolderItem.link(
            id: link2.linkId, itemId: null, url: "https://example.com/2"),
        FolderItem.link(
            id: link3.linkId, itemId: null, url: "https://example.com/3"),
      ];

      final result =
          await ItemTaggingService().addTagToItems(items, ["shared"]);

      expect(result.itemCount, equals(3));
      expect(result.newCountPerTag["shared"], equals(3));

      // Verify each link has the tag
      for (final linkId in [link1.linkId, link2.linkId, link3.linkId]) {
        final link = await database.getLink(
          linkId: linkId,
          includeOptions: const IncludeOptions({AppDataInclude.tags}),
        );
        expect(link!.tags.length, equals(1));
        expect(link.tags.first.name, equals("shared"));
      }
    });

    test("handles duplicate tags idempotently", () async {
      // Create link with existing tag
      final linkResult = await database.createLink(
        link: "https://example.com",
        tags: [Metadata(value: "existing", type: MetadataTypeEnum.tag)],
      );

      final items = [
        FolderItem.link(
          id: linkResult.linkId,
          itemId: null,
          url: "https://example.com",
        ),
      ];

      // Add the same tag again
      final result =
          await ItemTaggingService().addTagToItems(items, ["existing"]);

      expect(result.itemCount, equals(1));
      // No new tags were added (duplicate)
      expect(result.newCountPerTag["existing"], equals(0));

      // Verify still only one tag
      final link = await database.getLink(
        linkId: linkResult.linkId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      expect(link!.tags.length, equals(1));
    });

    test("mixed: some items already have tag, some don't", () async {
      // Link 1 already has "flutter"
      final link1 = await database.createLink(
        link: "https://example.com/1",
        tags: [Metadata(value: "flutter", type: MetadataTypeEnum.tag)],
      );
      // Link 2 does not have "flutter"
      final link2 =
          await database.createLink(link: "https://example.com/2");

      final items = [
        FolderItem.link(
            id: link1.linkId, itemId: null, url: "https://example.com/1"),
        FolderItem.link(
            id: link2.linkId, itemId: null, url: "https://example.com/2"),
      ];

      final result =
          await ItemTaggingService().addTagToItems(items, ["flutter"]);

      expect(result.itemCount, equals(2));
      // Only link2 got it newly (link1 already had it)
      // Conservative: newCountPerTag counts 0 for link1 (already had it)
      // and 1 for link2 (new). But our counting is conservative—
      // it only counts when ALL tags were new for an item.
      expect(result.newCountPerTag["flutter"], equals(1));

      // Verify both links now have the tag
      for (final linkId in [link1.linkId, link2.linkId]) {
        final link = await database.getLink(
          linkId: linkId,
          includeOptions: const IncludeOptions({AppDataInclude.tags}),
        );
        expect(link!.tags.map((t) => t.name), contains("flutter"));
      }
    });

    test("adds tags to documents", () async {
      final docResult = await database.createDocument(
        title: "Test Doc",
        filePath: "/path/to/doc.md",
        fileType: DocumentFileType.markdown,
      );

      final items = [
        FolderItem.document(
          id: docResult.documentId,
          itemId: null,
          title: "Test Doc",
          filePath: "/path/to/doc.md",
        ),
      ];

      final result =
          await ItemTaggingService().addTagToItems(items, ["notes"]);

      expect(result.itemCount, equals(1));
      expect(result.newCountPerTag["notes"], equals(1));

      final doc = await database.getDocument(
        documentId: docResult.documentId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      expect(doc!.tags!.length, equals(1));
      expect(doc.tags!.first.name, equals("notes"));
    });

    test("adds tags to folders", () async {
      final folderResult = await database.createFolder(
        folderInfo: FolderDraft(title: "Test Folder", description: ""),
      );

      final items = [
        FolderItem.folder(
          id: folderResult.folderId,
          itemId: null,
          folderId: folderResult.folderId,
          title: "Test Folder",
        ),
      ];

      final result =
          await ItemTaggingService().addTagToItems(items, ["archive"]);

      expect(result.itemCount, equals(1));
      expect(result.newCountPerTag["archive"], equals(1));

      final folder = await database.getFolder(
        folderId: folderResult.folderId,
        includeOptions: const IncludeOptions({AppDataInclude.tags}),
      );
      expect(folder!.tags.length, equals(1));
      expect(folder.tags.first.name, equals("archive"));
    });

    test("adds tags to mixed item types", () async {
      final linkResult =
          await database.createLink(link: "https://example.com");
      final docResult = await database.createDocument(
        title: "Test Doc",
        filePath: "/path/to/doc.md",
        fileType: DocumentFileType.markdown,
      );
      final folderResult = await database.createFolder(
        folderInfo: FolderDraft(title: "Test Folder", description: ""),
      );

      final items = [
        FolderItem.link(
            id: linkResult.linkId,
            itemId: null,
            url: "https://example.com"),
        FolderItem.document(
            id: docResult.documentId,
            itemId: null,
            title: "Test Doc",
            filePath: "/path/to/doc.md"),
        FolderItem.folder(
            id: folderResult.folderId,
            itemId: null,
            folderId: folderResult.folderId,
            title: "Test Folder"),
      ];

      final result =
          await ItemTaggingService().addTagToItems(items, ["common"]);

      expect(result.itemCount, equals(3));
      expect(result.newCountPerTag["common"], equals(3));
    });

    test("skips items with null id", () async {
      final items = [
        const FolderItem.link(
            url: "https://example.com"),
      ];

      final result =
          await ItemTaggingService().addTagToItems(items, ["test"]);

      expect(result.itemCount, equals(0));
    });

    test("handles empty items list", () async {
      final result =
          await ItemTaggingService().addTagToItems([], ["flutter"]);

      expect(result.itemCount, equals(0));
      expect(result.totalNew, equals(0));
    });

    test("tag is shared across items via same tag row", () async {
      final link1 =
          await database.createLink(link: "https://example.com/1");
      final link2 =
          await database.createLink(link: "https://example.com/2");

      final items = [
        FolderItem.link(
            id: link1.linkId, itemId: null, url: "https://example.com/1"),
        FolderItem.link(
            id: link2.linkId, itemId: null, url: "https://example.com/2"),
      ];

      await ItemTaggingService().addTagToItems(items, ["shared"]);

      // Both should reference the same tag
      final allTags = await database.getAllTags();
      final sharedTags =
          allTags.where((t) => t.name == "shared").toList();
      expect(sharedTags.length, equals(1));
    });
  });
}

/// Minimal stub that wraps a test [AppDatabase] for the locator.
class _TestAppDatabaseHandler extends AppDatabaseHandler {
  final AppDatabase _testDb;

  _TestAppDatabaseHandler(this._testDb);

  @override
  AppDatabase get appDatabase => _testDb;
}
