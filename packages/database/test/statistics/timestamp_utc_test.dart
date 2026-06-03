import "package:database/database.dart";
import "package:database/src/features/folder/create.dart";
import "package:database/src/features/link/create.dart";
import "package:database/src/features/statistics/activity.dart";
import "package:database/src/features/background_jobs/crud.dart";
import "package:database/src/features/tag/create.dart";
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

  group("column DEFAULT writes canonical UTC ms text", () {
    // No timestamps are passed to these inserts, so the value comes from the
    // column DEFAULT — proving the new strftime default is live (not the old
    // space-separated CURRENT_TIMESTAMP shape).
    void expectCanonical(String raw) {
      expect(raw.endsWith("Z"), isTrue, reason: "expected UTC, got <$raw>");
      expect(raw.contains("T"), isTrue,
          reason: "expected ISO 'T' separator, got <$raw>");
      expect(raw.contains("."), isTrue,
          reason: "expected millisecond fraction, got <$raw>");
      expect(raw.contains(" "), isFalse,
          reason: "space-separated CURRENT_TIMESTAMP shape leaked: <$raw>");
    }

    test("folders.created_at / updated_at default is canonical", () async {
      final result = await database.createFolder(
        folderInfo: FolderDraft(
            title: "Default Folder", description: "no timestamps passed"),
      );
      final row = await database
          .customSelect(
              "SELECT created_at, updated_at FROM folders WHERE id = '${result.folderId}'")
          .getSingle();
      expectCanonical(row.read<String>("created_at"));
      expectCanonical(row.read<String>("updated_at"));
    });

    test("background_jobs.created_at default is canonical", () async {
      final id = await database.enqueueArchiveJob(
          linkId: "l1", url: "https://example.com", service: "archive_org");
      expectCanonical(await rawSingle(
          "SELECT created_at AS v FROM background_jobs WHERE id = '$id'"));
    });

    test("links.created_at default is canonical", () async {
      final result = await database.createLink(link: "https://example.org");
      expectCanonical(await rawSingle(
          "SELECT created_at AS v FROM links WHERE id = '${result.linkId}'"));
    });

    test("tags.created_at default is canonical", () async {
      final tagId = await database.addTag("defaulttag");
      expectCanonical(await rawSingle(
          "SELECT created_at AS v FROM tags WHERE id = '$tagId'"));
    });
  });
}
