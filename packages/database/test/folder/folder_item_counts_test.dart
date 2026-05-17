import "package:database/main.dart";
import "package:database/models/item.dart";
import "package:database/src/features/folder/counts.dart";
import "package:database/src/features/folder/create.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(databaseName: "test_counts_db", debugMode: true);
  });

  tearDown(() async {
    await database.delete(database.items).go();
    await database.delete(database.folders).go();
    await database.delete(database.links).go();
    await database.delete(database.documents).go();
    await database.close();
  });

  group("watchFoldersWithItemCounts", () {
    test("emits empty list when no folders exist", () async {
      final stream = database.watchFoldersWithItemCounts();
      expect(await stream.first, isEmpty);
    });

    test("emits a folder with zero counts when it has no items", () async {
      final folderData = FolderTestDataFactory.create(
        title: "Empty Folder",
        description: "No items here",
        tagValues: [],
        itemsData: [],
      );
      await database.createFolder(
        folderInfo: folderData.folder,
        tags: folderData.tags,
        items: folderData.items,
      );

      final result = await database.watchFoldersWithItemCounts().first;

      expect(result, hasLength(1));
      expect(result.single.title, "Empty Folder");
      expect(result.single.countOf(FolderItemType.link), 0);
      expect(result.single.countOf(FolderItemType.document), 0);
      expect(result.single.countOf(FolderItemType.folder), 0);
      expect(result.single.total, 0);
    });

    test("counts items grouped by FolderItemType", () async {
      final folderData = FolderTestDataFactory.create(
        title: "Mixed Folder",
        description: "Has links and docs",
        tagValues: [],
        itemsData: [
          {"type": "link", "content": "https://a.example.com"},
          {"type": "link", "content": "https://b.example.com"},
          {"type": "link", "content": "https://c.example.com"},
          {
            "type": "document",
            "content": {"title": "Document One", "body": "Body"}
          },
          {
            "type": "document",
            "content": {"title": "Document Two", "body": "Body"}
          },
        ],
      );
      await database.createFolder(
        folderInfo: folderData.folder,
        tags: folderData.tags,
        items: folderData.items,
      );

      final result = await database.watchFoldersWithItemCounts().first;

      expect(result, hasLength(1));
      expect(result.single.countOf(FolderItemType.link), 3);
      expect(result.single.countOf(FolderItemType.document), 2);
      expect(result.single.countOf(FolderItemType.folder), 0);
      expect(result.single.total, 5);
    });

    test("emits one row per folder with independent counts", () async {
      final folderA = FolderTestDataFactory.create(
        title: "Folder Alpha",
        description: "A",
        tagValues: [],
        itemsData: [
          {"type": "link", "content": "https://a.com"},
        ],
      );
      final folderB = FolderTestDataFactory.create(
        title: "Folder Bravo",
        description: "B",
        tagValues: [],
        itemsData: [
          {"type": "link", "content": "https://b.com"},
          {"type": "link", "content": "https://b2.com"},
        ],
      );
      await database.createFolder(
        folderInfo: folderA.folder,
        tags: folderA.tags,
        items: folderA.items,
      );
      await database.createFolder(
        folderInfo: folderB.folder,
        tags: folderB.tags,
        items: folderB.items,
      );

      final result = await database.watchFoldersWithItemCounts().first;

      expect(result, hasLength(2));
      final byTitle = {for (final r in result) r.title: r};
      expect(byTitle["Folder Alpha"]!.countOf(FolderItemType.link), 1);
      expect(byTitle["Folder Bravo"]!.countOf(FolderItemType.link), 2);
    });

    test("stream re-emits when new folder rows arrive", () async {
      final emissions = <int>[];
      final sub = database.watchFoldersWithItemCounts().listen((rows) {
        emissions.add(rows.length);
      });

      // Initial emission: no folders.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions, [0]);

      final batch1 = FolderTestDataFactory.create(
        title: "First Batch",
        description: "First",
        tagValues: [],
        itemsData: [
          {"type": "link", "content": "https://1.com"},
        ],
      );
      await database.createFolder(
        folderInfo: batch1.folder,
        tags: batch1.tags,
        items: batch1.items,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions.last, 1);

      final batch2 = FolderTestDataFactory.create(
        title: "Second Batch",
        description: "Second",
        tagValues: [],
        itemsData: [
          {"type": "link", "content": "https://2.com"},
          {"type": "link", "content": "https://2b.com"},
        ],
      );
      await database.createFolder(
        folderInfo: batch2.folder,
        tags: batch2.tags,
        items: batch2.items,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions.last, 2);

      // Latest snapshot has independent per-folder counts.
      final snapshot = await database.watchFoldersWithItemCounts().first;
      final byTitle = {for (final r in snapshot) r.title: r};
      expect(byTitle["First Batch"]!.countOf(FolderItemType.link), 1);
      expect(byTitle["Second Batch"]!.countOf(FolderItemType.link), 2);

      await sub.cancel();
    });
  });
}
