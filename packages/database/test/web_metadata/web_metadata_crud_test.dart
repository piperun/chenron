import "package:database/database.dart";
import "package:database/features.dart";
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
    await database.delete(database.webMetadataRefreshEntries).go();
    await database.delete(database.webMetadataEntries).go();
    await database.close();
  });

  group("WebMetadataCrudExtensions", () {
    test("getWebMetadata returns null for unknown URL", () async {
      final result = await database.getWebMetadata("https://unknown.com");
      expect(result, isNull);
    });

    test("upsertWebMetadata inserts new entry", () async {
      final now = DateTime.now();
      await database.upsertWebMetadata(
        url: "https://example.com",
        title: "Example",
        description: "An example page",
        image: "https://example.com/og.png",
        resolvedUrl: "https://www.example.com/final",
        etag: '"example-v1"',
        lastModified: "Sat, 09 Aug 2026 10:00:00 GMT",
        contentHash: "sha256:example",
        fetchedAt: now,
      );

      final result = await database.getWebMetadata("https://example.com");
      expect(result, isNotNull);
      expect(result!.url, "https://example.com");
      expect(result.title, "Example");
      expect(result.description, "An example page");
      expect(result.image, "https://example.com/og.png");
      expect(result.resolvedUrl, "https://www.example.com/final");
      expect(result.etag, '"example-v1"');
      expect(result.lastModified, "Sat, 09 Aug 2026 10:00:00 GMT");
      expect(result.contentHash, "sha256:example");
    });

    test("upsertWebMetadata updates existing entry on conflict", () async {
      final t1 = DateTime(2025, 1, 1);
      final t2 = DateTime(2025, 6, 1);

      await database.upsertWebMetadata(
        url: "https://example.com",
        title: "Old Title",
        description: "Old desc",
        image: null,
        fetchedAt: t1,
      );

      await database.upsertWebMetadata(
        url: "https://example.com",
        title: "New Title",
        description: "New desc",
        image: "https://example.com/new.png",
        fetchedAt: t2,
      );

      final result = await database.getWebMetadata("https://example.com");
      expect(result, isNotNull);
      expect(result!.title, "New Title");
      expect(result.description, "New desc");
      expect(result.image, "https://example.com/new.png");

      // Should still be one row, not two
      final count = await database.countWebMetadata();
      expect(count, 1);
    });

    test("upsertWebMetadata handles nullable fields", () async {
      await database.upsertWebMetadata(
        url: "https://no-meta.com",
        title: null,
        description: null,
        image: null,
        fetchedAt: DateTime.now(),
      );

      final result = await database.getWebMetadata("https://no-meta.com");
      expect(result, isNotNull);
      expect(result!.title, isNull);
      expect(result.description, isNull);
      expect(result.image, isNull);
      expect(result.resolvedUrl, isNull);
      expect(result.etag, isNull);
      expect(result.lastModified, isNull);
      expect(result.contentHash, isNull);
    });

    test("removeWebMetadata deletes an entry", () async {
      await database.upsertWebMetadata(
        url: "https://example.com",
        title: "Example",
        description: null,
        image: null,
        fetchedAt: DateTime.now(),
      );

      await database.removeWebMetadata("https://example.com");

      final result = await database.getWebMetadata("https://example.com");
      expect(result, isNull);
    });

    test("removeWebMetadata is a no-op for unknown URL", () async {
      // Should not throw
      await database.removeWebMetadata("https://nonexistent.com");
    });

    test("clearAllWebMetadata removes all entries", () async {
      for (var i = 0; i < 5; i++) {
        await database.upsertWebMetadata(
          url: "https://example.com/$i",
          title: "Page $i",
          description: null,
          image: null,
          fetchedAt: DateTime.now(),
        );
      }

      expect(await database.countWebMetadata(), 5);

      await database.clearAllWebMetadata();

      expect(await database.countWebMetadata(), 0);
    });

    test("countWebMetadata returns correct count", () async {
      expect(await database.countWebMetadata(), 0);

      await database.upsertWebMetadata(
        url: "https://a.com",
        title: "A",
        description: null,
        image: null,
        fetchedAt: DateTime.now(),
      );
      expect(await database.countWebMetadata(), 1);

      await database.upsertWebMetadata(
        url: "https://b.com",
        title: "B",
        description: null,
        image: null,
        fetchedAt: DateTime.now(),
      );
      expect(await database.countWebMetadata(), 2);

      // Upsert same URL shouldn't increase count
      await database.upsertWebMetadata(
        url: "https://a.com",
        title: "A updated",
        description: null,
        image: null,
        fetchedAt: DateTime.now(),
      );
      expect(await database.countWebMetadata(), 2);
    });

    test("different URLs are stored independently", () async {
      await database.upsertWebMetadata(
        url: "https://foo.com",
        title: "Foo",
        description: "Foo site",
        image: null,
        fetchedAt: DateTime.now(),
      );
      await database.upsertWebMetadata(
        url: "https://bar.com",
        title: "Bar",
        description: "Bar site",
        image: null,
        fetchedAt: DateTime.now(),
      );

      final foo = await database.getWebMetadata("https://foo.com");
      final bar = await database.getWebMetadata("https://bar.com");

      expect(foo!.title, "Foo");
      expect(bar!.title, "Bar");
    });

    test("removeWebMetadata only removes the targeted URL", () async {
      await database.upsertWebMetadata(
        url: "https://keep.com",
        title: "Keep",
        description: null,
        image: null,
        fetchedAt: DateTime.now(),
      );
      await database.upsertWebMetadata(
        url: "https://delete.com",
        title: "Delete",
        description: null,
        image: null,
        fetchedAt: DateTime.now(),
      );

      await database.removeWebMetadata("https://delete.com");

      expect(await database.getWebMetadata("https://keep.com"), isNotNull);
      expect(await database.getWebMetadata("https://delete.com"), isNull);
      expect(await database.countWebMetadata(), 1);
    });

    test("upsertWebMetadata stores adaptive TTL fields", () async {
      await database.upsertWebMetadata(
        url: "https://example.com",
        title: "Example",
        description: null,
        image: null,
        fetchedAt: DateTime.now(),
        consecutiveUnchanged: 3,
        ttlDays: 56,
      );

      final result = await database.getWebMetadata("https://example.com");
      expect(result!.consecutiveUnchanged, 3);
      expect(result.ttlDays, 56);
    });

    test("upsertWebMetadata defaults TTL fields when omitted", () async {
      await database.upsertWebMetadata(
        url: "https://example.com",
        title: "Example",
        description: null,
        image: null,
        fetchedAt: DateTime.now(),
      );

      final result = await database.getWebMetadata("https://example.com");
      expect(result!.consecutiveUnchanged, 0);
      expect(result.ttlDays, 7);
    });

    test("getExpiredEntries returns entries past their TTL", () async {
      final now = DateTime.now();
      // Fresh entry (fetched today, TTL 7 days) — should NOT be returned
      await database.upsertWebMetadata(
        url: "https://fresh.com",
        title: "Fresh",
        description: null,
        image: null,
        fetchedAt: now,
        ttlDays: 7,
      );
      // Expired entry (fetched 10 days ago, TTL 7 days) — should be returned
      await database.upsertWebMetadata(
        url: "https://stale.com",
        title: "Stale",
        description: null,
        image: null,
        fetchedAt: now.subtract(const Duration(days: 10)),
        ttlDays: 7,
        consecutiveUnchanged: 2,
      );
      // Barely expired (fetched 8 days ago, TTL 7 days) — should be returned
      await database.upsertWebMetadata(
        url: "https://barely.com",
        title: "Barely",
        description: null,
        image: null,
        fetchedAt: now.subtract(const Duration(days: 8)),
        ttlDays: 7,
        consecutiveUnchanged: 0,
      );

      final expired = await database.getExpiredEntries();
      final urls = expired.map((e) => e.url).toList();

      expect(urls, contains("https://stale.com"));
      expect(urls, contains("https://barely.com"));
      expect(urls, isNot(contains("https://fresh.com")));
    });

    test("getWebMetadataForUrls returns map keyed by URL for known entries",
        () async {
      final now = DateTime.now();
      await database.upsertWebMetadata(
        url: "https://a.com",
        title: "A",
        description: null,
        image: null,
        fetchedAt: now,
      );
      await database.upsertWebMetadata(
        url: "https://b.com",
        title: "B",
        description: null,
        image: null,
        fetchedAt: now,
      );

      final result = await database.getWebMetadataForUrls([
        "https://a.com",
        "https://b.com",
        "https://missing.com",
      ]);

      expect(result.keys, containsAll(["https://a.com", "https://b.com"]));
      expect(result.containsKey("https://missing.com"), isFalse);
      expect(result["https://a.com"]!.title, "A");
      expect(result["https://b.com"]!.title, "B");
    });

    test("getWebMetadataForUrls returns empty map for empty input",
        () async {
      // Regression: must not issue a SQL query at all for empty input —
      // the suggestion-builder hot path frequently has nothing to fetch
      // after the parallel search already filled metadataByUrl.
      final result = await database.getWebMetadataForUrls(const []);
      expect(result, isEmpty);
    });

    test("getWebMetadataRefresh returns null for unknown URL", () async {
      final result =
          await database.getWebMetadataRefresh("https://unknown.com");

      expect(result, isNull);
    });

    test("upsertWebMetadataRefresh round-trips retry state", () async {
      final lastAttemptAt = DateTime(2026, 8, 9, 10, 30);
      final nextRetryAt = DateTime(2026, 8, 9, 11, 30);

      await database.upsertWebMetadataRefresh(
        url: "https://example.com",
        lastAttemptAt: lastAttemptAt,
        lastFailureKind: "serverError",
        lastStatusCode: 503,
        consecutiveFailures: 3,
        nextRetryAt: nextRetryAt,
      );

      final result =
          await database.getWebMetadataRefresh("https://example.com");
      expect(result, isNotNull);
      expect(result!.url, "https://example.com");
      expect(result.lastAttemptAt, lastAttemptAt);
      expect(result.lastFailureKind, "serverError");
      expect(result.lastStatusCode, 503);
      expect(result.consecutiveFailures, 3);
      expect(result.nextRetryAt, nextRetryAt);
    });

    test("upsertWebMetadataRefresh updates the same retry URL", () async {
      await database.upsertWebMetadataRefresh(
        url: "https://example.com",
        lastAttemptAt: DateTime(2026, 8, 9, 10),
        lastFailureKind: "timeout",
        lastStatusCode: null,
        consecutiveFailures: 1,
        nextRetryAt: DateTime(2026, 8, 9, 10, 5),
      );
      final updatedAttempt = DateTime(2026, 8, 9, 12);
      await database.upsertWebMetadataRefresh(
        url: "https://example.com",
        lastAttemptAt: updatedAttempt,
        lastFailureKind: null,
        lastStatusCode: null,
        consecutiveFailures: 0,
        nextRetryAt: null,
      );

      final result =
          await database.getWebMetadataRefresh("https://example.com");
      expect(result, isNotNull);
      expect(result!.lastAttemptAt, updatedAttempt);
      expect(result.lastFailureKind, isNull);
      expect(result.lastStatusCode, isNull);
      expect(result.consecutiveFailures, 0);
      expect(result.nextRetryAt, isNull);
      final rows =
          await database.select(database.webMetadataRefreshEntries).get();
      expect(rows, hasLength(1));
    });

    test("removeWebMetadataRefresh deletes only the targeted URL", () async {
      for (final url in ["https://keep.com", "https://delete.com"]) {
        await database.upsertWebMetadataRefresh(
          url: url,
          lastAttemptAt: DateTime(2026, 8, 9),
          lastFailureKind: "timeout",
          lastStatusCode: null,
          consecutiveFailures: 1,
          nextRetryAt: null,
        );
      }

      await database.removeWebMetadataRefresh("https://delete.com");

      expect(
          await database.getWebMetadataRefresh("https://keep.com"), isNotNull);
      expect(
          await database.getWebMetadataRefresh("https://delete.com"), isNull);
    });

    test("clearing retry rows preserves verified metadata snapshots", () async {
      await database.upsertWebMetadata(
        url: "https://example.com",
        title: "Verified",
        description: null,
        image: null,
        resolvedUrl: "https://example.com/final",
        etag: '"verified"',
        lastModified: null,
        contentHash: "sha256:verified",
        fetchedAt: DateTime(2026, 8, 9),
      );
      await database.upsertWebMetadataRefresh(
        url: "https://example.com",
        lastAttemptAt: DateTime(2026, 8, 9, 1),
        lastFailureKind: "serverError",
        lastStatusCode: 500,
        consecutiveFailures: 2,
        nextRetryAt: DateTime(2026, 8, 9, 2),
      );

      await database.clearAllWebMetadataRefresh();

      expect(
          await database.getWebMetadataRefresh("https://example.com"), isNull);
      final snapshot = await database.getWebMetadata("https://example.com");
      expect(snapshot, isNotNull);
      expect(snapshot!.title, "Verified");
      expect(snapshot.contentHash, "sha256:verified");
    });

    test("schema v12 indexes exist", () async {
      final indexes = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND name IN ('metadata_records_item_idx', 'activity_events_occurred_idx')",
          )
          .get();
      final names = indexes.map((r) => r.data["name"] as String).toSet();
      expect(names, contains("metadata_records_item_idx"));
      expect(names, contains("activity_events_occurred_idx"));
    });
  });
}
