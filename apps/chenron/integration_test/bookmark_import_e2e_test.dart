import "dart:io";

import "package:chenron/features/settings/service/bookmark_import_service.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/features.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

/// End-to-end bookmark import: real (in-memory) AppDatabase, real on-disk
/// HTML file, real `compute()` isolate hop. The unit test in
/// `test/features/settings/service/bookmark_import_service_test.dart`
/// covers small scenarios; this exercises a realistic Chrome-shaped
/// export with deep nesting and the title/description sanitization
/// edge cases that only fire at scale.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(installTestLogger);

  late MockDatabaseHelper mockDb;
  late BookmarkImportService service;
  late Directory tempDir;

  setUp(() async {
    mockDb = MockDatabaseHelper();
    await mockDb.setup();
    service = BookmarkImportService.withDeps(appDatabase: mockDb.database);
    tempDir = await Directory.systemTemp.createTemp("bookmark_import_e2e");
  });

  tearDown(() async {
    await mockDb.dispose();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<File> writeFixture(String content) async {
    final file = File("${tempDir.path}/bookmarks.html");
    await file.writeAsString(content);
    return file;
  }

  group("Bookmark import — realistic export shape", () {
    test("imports a deeply nested folder tree with mixed content", () async {
      final html = _buildRealisticExport();
      final file = await writeFixture(html);

      final result = await service.importBookmarks(file);

      expect(result.foldersCreated, equals(5));
      expect(result.linksImported, equals(8));
      expect(result.linksSkipped, equals(0));
      expect(result.tagsCreated, greaterThan(0));

      final allLinks = await mockDb.database.getAllLinks();
      expect(allLinks.length, equals(8));

      final urls = allLinks.map((l) => l.data.path).toSet();
      expect(urls, contains("https://docs.flutter.dev/"));
      expect(urls, contains("https://api.dart.dev/"));
      expect(urls, contains("https://drift.simonbinder.eu/"));
    });

    test("skips duplicate URLs but counts the folder/tag side effects",
        () async {
      const dupUrl = "https://example.org/page";
      final html = _wrap("""
    <DT><A HREF="$dupUrl">First</A>
    <DT><A HREF="$dupUrl">Second</A>
    <DT><A HREF="$dupUrl">Third</A>
""");

      final file = await writeFixture(html);
      final result = await service.importBookmarks(file);

      expect(result.linksImported, equals(1));
      expect(result.linksSkipped, equals(2));

      final allLinks = await mockDb.database.getAllLinks();
      expect(allLinks.where((l) => l.data.path == dupUrl).length,
          greaterThanOrEqualTo(1));
    });

    test("sanitizes folder titles per BookmarkImportService rules", () async {
      final html = _wrap("""
    <DT><H3>A</H3>
    <DL><p>
        <DT><A HREF="https://short-title.example/">a</A>
    </DL><p>
    <DT><H3>This folder title is intentionally far longer than thirty characters and should be truncated</H3>
    <DL><p>
        <DT><A HREF="https://long-title.example/">b</A>
    </DL><p>
    <DT><H3>Normal Folder Name</H3>
    <DL><p>
        <DT><A HREF="https://normal.example/">c</A>
    </DL><p>
""");
      final file = await writeFixture(html);
      await service.importBookmarks(file);

      final folders = await mockDb.database.getAllFolders();
      final titles = folders.map((f) => f.data.title).toList();

      expect(
        titles,
        contains("A (imported)"),
        reason: "Titles shorter than 6 chars get the ` (imported)` suffix.",
      );
      expect(
        titles.any((t) => t.length == 30),
        isTrue,
        reason: "Titles longer than 30 chars are truncated to 30.",
      );
      expect(titles, contains("Normal Folder Name"));
    });

    test("ignores invalid URLs without crashing", () async {
      final html = _wrap("""
    <DT><A HREF="not-a-url">bad</A>
    <DT><A HREF="javascript:alert(1)">also bad</A>
    <DT><A HREF="http://x">too short</A>
    <DT><A HREF="https://valid.example/page">good</A>
""");
      final file = await writeFixture(html);
      final result = await service.importBookmarks(file);

      expect(result.linksImported, equals(1));
      final allLinks = await mockDb.database.getAllLinks();
      expect(allLinks.map((l) => l.data.path),
          equals({"https://valid.example/page"}));
    });
  });
}

String _wrap(String body) => """
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks</H1>
<DL><p>
$body
</DL><p>
""";

String _buildRealisticExport() => _wrap("""
    <DT><H3>Flutter Stuff</H3>
    <DL><p>
        <DT><A HREF="https://docs.flutter.dev/" TAGS="docs,flutter">Flutter docs</A>
        <DT><A HREF="https://api.dart.dev/" TAGS="docs,dart">Dart API</A>
        <DT><H3 TAGS="orm">Drift Resources</H3>
        <DL><p>
            <DT><A HREF="https://drift.simonbinder.eu/" TAGS="drift,sqlite">Drift docs</A>
            <DT><A HREF="https://pub.dev/packages/drift" TAGS="drift,pub">Drift on pub</A>
        </DL><p>
    </DL><p>
    <DT><H3>Reading List</H3>
    <DL><p>
        <DT><A HREF="https://martinfowler.com/articles/lmax.html" TAGS="reading,architecture">LMAX article</A>
        <DT><A HREF="https://www.joelonsoftware.com/2002/11/11/the-law-of-leaky-abstractions/" TAGS="reading">Joel on Software</A>
    </DL><p>
    <DT><H3>Tools</H3>
    <DL><p>
        <DT><H3>VCS</H3>
        <DL><p>
            <DT><A HREF="https://git-scm.com/" TAGS="git,vcs">git</A>
            <DT><A HREF="https://docs.cocogitto.io/" TAGS="cog,vcs">cocogitto</A>
        </DL><p>
    </DL><p>
""");
