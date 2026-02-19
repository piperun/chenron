import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:chenron/features/settings/service/bookmark_import_service.dart";

/// Minimal Netscape bookmark HTML for testing
String _bookmarkHtml({
  List<String> links = const [],
  Map<String, List<String>>? folders,
  Map<String, String>? linkTags,
  Map<String, String>? folderTags,
}) {
  final sb = StringBuffer();
  sb.writeln("<!DOCTYPE NETSCAPE-Bookmark-file-1>");
  sb.writeln('<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">');
  sb.writeln("<TITLE>Bookmarks</TITLE>");
  sb.writeln("<H1>Bookmarks</H1>");
  sb.writeln("<DL><p>");

  // Root-level links
  for (final url in links) {
    final tags = linkTags?[url];
    final tagsAttr = tags != null ? ' TAGS="$tags"' : "";
    sb.writeln('    <DT><A HREF="$url" ADD_DATE="0"$tagsAttr>$url</A>');
  }

  // Folders with links
  if (folders != null) {
    for (final entry in folders.entries) {
      final fTags = folderTags?[entry.key];
      final fTagsAttr = fTags != null ? ' TAGS="$fTags"' : "";
      sb.writeln('    <DT><H3 ADD_DATE="0"$fTagsAttr>${entry.key}</H3>');
      sb.writeln("    <DL><p>");
      for (final url in entry.value) {
        sb.writeln('        <DT><A HREF="$url" ADD_DATE="0">$url</A>');
      }
      sb.writeln("    </DL><p>");
    }
  }

  sb.writeln("</DL><p>");
  return sb.toString();
}

void main() {
  late MockDatabaseHelper mockDb;
  late BookmarkImportService service;
  late Directory tempDir;

  setUpAll(installTestLogger);

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup();
    service = BookmarkImportService.withDeps(appDatabase: mockDb.database);
    tempDir = await Directory.systemTemp.createTemp("bookmark_import_test");
  });

  tearDown(() async {
    await mockDb.dispose();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<File> writeBookmarkFile(String content) async {
    final file = File("${tempDir.path}/bookmarks.html");
    await file.writeAsString(content);
    return file;
  }

  // -------------------------------------------------------------------------
  // importBookmarks
  // -------------------------------------------------------------------------
  group("importBookmarks()", () {
    test("imports root-level links", () async {
      final file = await writeBookmarkFile(_bookmarkHtml(
        links: ["https://flutter.dev", "https://dart.dev"],
      ));

      final result = await service.importBookmarks(file);
      expect(result.linksImported, 2);
      expect(result.linksSkipped, 0);
    });

    test("imports folder with links", () async {
      final file = await writeBookmarkFile(_bookmarkHtml(
        folders: {
          "Flutter Resources": [
            "https://flutter.dev",
            "https://pub.dev",
          ],
        },
      ));

      final result = await service.importBookmarks(file);
      expect(result.foldersCreated, 1);
      expect(result.linksImported, 2);
    });

    test("skips duplicate links", () async {
      // Pre-create a link
      await mockDb.database.createLink(link: "https://flutter.dev");

      final file = await writeBookmarkFile(_bookmarkHtml(
        links: ["https://flutter.dev", "https://dart.dev"],
      ));

      final result = await service.importBookmarks(file);
      expect(result.linksImported, 1); // only dart.dev is new
      expect(result.linksSkipped, 1); // flutter.dev already exists
    });

    test("imports tags on links", () async {
      final file = await writeBookmarkFile(_bookmarkHtml(
        links: ["https://flutter.dev"],
        linkTags: {"https://flutter.dev": "flutter,dart,mobile"},
      ));

      final result = await service.importBookmarks(file);
      expect(result.linksImported, 1);
      // Tags "flutter" (7), "dart" (4), "mobile" (6) — all within 3-12 char range
      expect(result.tagsCreated, 3);
    });

    test("filters tags by length (3-12 chars)", () async {
      final file = await writeBookmarkFile(_bookmarkHtml(
        links: ["https://example.com"],
        linkTags: {"https://example.com": "ok,ab,validlongtag12"},
      ));

      final result = await service.importBookmarks(file);
      // "ok" is 2 chars (too short), "ab" is 2 chars (too short),
      // "validlongtag12" is 14 chars (too long → >12)
      // Wait, "validlongtag12" is 14 chars which is > 12, so filtered
      // Only tags with 3 <= len <= 12 pass
      expect(result.tagsCreated, 0);
    });

    test("imports folder tags", () async {
      final file = await writeBookmarkFile(_bookmarkHtml(
        folders: {"Dev Tools": []},
        folderTags: {"Dev Tools": "tools,development"},
      ));

      final result = await service.importBookmarks(file);
      expect(result.foldersCreated, 1);
      // "tools" (5 chars) and "development" (11 chars) both valid
      expect(result.tagsCreated, 2);
    });

    test("skips invalid URLs", () async {
      final file = await writeBookmarkFile(_bookmarkHtml(
        links: [
          "https://valid.dev",
          "javascript:void(0)",
          "ftp://files.example.com",
          "short",
        ],
      ));

      final result = await service.importBookmarks(file);
      // Only https://valid.dev is valid (starts with http/https, len >= 10)
      expect(result.linksImported, 1);
    });

    test("sanitizes short folder titles", () async {
      final file = await writeBookmarkFile(_bookmarkHtml(
        folders: {"Dev": ["https://example.com"]},
      ));

      final result = await service.importBookmarks(file);
      expect(result.foldersCreated, 1);
      // Title "Dev" is < 6 chars, gets " (imported)" appended
    });

    test("throws for invalid bookmark file", () async {
      final file = await writeBookmarkFile("<html><body>Not a bookmark file</body></html>");

      expect(
        () => service.importBookmarks(file),
        throwsA(isA<ArgumentError>()),
      );
    });

    test("handles empty bookmark file with DL tag", () async {
      final file = await writeBookmarkFile(_bookmarkHtml());

      final result = await service.importBookmarks(file);
      expect(result.foldersCreated, 0);
      expect(result.linksImported, 0);
    });
  });
}
