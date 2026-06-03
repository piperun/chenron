import "package:database/database.dart";
import "package:database/src/features/statistics/activity.dart";
import "package:drift/drift.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

/// With timestamps stored as canonical fixed-width UTC text, the date range
/// filter on `occurred_at` is a plain `col >= ? AND col <= ?` — sargable, so
/// SQLite can drive it through `activity_events_occurred_idx` instead of
/// scanning the table. The old `datetime(occurred_at)` wrapping made the
/// predicate non-sargable and forced a full scan.
void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
        databaseName: "sargability_db", setupOnInit: true, debugMode: true);
  });

  tearDown(() async {
    await database.delete(database.activityEvents).go();
    await database.close();
  });

  test("getActivityCountsByType range filter uses the occurred_at index",
      () async {
    // Seed enough rows that the planner won't dismiss the index as
    // not-worth-it on a near-empty table.
    for (var i = 0; i < 50; i++) {
      await database.recordActivity(
        eventType: i.isEven ? "viewed" : "created",
        entityType: "link",
        entityId: "e$i",
      );
    }

    final start = DateTime.now().subtract(const Duration(days: 1));
    final end = DateTime.now().add(const Duration(days: 1));

    // Exact query text getActivityCountsByType runs, wrapped in EXPLAIN
    // QUERY PLAN so we inspect how SQLite resolves the range filter.
    final plan = await database.customSelect(
      "EXPLAIN QUERY PLAN "
      "SELECT event_type, COUNT(*) as count FROM activity_events "
      "WHERE occurred_at >= ? AND occurred_at <= ? "
      "GROUP BY event_type ORDER BY count DESC",
      variables: [
        Variable.withDateTime(start),
        Variable.withDateTime(end),
      ],
    ).get();

    final details =
        plan.map((row) => row.read<String>("detail")).toList(growable: false);
    final joined = details.join(" | ");

    expect(
      details.any(
          (d) => d.contains("USING INDEX activity_events_occurred_idx")),
      isTrue,
      reason: "expected the occurred_at index to drive the range scan, "
          "but the plan was: $joined",
    );
    expect(
      details.any((d) => d.contains("SCAN activity_events") &&
          !d.contains("USING INDEX")),
      isFalse,
      reason: "expected no full table scan, but the plan was: $joined",
    );
  });
}
