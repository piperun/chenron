import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:chenron/features/settings/service/bookmark_export_service.dart";

void main() {
  late MockDatabaseHelper mockDb;
  late BookmarkExportService service;
  late Directory tempDir;

  setUpAll(installTestLogger);

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup();
    service = BookmarkExportService.withDeps(appDatabase: mockDb.database);
    tempDir = await Directory.systemTemp.createTemp("bookmark_export_test");
  });

  tearDown(() async {
    await mockDb.dispose();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  // -------------------------------------------------------------------------
  // exportBookmarks
  // -------------------------------------------------------------------------
  group("exportBookmarks()", () {
    test("exports empty database as valid Netscape HTML", () async {
      final file = File("${tempDir.path}/bookmarks.html");
      await service.exportBookmarks(file);

      expect(file.existsSync(), isTrue);
      final content = await file.readAsString();
      expect(content, contains("<!DOCTYPE NETSCAPE-Bookmark-file-1>"));
      expect(content, contains("<TITLE>Bookmarks</TITLE>"));
      expect(content, contains("<H1>Bookmarks</H1>"));
    });

    test("exports folder with links", () async {
      final folderId =
          await mockDb.createTestFolder(title: "My Bookmarks");
      await mockDb.database.createLink(link: "https://flutter.dev");

      // Add link to folder
      final allLinks = await mockDb.database.getAllLinks();
      final linkId = allLinks.first.data.id;
      await mockDb.database.updateFolder(
        folderId,
        itemUpdates: CUD(
          update: [
            FolderItem.link(id: null, itemId: linkId, url: "https://flutter.dev"),
          ],
        ),
      );

      final file = File("${tempDir.path}/bookmarks.html");
      await service.exportBookmarks(file);

      final content = await file.readAsString();
      expect(content, contains("My Bookmarks"));
      expect(content, contains("https://flutter.dev"));
    });

    test("exports orphan links (not in any folder)", () async {
      await mockDb.database.createLink(link: "https://orphan.dev");

      final file = File("${tempDir.path}/bookmarks.html");
      await service.exportBookmarks(file);

      final content = await file.readAsString();
      expect(content, contains("https://orphan.dev"));
    });

    test("exports folder tags", () async {
      await mockDb.createTestFolder(
        title: "Tagged Folder",
        tags: ["flutter", "dart"],
      );

      final file = File("${tempDir.path}/bookmarks.html");
      await service.exportBookmarks(file);

      final content = await file.readAsString();
      expect(content, contains("Tagged Folder"));
      expect(content, contains("TAGS="));
      expect(content, contains("flutter"));
    });

    test("exports nested folders", () async {
      final parentId =
          await mockDb.createTestFolder(title: "Parent Folder");
      final childId =
          await mockDb.createTestFolder(title: "Child Folder");

      await mockDb.database.updateFolder(
        parentId,
        itemUpdates: CUD(
          update: [
            FolderItem.folder(
              id: null,
              itemId: childId,
              folderId: childId,
              title: "Child Folder",
            ),
          ],
        ),
      );

      final file = File("${tempDir.path}/bookmarks.html");
      await service.exportBookmarks(file);

      final content = await file.readAsString();
      expect(content, contains("Parent Folder"));
      expect(content, contains("Child Folder"));
    });

    test("escapes HTML special characters", () async {
      // Title max is 30 chars — keep it short
      await mockDb.createTestFolder(title: 'A <b> & "c" folder');

      final file = File("${tempDir.path}/bookmarks.html");
      await service.exportBookmarks(file);

      final content = await file.readAsString();
      expect(content, contains("&lt;b&gt;"));
      expect(content, contains("&amp;"));
      expect(content, contains("&quot;c&quot;"));
    });

    test("returns the destination file", () async {
      final file = File("${tempDir.path}/bookmarks.html");
      final result = await service.exportBookmarks(file);
      expect(result.path, file.path);
    });
  });
}
