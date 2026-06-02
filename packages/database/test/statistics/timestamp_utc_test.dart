import "package:database/database.dart";
import "package:database/src/features/statistics/activity.dart";
import "package:database/src/features/background_jobs/crud.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

/// Timestamps written from Dart must be stored in UTC (an ISO-8601 string
/// ending in `Z`), not the local timezone offset. Mixed local/UTC storage
/// makes raw text comparisons of the column unreliable.
void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
        databaseName: "ts_utc_db", setupOnInit: true, debugMode: true);
  });

  tearDown(() async {
    await database.delete(database.activityEvents).go();
    await database.delete(database.backgroundJobs).go();
    await database.close();
  });

  Future<String> rawSingle(String sql) async =>
      (await database.customSelect(sql).getSingle()).read<String>("v");

  test("recordActivity stores occurred_at in UTC", () async {
    await database.recordActivity(
        eventType: "viewed", entityType: "link", entityId: "abc");

    final raw = await rawSingle(
        "SELECT occurred_at AS v FROM activity_events LIMIT 1");
    expect(raw.endsWith("Z"), isTrue, reason: "expected UTC, got <$raw>");
    expect(raw.contains("+"), isFalse, reason: "local offset leaked: <$raw>");
  });

  test("updateBackgroundJobStatus stores updated_at in UTC", () async {
    final id = await database.enqueueArchiveJob(
        linkId: "l1", url: "https://example.com", service: "archive_org");
    await database.updateBackgroundJobStatus(id: id, status: "in_progress");

    final raw = await rawSingle(
        "SELECT updated_at AS v FROM background_jobs WHERE id = '$id'");
    expect(raw.endsWith("Z"), isTrue, reason: "expected UTC, got <$raw>");
    expect(raw.contains("+"), isFalse, reason: "local offset leaked: <$raw>");
  });
}
