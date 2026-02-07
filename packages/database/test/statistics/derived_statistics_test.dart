import "package:database/main.dart";
import "package:database/models/document_file_type.dart";
import "package:database/models/folder.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/src/features/statistics/activity.dart";
import "package:database/src/features/statistics/derived.dart";
import "package:database/src/features/link/create.dart";
import "package:database/src/features/folder/create.dart";
import "package:database/src/features/tag/create.dart";
import "package:flutter_test/flutter_test.dart" as matcher;
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
      databaseName: "test_db",
      setupOnInit: true,
      debugMode: true,
    );
  });

  tearDown(() async {
    // Delete entities first (triggers will fire and create more events)
    final metadataRecords = database.metadataRecords;
    await database.delete(metadataRecords).go();
    final items = database.items;
    await database.delete(items).go();
    final links = database.links;
    await database.delete(links).go();
    final documents = database.documents;
    await database.delete(documents).go();
    final folders = database.folders;
    await database.delete(folders).go();
    final tags = database.tags;
    await database.delete(tags).go();
    // Clean activity_events LAST to also remove trigger-generated events from above
    final activityEvents = database.activityEvents;
    await database.delete(activityEvents).go();
    await database.close();
  });

  group("getTagDistribution() Aggregation", () {
    test("returns tag distribution with item counts", () async {
      // Create 2 links with "flutter" tag
      await database.createLink(
        link: "https://flutter.dev",
        tags: [Metadata(value: "flutter", type: MetadataTypeEnum.tag)],
      );
      await database.createLink(
        link: "https://flutter.dev/docs",
        tags: [Metadata(value: "flutter", type: MetadataTypeEnum.tag)],
      );

      // Create 1 link with "dart" tag
      await database.createLink(
        link: "https://dart.dev",
        tags: [Metadata(value: "dart", type: MetadataTypeEnum.tag)],
      );

      final distribution = await database.getTagDistribution();

      expect(distribution, matcher.isNotEmpty);

      final flutterTag =
          distribution.where((t) => t.tagName == "flutter").first;
      final dartTag =
          distribution.where((t) => t.tagName == "dart").first;

      expect(flutterTag.itemCount, equals(2));
      expect(dartTag.itemCount, equals(1));
    });

    test("returns tags with zero items via LEFT JOIN", () async {
      // Create a tag with no linked items
      await database.addTag("unused-tag");

      final distribution = await database.getTagDistribution();

      expect(distribution, matcher.isNotEmpty);
      final unusedTag =
          distribution.where((t) => t.tagName == "unused-tag").first;
      expect(unusedTag.itemCount, equals(0));
    });

    test("returns empty list when no tags exist", () async {
      final distribution = await database.getTagDistribution();

      expect(distribution, matcher.isEmpty);
    });

    test("includes tagColor when set", () async {
      await database.addTag("red-tag", color: 0xFFFF0000);

      final distribution = await database.getTagDistribution();

      final redTag =
          distribution.where((t) => t.tagName == "red-tag").first;
      expect(redTag.tagColor, equals(0xFFFF0000));
    });
  });

  group("getFolderComposition() Aggregation", () {
    test("returns folder composition with item type counts", () async {
      await database.createFolder(
        folderInfo: FolderDraft(
          title: "Test Folder",
          description: "A test folder",
        ),
        items: [
          const FolderItem.link(url: "https://flutter.dev"),
          const FolderItem.link(url: "https://dart.dev"),
          const FolderItem.document(
            title: "Test Doc",
            filePath: "/path/doc.md",
            fileType: DocumentFileType.markdown,
          ),
        ],
      );

      final composition = await database.getFolderComposition();

      expect(composition, matcher.isNotEmpty);

      final folderEntries = composition
          .where((c) => c.folderTitle == "Test Folder")
          .toList();

      expect(folderEntries, matcher.isNotEmpty);

      // Should have entries for link and document item types
      final totalItems =
          folderEntries.fold<int>(0, (sum, c) => sum + c.itemCount);
      expect(totalItems, equals(3));
    });

    test("returns folders with no items via LEFT JOIN", () async {
      await database.createFolder(
        folderInfo: FolderDraft(
          title: "Empty Folder",
          description: "No items here",
        ),
      );

      final composition = await database.getFolderComposition();

      expect(composition, matcher.isNotEmpty);
      final emptyFolder = composition
          .where((c) => c.folderTitle == "Empty Folder")
          .first;
      expect(emptyFolder.itemCount, equals(0));
      expect(emptyFolder.itemType, matcher.isNull);
    });

    test("returns empty list when no folders exist", () async {
      final composition = await database.getFolderComposition();

      expect(composition, matcher.isEmpty);
    });
  });

  group("getActivitySummary() Aggregation", () {
    test("returns complete summary with events", () async {
      final now = DateTime.now();
      final start = now.subtract(const Duration(hours: 1));
      final end = now.add(const Duration(hours: 1));

      // Record 3 "link_created" and 2 "tag_created" events
      await database.recordActivity(
          eventType: "link_created", entityType: "link");
      await database.recordActivity(
          eventType: "link_created", entityType: "link");
      await database.recordActivity(
          eventType: "link_created", entityType: "link");
      await database.recordActivity(
          eventType: "tag_created", entityType: "tag");
      await database.recordActivity(
          eventType: "tag_created", entityType: "tag");

      final summary = await database.getActivitySummary(
        startDate: start,
        endDate: end,
      );

      expect(summary.totalEvents, equals(5));
      expect(summary.mostCommonAction, equals("link_created"));
      expect(summary.mostCommonActionCount, equals(3));
      expect(summary.mostActiveDay, matcher.isNotNull);
      expect(summary.mostActiveDayCount, equals(5));
    });

    test("returns zero summary for empty date range", () async {
      await database.recordActivity(
          eventType: "link_created", entityType: "link");

      final futureStart = DateTime.now().add(const Duration(hours: 1));
      final futureEnd = DateTime.now().add(const Duration(hours: 2));

      final summary = await database.getActivitySummary(
        startDate: futureStart,
        endDate: futureEnd,
      );

      expect(summary.totalEvents, equals(0));
      expect(summary.mostActiveDay, matcher.isNull);
      expect(summary.mostActiveDayCount, equals(0));
      expect(summary.mostCommonAction, matcher.isNull);
      expect(summary.mostCommonActionCount, equals(0));
    });

    test("returns zero summary on empty database", () async {
      final summary = await database.getActivitySummary(
        startDate: DateTime.now().subtract(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(summary.totalEvents, equals(0));
      expect(summary.mostActiveDay, matcher.isNull);
      expect(summary.mostCommonAction, matcher.isNull);
    });
  });
}
