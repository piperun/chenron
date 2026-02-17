import "package:database/main.dart";
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
        fetchedAt: now,
      );

      final result = await database.getWebMetadata("https://example.com");
      expect(result, isNotNull);
      expect(result!.url, "https://example.com");
      expect(result.title, "Example");
      expect(result.description, "An example page");
      expect(result.image, "https://example.com/og.png");
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
  });
}
