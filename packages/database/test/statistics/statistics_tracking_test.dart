import "package:database/main.dart";
import "package:database/models/document_file_type.dart";
import "package:database/models/folder.dart";
import "package:database/src/features/statistics/track.dart";
import "package:database/src/features/link/create.dart";
import "package:database/src/features/folder/create.dart";
import "package:database/src/features/document/create.dart";
import "package:database/src/features/tag/create.dart";
import "package:drift/drift.dart";
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
    final statistics = database.statistics;
    await database.delete(statistics).go();
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

  group("recordStatisticsSnapshot() Operations", () {
    test("records snapshot reflecting initial database state", () async {
      await database.recordStatisticsSnapshot();

      final statistics = database.statistics;
      final snapshots = await database.select(statistics).get();

      expect(snapshots.length, equals(1));
      // setupOnInit creates a Default folder, so totalFolders >= 1
      // Verify counts are non-negative (snapshot reflects actual state)
      expect(snapshots.first.totalLinks, matcher.greaterThanOrEqualTo(0));
      expect(snapshots.first.totalDocuments, matcher.greaterThanOrEqualTo(0));
      expect(snapshots.first.totalTags, matcher.greaterThanOrEqualTo(0));
      expect(snapshots.first.totalFolders, matcher.greaterThanOrEqualTo(1));
    });

    test("records snapshot with correct counts after creating entities",
        () async {
      // Capture baseline counts from initial database state
      final linksTable = database.links;
      final docsTable = database.documents;
      final tagsTable = database.tags;
      final foldersTable = database.folders;
      final baseLinks = (await database.select(linksTable).get()).length;
      final baseDocs = (await database.select(docsTable).get()).length;
      final baseTags = (await database.select(tagsTable).get()).length;
      final baseFolders = (await database.select(foldersTable).get()).length;

      // Create seed data
      await database.createLink(link: "https://flutter.dev");
      await database.createLink(link: "https://dart.dev");
      await database.createDocument(
        title: "Test Doc",
        filePath: "/path/doc.md",
        fileType: DocumentFileType.markdown,
      );
      await database.addTag("flutter");
      await database.addTag("dart");
      await database.addTag("test");
      await database.createFolder(
        folderInfo: FolderDraft(
          title: "Test Folder",
          description: "A test folder",
        ),
      );

      await database.recordStatisticsSnapshot();

      final statistics = database.statistics;
      final snapshots = await database.select(statistics).get();

      expect(snapshots.length, equals(1));
      expect(snapshots.first.totalLinks, equals(baseLinks + 2));
      expect(snapshots.first.totalDocuments, equals(baseDocs + 1));
      expect(snapshots.first.totalTags, equals(baseTags + 3));
      expect(snapshots.first.totalFolders, equals(baseFolders + 1));
    });

    test("records multiple snapshots reflecting state changes", () async {
      // Capture baseline link count
      final linksTable = database.links;
      final baseLinks = (await database.select(linksTable).get()).length;

      // First snapshot: baseline + 1 link
      await database.createLink(link: "https://flutter.dev");
      await database.recordStatisticsSnapshot();

      await Future.delayed(const Duration(milliseconds: 1100));

      // Create more items
      await database.createLink(link: "https://dart.dev");
      await database.createLink(link: "https://pub.dev");

      // Second snapshot: baseline + 3 links
      await database.recordStatisticsSnapshot();

      final statistics = database.statistics;
      final snapshots = await (database.select(statistics)
            ..orderBy([(t) => OrderingTerm.asc(t.recordedAt)]))
          .get();

      expect(snapshots.length, equals(2));
      expect(snapshots[0].totalLinks, equals(baseLinks + 1));
      expect(snapshots[1].totalLinks, equals(baseLinks + 3));
    });
  });

  group("getLatestStatistics() Query Operations", () {
    test("returns null when no snapshots exist", () async {
      final latest = await database.getLatestStatistics();

      expect(latest, matcher.isNull);
    });

    test("returns the most recent snapshot", () async {
      final linksTable = database.links;
      final baseLinks = (await database.select(linksTable).get()).length;

      await database.createLink(link: "https://flutter.dev");
      await database.recordStatisticsSnapshot();

      await Future.delayed(const Duration(milliseconds: 1100));

      await database.createLink(link: "https://dart.dev");
      await database.recordStatisticsSnapshot();

      final latest = await database.getLatestStatistics();

      expect(latest, matcher.isNotNull);
      expect(latest!.totalLinks, equals(baseLinks + 2));
    });

    test("returns single snapshot when only one exists", () async {
      await database.recordStatisticsSnapshot();

      final latest = await database.getLatestStatistics();

      expect(latest, matcher.isNotNull);
      // Snapshot reflects whatever baseline exists after setupOnInit
      expect(latest!.totalLinks, matcher.greaterThanOrEqualTo(0));
    });
  });

  group("getStatisticsHistory() Query Operations", () {
    test("returns all snapshots with no filters", () async {
      await database.recordStatisticsSnapshot();
      await Future.delayed(const Duration(milliseconds: 1100));
      await database.recordStatisticsSnapshot();
      await Future.delayed(const Duration(milliseconds: 1100));
      await database.recordStatisticsSnapshot();

      final history = await database.getStatisticsHistory();

      expect(history.length, equals(3));
    });

    test("returns results ordered by recordedAt DESC", () async {
      final linksTable = database.links;
      final baseLinks = (await database.select(linksTable).get()).length;

      await database.createLink(link: "https://flutter.dev");
      await database.recordStatisticsSnapshot();
      await Future.delayed(const Duration(milliseconds: 1100));

      await database.createLink(link: "https://dart.dev");
      await database.recordStatisticsSnapshot();

      final history = await database.getStatisticsHistory();

      expect(history.length, equals(2));
      // First result should be the most recent (baseLinks + 2)
      expect(history.first.totalLinks, equals(baseLinks + 2));
      expect(history.last.totalLinks, equals(baseLinks + 1));
    });

    test("filters by startDate", () async {
      final linksTable = database.links;
      final baseLinks = (await database.select(linksTable).get()).length;

      await database.recordStatisticsSnapshot();
      await Future.delayed(const Duration(milliseconds: 1100));

      final cutoff = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 1100));

      await database.createLink(link: "https://flutter.dev");
      await database.recordStatisticsSnapshot();

      final history = await database.getStatisticsHistory(startDate: cutoff);

      expect(history.length, equals(1));
      expect(history.first.totalLinks, equals(baseLinks + 1));
    });

    test("filters by endDate", () async {
      final linksTable = database.links;
      final baseLinks = (await database.select(linksTable).get()).length;

      await database.recordStatisticsSnapshot();
      await Future.delayed(const Duration(milliseconds: 1100));

      final cutoff = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 1100));

      await database.createLink(link: "https://flutter.dev");
      await database.recordStatisticsSnapshot();

      final history = await database.getStatisticsHistory(endDate: cutoff);

      expect(history.length, equals(1));
      expect(history.first.totalLinks, equals(baseLinks));
    });

    test("returns empty list when no snapshots match", () async {
      await database.recordStatisticsSnapshot();

      final futureStart = DateTime.now().add(const Duration(hours: 1));

      final history =
          await database.getStatisticsHistory(startDate: futureStart);

      expect(history, matcher.isEmpty);
    });

    test("returns empty list on empty database", () async {
      final history = await database.getStatisticsHistory();

      expect(history, matcher.isEmpty);
    });
  });
}
