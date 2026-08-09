import "package:cache_manager/cache_manager.dart";
import "package:chenron/services/drift_metadata_persistence.dart";
import "package:database/database.dart" hide Metadata;
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;
  late DriftMetadataPersistence persistence;

  setUp(() {
    database = AppDatabase(
      databaseName: "test_db",
      setupOnInit: true,
      debugMode: true,
    );
    persistence = DriftMetadataPersistence(database);
  });

  tearDown(() async {
    await database.customStatement(
      "DROP TRIGGER IF EXISTS prevent_refresh_clear",
    );
    await database.delete(database.webMetadataRefreshEntries).go();
    await database.delete(database.webMetadataEntries).go();
    await database.close();
  });

  /// Helper — build a [Metadata] with sensible defaults so tests focus
  /// on the fields that vary.
  Metadata build(
    String url, {
    String? title,
    String? description,
    String? imageUrl,
    String? resolvedUrl,
    DateTime? fetchedAt,
    int ttlDays = 7,
    String? etag,
    String? lastModified,
    String? contentHash,
    int consecutiveUnchanged = 0,
  }) {
    return Metadata(
      url: url,
      title: title,
      description: description,
      imageUrl: imageUrl,
      resolvedUrl: resolvedUrl,
      fetchedAt: fetchedAt ?? DateTime.now(),
      ttlDays: ttlDays,
      etag: etag,
      lastModified: lastModified,
      contentHash: contentHash,
      consecutiveUnchanged: consecutiveUnchanged,
    );
  }

  group("DriftMetadataPersistence", () {
    group("get", () {
      test("returns null for unknown URL", () async {
        final result = await persistence.get("https://unknown.com");
        expect(result, isNull);
      });

      test("returns Metadata with correct fields after set", () async {
        await persistence.set(build(
          "https://example.com",
          title: "Example",
          description: "A page",
          imageUrl: "https://example.com/og.png",
        ));

        final result = await persistence.get("https://example.com");
        expect(result, isNotNull);
        expect(result!.title, "Example");
        expect(result.description, "A page");
        expect(result.imageUrl, "https://example.com/og.png");
        expect(result.url, "https://example.com");
        expect(result.fetchedAt, isA<DateTime>());
      });

      test("fetchedAt round-trips", () async {
        final when = DateTime.now();
        await persistence
            .set(build("https://example.com", title: "T", fetchedAt: when));

        final result = await persistence.get("https://example.com");
        expect(result, isNotNull);
        // Drift stores DateTimes with second-level resolution; compare
        // within a small tolerance.
        expect(
          result!.fetchedAt.difference(when).inSeconds.abs(),
          lessThanOrEqualTo(1),
        );
      });

      test("preserves null fields in round-trip", () async {
        await persistence.set(build("https://minimal.com"));

        final result = await persistence.get("https://minimal.com");
        expect(result, isNotNull);
        expect(result!.title, isNull);
        expect(result.description, isNull);
        expect(result.imageUrl, isNull);
        expect(result.url, "https://minimal.com");
      });

      test("preserves consecutiveUnchanged and ttlDays", () async {
        await persistence.set(build(
          "https://x.com",
          title: "X",
          consecutiveUnchanged: 4,
          ttlDays: 21,
        ));

        final result = await persistence.get("https://x.com");
        expect(result!.consecutiveUnchanged, 4);
        expect(result.ttlDays, 21);
      });
      test("round-trips every snapshot validator field", () async {
        final fetchedAt = DateTime.utc(2026, 8, 9, 10, 30);
        await persistence.set(build(
          "https://example.com/original",
          title: "Title",
          description: "Description",
          imageUrl: "https://cdn.example.com/image.png",
          resolvedUrl: "https://example.com/resolved",
          fetchedAt: fetchedAt,
          ttlDays: 21,
          etag: '"validator"',
          lastModified: "Sun, 09 Aug 2026 10:00:00 GMT",
          contentHash: "sha256:abc123",
          consecutiveUnchanged: 4,
        ));

        final result = await persistence.get("https://example.com/original");

        expect(result!.url, "https://example.com/original");
        expect(result.resolvedUrl, "https://example.com/resolved");
        expect(result.title, "Title");
        expect(result.description, "Description");
        expect(result.imageUrl, "https://cdn.example.com/image.png");
        expect(result.fetchedAt, fetchedAt);
        expect(result.ttlDays, 21);
        expect(result.etag, '"validator"');
        expect(result.lastModified, "Sun, 09 Aug 2026 10:00:00 GMT");
        expect(result.contentHash, "sha256:abc123");
        expect(result.consecutiveUnchanged, 4);
      });
    });

    group("set", () {
      test("upserts on same URL", () async {
        await persistence.set(build("https://a.com", title: "V1"));
        await persistence.set(build("https://a.com", title: "V2"));

        final result = await persistence.get("https://a.com");
        expect(result!.title, "V2");
        expect(await persistence.count(), 1);
      });

      test("stores different URLs independently", () async {
        await persistence.set(build("https://a.com", title: "A"));
        await persistence.set(build("https://b.com", title: "B"));

        expect((await persistence.get("https://a.com"))!.title, "A");
        expect((await persistence.get("https://b.com"))!.title, "B");
        expect(await persistence.count(), 2);
      });
    });

    group("remove", () {
      test("removes existing entry", () async {
        await persistence.set(build("https://a.com", title: "A"));
        await persistence.remove("https://a.com");

        expect(await persistence.get("https://a.com"), isNull);
      });

      test("does not affect other entries", () async {
        await persistence.set(build("https://a.com", title: "A"));
        await persistence.set(build("https://b.com", title: "B"));

        await persistence.remove("https://a.com");

        expect(await persistence.get("https://a.com"), isNull);
        expect(await persistence.get("https://b.com"), isNotNull);
      });

      test("is safe for nonexistent URL", () async {
        // Should not throw
        await persistence.remove("https://nope.com");
      });
    });

    group("clearAll", () {
      test("removes all entries", () async {
        for (var i = 0; i < 5; i++) {
          await persistence.set(build("https://site$i.com", title: "S$i"));
        }
        expect(await persistence.count(), 5);

        await persistence.clearAll();

        expect(await persistence.count(), 0);
      });

      test("is safe when already empty", () async {
        await persistence.clearAll();
        expect(await persistence.count(), 0);
      });
    });

    group("count", () {
      test("starts at zero", () async {
        expect(await persistence.count(), 0);
      });

      test("increments on insert, not on upsert", () async {
        await persistence.set(build("https://a.com", title: "A"));
        expect(await persistence.count(), 1);

        await persistence.set(build("https://a.com", title: "A2"));
        expect(await persistence.count(), 1);

        await persistence.set(build("https://b.com", title: "B"));
        expect(await persistence.count(), 2);
      });

      test("decrements on remove", () async {
        await persistence.set(build("https://a.com", title: "A"));
        await persistence.set(build("https://b.com", title: "B"));
        expect(await persistence.count(), 2);

        await persistence.remove("https://a.com");
        expect(await persistence.count(), 1);
      });
    });

    group("getExpiredEntries", () {
      test("returns entries past ttl", () async {
        final long = DateTime.now().subtract(const Duration(days: 30));
        await persistence.set(build(
          "https://stale.com",
          title: "old",
          fetchedAt: long,
          ttlDays: 7,
        ));
        await persistence.set(build(
          "https://fresh.com",
          title: "fresh",
          ttlDays: 7,
        ));

        final expired = await persistence.getExpiredEntries();
        final urls = expired.map((m) => m.url).toSet();
        expect(urls, contains("https://stale.com"));
        expect(urls.contains("https://fresh.com"), isFalse);
      });

      test("returns empty when nothing is expired", () async {
        await persistence.set(build("https://fresh.com", title: "fresh"));
        expect(await persistence.getExpiredEntries(), isEmpty);
      });
    });

    group("refresh persistence", () {
      test("round-trips every refresh record field", () async {
        final record = MetadataRefreshRecord(
          url: "https://example.com/post",
          lastAttemptAt: DateTime.utc(2026, 8, 9, 10),
          lastFailureKind: MetadataFailureKind.challenge,
          lastStatusCode: 403,
          consecutiveFailures: 4,
          nextRetryAt: DateTime.utc(2026, 8, 9, 16),
        );

        await persistence.setRefreshRecord(record);
        final result = await persistence.getRefreshRecord(record.url);

        expect(result!.url, record.url);
        expect(result.lastAttemptAt, record.lastAttemptAt);
        expect(result.lastFailureKind, MetadataFailureKind.challenge);
        expect(result.lastStatusCode, 403);
        expect(result.consecutiveFailures, 4);
        expect(result.nextRetryAt, record.nextRetryAt);
      });

      test("round-trips every failure kind by enum name", () async {
        for (final kind in MetadataFailureKind.values) {
          final url = "https://example.com/${kind.name}";
          await persistence.setRefreshRecord(MetadataRefreshRecord(
            url: url,
            lastAttemptAt: DateTime.utc(2026, 8, 9),
            lastFailureKind: kind,
            consecutiveFailures: 1,
          ));

          expect(
            (await persistence.getRefreshRecord(url))!.lastFailureKind,
            kind,
          );
        }
      });

      test("remove and refresh-only clear leave snapshots intact", () async {
        const firstUrl = "https://example.com/first";
        const secondUrl = "https://example.com/second";
        await persistence.set(build(firstUrl, title: "First"));
        for (final url in const [firstUrl, secondUrl]) {
          await persistence.setRefreshRecord(MetadataRefreshRecord(
            url: url,
            lastAttemptAt: DateTime.utc(2026, 8, 9),
            lastFailureKind: MetadataFailureKind.transport,
            consecutiveFailures: 1,
          ));
        }

        await persistence.removeRefreshRecord(firstUrl);
        expect(await persistence.getRefreshRecord(firstUrl), isNull);
        expect(await persistence.getRefreshRecord(secondUrl), isNotNull);

        await persistence.clearAllRefreshRecords();
        expect(await persistence.getRefreshRecord(secondUrl), isNull);
        expect(await persistence.get(firstUrl), isNotNull);
      });
    });

    group("combined clearAll", () {
      test("clears snapshots and refresh records", () async {
        const url = "https://example.com/post";
        await persistence.set(build(url, title: "Snapshot"));
        await persistence.setRefreshRecord(MetadataRefreshRecord(
          url: url,
          lastAttemptAt: DateTime.utc(2026, 8, 9),
          lastFailureKind: MetadataFailureKind.timeout,
          consecutiveFailures: 2,
        ));

        await persistence.clearAll();

        expect(await persistence.get(url), isNull);
        expect(await persistence.getRefreshRecord(url), isNull);
      });

      test("rolls back both deletes when either table cannot clear", () async {
        const url = "https://example.com/post";
        await persistence.set(build(url, title: "Snapshot"));
        await persistence.setRefreshRecord(MetadataRefreshRecord(
          url: url,
          lastAttemptAt: DateTime.utc(2026, 8, 9),
          lastFailureKind: MetadataFailureKind.blocked,
          consecutiveFailures: 1,
        ));
        await database.customStatement(
          "CREATE TRIGGER prevent_refresh_clear "
          "BEFORE DELETE ON web_metadata_refresh_entries "
          "BEGIN SELECT RAISE(ABORT, 'blocked'); END",
        );

        await expectLater(persistence.clearAll(), throwsA(anything));

        expect((await persistence.get(url))!.title, "Snapshot");
        expect(await persistence.getRefreshRecord(url), isNotNull);
      });
    });
  });
}
