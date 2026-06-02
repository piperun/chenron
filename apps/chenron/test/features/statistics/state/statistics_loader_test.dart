import "package:database/database.dart";
import "package:database/features.dart";
import "package:drift/drift.dart" show Value;
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/statistics/state/statistics_loader.dart";
import "package:chenron/features/statistics/widgets/time_range_selector.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDatabaseHelper helper;
  late AppDatabase db;
  late StatisticsLoader loader;

  /// Inserts a statistics snapshot and an activity event timestamped
  /// [daysAgo] days in the past, so different time ranges include or
  /// exclude it.
  Future<void> seedSnapshotAndActivity({required int daysAgo}) async {
    final when = DateTime.now().subtract(Duration(days: daysAgo));
    await db.into(db.statistics).insert(
          StatisticsCompanion.insert(
            id: db.generateId(),
            recordedAt: Value(when),
            totalLinks: const Value(1),
          ),
        );
    await db.into(db.activityEvents).insert(
          ActivityEventsCompanion.insert(
            id: db.generateId(),
            occurredAt: Value(when),
            eventType: "link_created",
            entityType: "link",
          ),
        );
  }

  setUp(() async {
    helper = MockDatabaseHelper();
    await helper.setup();
    db = helper.database;
    loader = StatisticsLoader(db);
  });

  tearDown(() async {
    loader.dispose();
    await helper.dispose();
  });

  test("loadAll populates every signal and clears the loading flag",
      () async {
    await helper.createTestLink(url: "https://example.com", tags: ["news"]);
    await helper.createTestFolder(title: "Inbox Folder");
    await seedSnapshotAndActivity(daysAgo: 0);

    expect(loader.isLoading.value, isTrue);

    await loader.loadAll(TimeRange.month);

    expect(loader.isLoading.value, isFalse);
    expect(loader.currentCounts.value, isNotNull);
    expect(loader.currentCounts.value!.links, 1);
    expect(loader.tagCounts.value, isNotEmpty);
    expect(loader.folderCounts.value, isNotEmpty);
    expect(loader.history.value, isNotEmpty);
    expect(loader.dailyCounts.value, isNotEmpty);
  });

  test(
      "reloadForRange refreshes only range-dependent signals; "
      "range-independent signals keep their identity", () async {
    await helper.createTestLink(url: "https://example.com", tags: ["news"]);
    // One recent row (inside the 7-day window) and one old row (only
    // inside the 90-day window) so week vs quarter yield different
    // range-dependent results.
    await seedSnapshotAndActivity(daysAgo: 1);
    await seedSnapshotAndActivity(daysAgo: 60);

    await loader.loadAll(TimeRange.week);

    // Capture identities of the range-independent results after the
    // initial load.
    final countsBefore = loader.currentCounts.value;
    final tagsBefore = loader.tagCounts.value;
    final foldersBefore = loader.folderCounts.value;
    final historyWeek = loader.history.value.length;
    final dailyWeek = loader.dailyCounts.value.length;

    await loader.reloadForRange(TimeRange.quarter);

    // Range-independent signals were not reassigned: same object.
    expect(identical(loader.currentCounts.value, countsBefore), isTrue,
        reason: "currentCounts must not be refetched on range change");
    expect(identical(loader.tagCounts.value, tagsBefore), isTrue,
        reason: "tagCounts must not be refetched on range change");
    expect(identical(loader.folderCounts.value, foldersBefore), isTrue,
        reason: "folderCounts must not be refetched on range change");

    // Range-dependent signals widen to the quarter window: the 60-day-old
    // snapshot and activity event are now included, so both grow.
    expect(loader.history.value.length, greaterThan(historyWeek),
        reason: "history must refetch and widen for the quarter range");
    expect(loader.dailyCounts.value.length, greaterThan(dailyWeek),
        reason: "dailyCounts must refetch and widen for the quarter range");
  });

  test("reloadForRange does not touch the loading flag", () async {
    await loader.loadAll(TimeRange.week);
    expect(loader.isLoading.value, isFalse);

    // Even if something flipped it back, reloadForRange must leave it as-is.
    loader.isLoading.value = true;
    await loader.reloadForRange(TimeRange.month);
    expect(loader.isLoading.value, isTrue);
  });

  test("loadAll clears the loading flag and reports errors on query "
      "failure", () async {
    // Drop a table a query reads from so the load throws mid-flight.
    await db.customStatement("DROP TABLE statistics");
    Object? reported;
    final failing = StatisticsLoader(db, onError: (e) => reported = e);

    await failing.loadAll(TimeRange.week);

    expect(failing.isLoading.value, isFalse,
        reason: "spinner must clear even when the load fails");
    expect(reported, isNotNull,
        reason: "the failure must be surfaced via onError");
    failing.dispose();
  });
}
