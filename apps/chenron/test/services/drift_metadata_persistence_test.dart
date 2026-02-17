import "package:chenron/services/drift_metadata_persistence.dart";
import "package:database/main.dart";
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
    await database.delete(database.webMetadataEntries).go();
    await database.close();
  });

  group("DriftMetadataPersistence", () {
    group("get", () {
      test("returns null for unknown URL", () async {
        final result = await persistence.get("https://unknown.com");
        expect(result, isNull);
      });

      test("returns map with correct keys after set", () async {
        await persistence.set("https://example.com", {
          "title": "Example",
          "description": "A page",
          "image": "https://example.com/og.png",
        });

        final result = await persistence.get("https://example.com");
        expect(result, isNotNull);
        expect(result!["title"], "Example");
        expect(result["description"], "A page");
        expect(result["image"], "https://example.com/og.png");
        expect(result["url"], "https://example.com");
        expect(result["fetchedAt"], isA<String>());
      });

      test("fetchedAt is a valid ISO 8601 timestamp", () async {
        await persistence.set("https://example.com", {"title": "T"});

        final result = await persistence.get("https://example.com");
        final parsed = DateTime.tryParse(result!["fetchedAt"] as String);
        expect(parsed, isNotNull);
        // Should be recent (within last minute)
        expect(
          DateTime.now().difference(parsed!).inSeconds.abs(),
          lessThan(60),
        );
      });

      test("preserves null fields in round-trip", () async {
        await persistence.set("https://minimal.com", {
          "title": null,
          "description": null,
          "image": null,
        });

        final result = await persistence.get("https://minimal.com");
        expect(result, isNotNull);
        expect(result!["title"], isNull);
        expect(result["description"], isNull);
        expect(result["image"], isNull);
        // url is always populated from the key
        expect(result["url"], "https://minimal.com");
      });

      test("ignores extra fields in input map", () async {
        await persistence.set("https://example.com", {
          "title": "Title",
          "description": "Desc",
          "image": "img.png",
          "extraField": "should be ignored",
          "fetchedAt": "2020-01-01T00:00:00.000Z", // should use DateTime.now()
        });

        final result = await persistence.get("https://example.com");
        expect(result, isNotNull);
        expect(result!["title"], "Title");
        // fetchedAt should be the actual insert time, not the input value
        final parsed = DateTime.parse(result["fetchedAt"] as String);
        expect(parsed.year, isNot(2020));
        // extraField should not appear in output
        expect(result.containsKey("extraField"), isFalse);
      });
    });

    group("set", () {
      test("upserts on same URL", () async {
        await persistence.set("https://a.com", {"title": "V1"});
        await persistence.set("https://a.com", {"title": "V2"});

        final result = await persistence.get("https://a.com");
        expect(result!["title"], "V2");
        expect(await persistence.count(), 1);
      });

      test("stores different URLs independently", () async {
        await persistence.set("https://a.com", {"title": "A"});
        await persistence.set("https://b.com", {"title": "B"});

        expect((await persistence.get("https://a.com"))!["title"], "A");
        expect((await persistence.get("https://b.com"))!["title"], "B");
        expect(await persistence.count(), 2);
      });
    });

    group("remove", () {
      test("removes existing entry", () async {
        await persistence.set("https://a.com", {"title": "A"});
        await persistence.remove("https://a.com");

        expect(await persistence.get("https://a.com"), isNull);
      });

      test("does not affect other entries", () async {
        await persistence.set("https://a.com", {"title": "A"});
        await persistence.set("https://b.com", {"title": "B"});

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
          await persistence.set("https://site$i.com", {"title": "S$i"});
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
        await persistence.set("https://a.com", {"title": "A"});
        expect(await persistence.count(), 1);

        await persistence.set("https://a.com", {"title": "A2"});
        expect(await persistence.count(), 1);

        await persistence.set("https://b.com", {"title": "B"});
        expect(await persistence.count(), 2);
      });

      test("decrements on remove", () async {
        await persistence.set("https://a.com", {"title": "A"});
        await persistence.set("https://b.com", {"title": "B"});
        expect(await persistence.count(), 2);

        await persistence.remove("https://a.com");
        expect(await persistence.count(), 1);
      });
    });
  });
}
