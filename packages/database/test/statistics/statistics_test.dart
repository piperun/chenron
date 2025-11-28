import "package:database/main.dart";
import "package:database/src/core/id.dart";
import "package:flutter_test/flutter_test.dart" as matcher;
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";
import "package:drift/drift.dart";

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
    await database.close();
  });

  group("Statistics CRUD Operations", () {
    test("create statistics record", () async {
      final id = database.generateId();
      final stat = StatisticsCompanion.insert(
        id: id,
        totalLinks: const Value(10),
        totalDocuments: const Value(5),
        totalTags: const Value(3),
        totalFolders: const Value(2),
      );

      await database.statistics.insertOne(stat);

      final statistics = database.statistics;
      final retrieved = await (database.select(statistics)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      expect(retrieved, matcher.isNotNull);
      expect(retrieved!.totalLinks, equals(10));
      expect(retrieved.totalDocuments, equals(5));
      expect(retrieved.totalTags, equals(3));
      expect(retrieved.totalFolders, equals(2));
    });

    test("read statistics by ID", () async {
      final id = database.generateId();
      await database.statistics.insertOne(
        StatisticsCompanion.insert(
          id: id,
          totalLinks: const Value(25),
        ),
      );

      final statistics = database.statistics;
      final stat = await (database.select(statistics)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      expect(stat, matcher.isNotNull);
      expect(stat!.id, equals(id));
      expect(stat.totalLinks, equals(25));
    });

    test("update statistics record", () async {
      final id = database.generateId();
      await database.statistics.insertOne(
        StatisticsCompanion.insert(
          id: id,
          totalLinks: const Value(10),
        ),
      );

      final statistics = database.statistics;
      await (database.update(statistics)..where((tbl) => tbl.id.equals(id)))
          .write(const StatisticsCompanion(totalLinks: Value(20)));

      final updated = await (database.select(statistics)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      expect(updated.totalLinks, equals(20));
    });

    test("delete statistics record", () async {
      final id = database.generateId();
      await database.statistics.insertOne(
        StatisticsCompanion.insert(id: id),
      );

      final statistics = database.statistics;
      await (database.delete(statistics)..where((tbl) => tbl.id.equals(id)))
          .go();

      final deleted = await (database.select(statistics)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      expect(deleted, matcher.isNull);
    });
  });

  group("Statistics Default Values", () {
    test("all counts default to 0 when not specified", () async {
      final id = database.generateId();
      await database.statistics.insertOne(
        StatisticsCompanion.insert(id: id),
      );

      final statistics = database.statistics;
      final stat = await (database.select(statistics)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      expect(stat.totalLinks, equals(0));
      expect(stat.totalDocuments, equals(0));
      expect(stat.totalTags, equals(0));
      expect(stat.totalFolders, equals(0));
    });

    test("recordedAt is auto-set on insert", () async {
      final beforeInsert = DateTime.now();
      final id = database.generateId();

      await database.statistics.insertOne(
        StatisticsCompanion.insert(id: id),
      );

      final statistics = database.statistics;
      final stat = await (database.select(statistics)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      final afterInsert = DateTime.now();

      expect(
          stat.recordedAt
              .isAfter(beforeInsert.subtract(const Duration(seconds: 1))),
          matcher.isTrue);
      expect(
          stat.recordedAt.isBefore(afterInsert.add(const Duration(seconds: 1))),
          matcher.isTrue);
    });
  });

  group("Statistics Edge Cases", () {
    test("max integer values", () async {
      final id = database.generateId();
      const maxInt = 2147483647; // Max 32-bit signed int

      await database.statistics.insertOne(
        StatisticsCompanion.insert(
          id: id,
          totalLinks: const Value(maxInt),
          totalDocuments: const Value(maxInt),
          totalTags: const Value(maxInt),
          totalFolders: const Value(maxInt),
        ),
      );

      final statistics = database.statistics;
      final stat = await (database.select(statistics)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      expect(stat.totalLinks, equals(maxInt));
      expect(stat.totalDocuments, equals(maxInt));
      expect(stat.totalTags, equals(maxInt));
      expect(stat.totalFolders, equals(maxInt));
    });

    test("negative values (if supported)", () async {
      final id = database.generateId();

      await database.statistics.insertOne(
        StatisticsCompanion.insert(
          id: id,
          totalLinks: const Value(-1),
        ),
      );

      final statistics = database.statistics;
      final stat = await (database.select(statistics)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      expect(stat.totalLinks, equals(-1));
    });

    test("incremental updates", () async {
      final id = database.generateId();
      await database.statistics.insertOne(
        StatisticsCompanion.insert(
          id: id,
          totalLinks: const Value(10),
        ),
      );

      // Increment totalLinks
      final statistics = database.statistics;
      final current = await (database.select(statistics)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      await (database.update(statistics)..where((tbl) => tbl.id.equals(id)))
          .write(
              StatisticsCompanion(totalLinks: Value(current.totalLinks + 1)));

      final updated = await (database.select(statistics)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      expect(updated.totalLinks, equals(11));
    });

    test("multiple statistics records", () async {
      final id1 = database.generateId();
      final id2 = database.generateId();

      await database.batch((batch) {
        batch.insert(
          database.statistics,
          StatisticsCompanion.insert(id: id1, totalLinks: const Value(5)),
        );
        batch.insert(
          database.statistics,
          StatisticsCompanion.insert(id: id2, totalLinks: const Value(10)),
        );
      });

      final statistics = database.statistics;
      final allStats = await database.select(statistics).get();
      expect(allStats.length, matcher.greaterThanOrEqualTo(2));
    });
  });

  group("Statistics Query Operations", () {
    test("get latest statistics", () async {
      await Future.delayed(const Duration(milliseconds: 10));
      final id1 = database.generateId();
      await database.statistics.insertOne(
        StatisticsCompanion.insert(id: id1, totalLinks: const Value(5)),
      );

      await Future.delayed(const Duration(milliseconds: 10));
      final id2 = database.generateId();
      await database.statistics.insertOne(
        StatisticsCompanion.insert(id: id2, totalLinks: const Value(10)),
      );

      final statistics = database.statistics;
      final latest = await (database.select(statistics)
            ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
            ..limit(1))
          .getSingle();

      expect(latest.totalLinks, equals(10));
    });

    test("delete all statistics", () async {
      await database.batch((batch) {
        batch.insert(
          database.statistics,
          StatisticsCompanion.insert(id: database.generateId()),
        );
        batch.insert(
          database.statistics,
          StatisticsCompanion.insert(id: database.generateId()),
        );
      });

      final statistics = database.statistics;
      await database.delete(statistics).go();

      final allStats = await database.select(statistics).get();
      expect(allStats.length, equals(0));
    });
  });
}
