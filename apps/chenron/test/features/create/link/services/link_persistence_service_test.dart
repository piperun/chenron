import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";
import "package:chenron/features/create/link/models/link_entry.dart";
import "package:chenron/features/create/link/services/link_persistence_service.dart";
import "package:database/database.dart";

void main() {
  late MockDatabaseHelper mockDb;
  late LinkPersistenceService service;

  setUpAll(installTestLogger);

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup();
    service = LinkPersistenceService.withDeps(appDatabase: mockDb.database);
  });

  tearDown(() async {
    await mockDb.dispose();
  });

  // -------------------------------------------------------------------------
  // saveLinks
  // -------------------------------------------------------------------------
  group("saveLinks()", () {
    late String folderId;

    setUp(() async {
      folderId = await mockDb.createTestFolder(title: "Test Folder");
    });

    test("saves a single link to a folder", () async {
      final entries = [
        const LinkEntry(key: ValueKey("k1"), url: "https://example.com"),
      ];

      final count =
          await service.saveLinks(entries: entries, folderIds: [folderId]);
      expect(count, 1);

      final folder = await mockDb.getFolder(folderId);
      expect(folder, isNotNull);
      expect(
        folder!.items.whereType<LinkItem>().any((i) => i.url == "https://example.com"),
        isTrue,
      );
    });

    test("saves multiple links", () async {
      final entries = [
        const LinkEntry(key: ValueKey("k1"), url: "https://a.com"),
        const LinkEntry(key: ValueKey("k2"), url: "https://b.com"),
        const LinkEntry(key: ValueKey("k3"), url: "https://c.com"),
      ];

      final count =
          await service.saveLinks(entries: entries, folderIds: [folderId]);
      expect(count, 3);
    });

    test("saves links with tags", () async {
      final entries = [
        const LinkEntry(
          key: ValueKey("k1"),
          url: "https://tagged.com",
          tags: ["flutter", "dart"],
        ),
      ];

      final count =
          await service.saveLinks(entries: entries, folderIds: [folderId]);
      expect(count, 1);
    });

    test("saves to multiple folders", () async {
      final folderId2 =
          await mockDb.createTestFolder(title: "Second Folder");

      final entries = [
        const LinkEntry(key: ValueKey("k1"), url: "https://multi.com"),
      ];

      final count = await service.saveLinks(
        entries: entries,
        folderIds: [folderId, folderId2],
      );
      // One distinct link saved, shared by two folders — the count reports
      // links saved, not folder attachments (the snackbar reads "Saved N link(s)").
      expect(count, 1);
      // The same URL must never be stored as more than one link record.
      expect(await mockDb.countLinkRows("https://multi.com"), 1);

      final f1 = await mockDb.getFolder(folderId);
      final f2 = await mockDb.getFolder(folderId2);
      expect(
        f1!.items.whereType<LinkItem>().any((i) => i.url == "https://multi.com"),
        isTrue,
      );
      expect(
        f2!.items.whereType<LinkItem>().any((i) => i.url == "https://multi.com"),
        isTrue,
      );
    });

    test("does not duplicate tag relations across multiple folders", () async {
      final folderId2 =
          await mockDb.createTestFolder(title: "Second Folder");

      final entries = [
        const LinkEntry(
          key: ValueKey("k1"),
          url: "https://multitag.com",
          tags: ["flutter"],
        ),
      ];

      await service.saveLinks(
        entries: entries,
        folderIds: [folderId, folderId2],
      );

      // The link is shared by both folders, so its single "flutter" tag must
      // be recorded exactly once — not once per target folder.
      expect(await mockDb.countLinkTagRelations("https://multitag.com"), 1);
    });

    test("falls back to default folder when folderIds is empty", () async {
      // The database setup creates a default folder automatically
      final entries = [
        const LinkEntry(key: ValueKey("k1"), url: "https://default.com"),
      ];

      final count =
          await service.saveLinks(entries: entries, folderIds: []);
      // Should save to default folder (1 link × 1 folder)
      expect(count, 1);
    });

    test("returns zero when no entries", () async {
      final count =
          await service.saveLinks(entries: [], folderIds: [folderId]);
      expect(count, 0);
    });

    test("merges globalTags into the persisted tags for each entry", () async {
      // Globals are now applied at persist time; per-entry tags + globals
      // must end up tagged on the saved link, deduplicated.
      final entries = [
        const LinkEntry(
          key: ValueKey("k1"),
          url: "https://merged.com",
          tags: ["inline", "shared"],
        ),
      ];

      final count = await service.saveLinks(
        entries: entries,
        folderIds: [folderId],
        globalTags: const {"shared", "global"},
      );
      expect(count, 1);

      final folder = await mockDb.getFolder(folderId);
      final link = folder!.items
          .whereType<LinkItem>()
          .firstWhere((i) => i.url == "https://merged.com");
      final tagNames = link.tags.map((t) => t.name).toSet();
      expect(tagNames, containsAll(["inline", "shared", "global"]));
      // No duplicate "shared".
      expect(link.tags.where((t) => t.name == "shared").length, 1);
    });
  });
}
