import "package:database/main.dart";
import "package:database/src/features/statistics/recent_access.dart";
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
    final recentAccess = database.recentAccess;
    await database.delete(recentAccess).go();
    await database.close();
  });

  group("recordItemAccess() UPSERT Operations", () {
    test("inserts new access record on first access", () async {
      await database.recordItemAccess(
        entityId: "link-1",
        entityType: "link",
      );

      final recentAccess = database.recentAccess;
      final records = await database.select(recentAccess).get();

      expect(records.length, equals(1));
      expect(records.first.entityId, equals("link-1"));
      expect(records.first.entityType, equals("link"));
      expect(records.first.accessCount, equals(1));
      expect(records.first.lastAccessedAt, matcher.isNotNull);
    });

    test("increments accessCount on repeated access", () async {
      await database.recordItemAccess(
        entityId: "link-1",
        entityType: "link",
      );
      await database.recordItemAccess(
        entityId: "link-1",
        entityType: "link",
      );
      await database.recordItemAccess(
        entityId: "link-1",
        entityType: "link",
      );

      final recentAccess = database.recentAccess;
      final records = await (database.select(recentAccess)
            ..where((t) => t.entityId.equals("link-1")))
          .get();

      expect(records.length, equals(1));
      expect(records.first.accessCount, equals(3));
    });

    test("updates lastAccessedAt on repeated access", () async {
      await database.recordItemAccess(
        entityId: "link-1",
        entityType: "link",
      );

      final recentAccess = database.recentAccess;
      final firstRecord = await (database.select(recentAccess)
            ..where((t) => t.entityId.equals("link-1")))
          .getSingle();

      final firstAccessedAt = firstRecord.lastAccessedAt;

      await Future.delayed(const Duration(milliseconds: 1100));

      await database.recordItemAccess(
        entityId: "link-1",
        entityType: "link",
      );

      final updatedRecord = await (database.select(recentAccess)
            ..where((t) => t.entityId.equals("link-1")))
          .getSingle();

      expect(
        updatedRecord.lastAccessedAt
            .isAfter(firstAccessedAt.subtract(const Duration(seconds: 1))),
        matcher.isTrue,
      );
    });

    test("handles different entityIds independently", () async {
      await database.recordItemAccess(
        entityId: "link-1",
        entityType: "link",
      );
      await database.recordItemAccess(
        entityId: "link-2",
        entityType: "link",
      );

      final recentAccess = database.recentAccess;
      final records = await database.select(recentAccess).get();

      expect(records.length, equals(2));
      expect(records.every((r) => r.accessCount == 1), matcher.isTrue);
    });

    test("composite key: same entityId with different entityTypes", () async {
      await database.recordItemAccess(
        entityId: "id-1",
        entityType: "link",
      );
      await database.recordItemAccess(
        entityId: "id-1",
        entityType: "document",
      );

      final recentAccess = database.recentAccess;
      final records = await database.select(recentAccess).get();

      expect(records.length, equals(2));

      final linkRecord =
          records.where((r) => r.entityType == "link").first;
      final docRecord =
          records.where((r) => r.entityType == "document").first;

      expect(linkRecord.accessCount, equals(1));
      expect(docRecord.accessCount, equals(1));
    });
  });

  group("getRecentlyViewed() Query Operations", () {
    test("returns items sorted by lastAccessedAt DESC", () async {
      await database.recordItemAccess(
        entityId: "first",
        entityType: "link",
      );
      await Future.delayed(const Duration(milliseconds: 1100));
      await database.recordItemAccess(
        entityId: "second",
        entityType: "link",
      );
      await Future.delayed(const Duration(milliseconds: 1100));
      await database.recordItemAccess(
        entityId: "third",
        entityType: "link",
      );

      final results = await database.getRecentlyViewed();

      expect(results.length, equals(3));
      expect(results[0].entityId, equals("third"));
      expect(results[1].entityId, equals("second"));
      expect(results[2].entityId, equals("first"));
    });

    test("respects limit parameter", () async {
      for (int i = 0; i < 5; i++) {
        await database.recordItemAccess(
          entityId: "item-$i",
          entityType: "link",
        );
        await Future.delayed(const Duration(milliseconds: 1100));
      }

      final results = await database.getRecentlyViewed(limit: 3);

      expect(results.length, equals(3));
    });

    test("default limit is 10", () async {
      for (int i = 0; i < 15; i++) {
        await database.recordItemAccess(
          entityId: "item-$i",
          entityType: "link",
        );
      }

      final results = await database.getRecentlyViewed();

      expect(results.length, equals(10));
    });

    test("filters by entityType", () async {
      await database.recordItemAccess(
        entityId: "link-1",
        entityType: "link",
      );
      await database.recordItemAccess(
        entityId: "link-2",
        entityType: "link",
      );
      await database.recordItemAccess(
        entityId: "doc-1",
        entityType: "document",
      );

      final results = await database.getRecentlyViewed(entityType: "link");

      expect(results.length, equals(2));
      for (final result in results) {
        expect(result.entityType, equals("link"));
      }
    });

    test("returns empty list when no records exist", () async {
      final results = await database.getRecentlyViewed();

      expect(results, matcher.isEmpty);
    });
  });

  group("getMostAccessed() Query Operations", () {
    test("returns items sorted by accessCount DESC", () async {
      // item-a: 1 access
      await database.recordItemAccess(
        entityId: "item-a",
        entityType: "link",
      );

      // item-b: 5 accesses
      for (int i = 0; i < 5; i++) {
        await database.recordItemAccess(
          entityId: "item-b",
          entityType: "link",
        );
      }

      // item-c: 3 accesses
      for (int i = 0; i < 3; i++) {
        await database.recordItemAccess(
          entityId: "item-c",
          entityType: "link",
        );
      }

      final results = await database.getMostAccessed();

      expect(results.length, equals(3));
      expect(results[0].entityId, equals("item-b"));
      expect(results[0].accessCount, equals(5));
      expect(results[1].entityId, equals("item-c"));
      expect(results[1].accessCount, equals(3));
      expect(results[2].entityId, equals("item-a"));
      expect(results[2].accessCount, equals(1));
    });

    test("respects limit parameter", () async {
      for (int i = 0; i < 5; i++) {
        await database.recordItemAccess(
          entityId: "item-$i",
          entityType: "link",
        );
      }

      final results = await database.getMostAccessed(limit: 2);

      expect(results.length, equals(2));
    });

    test("filters by entityType", () async {
      await database.recordItemAccess(
        entityId: "link-1",
        entityType: "link",
      );
      await database.recordItemAccess(
        entityId: "doc-1",
        entityType: "document",
      );
      await database.recordItemAccess(
        entityId: "doc-2",
        entityType: "document",
      );

      final results = await database.getMostAccessed(entityType: "document");

      expect(results.length, equals(2));
      for (final result in results) {
        expect(result.entityType, equals("document"));
      }
    });

    test("returns empty list when no records exist", () async {
      final results = await database.getMostAccessed();

      expect(results, matcher.isEmpty);
    });
  });
}
