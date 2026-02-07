import "package:database/main.dart";
import "package:database/src/features/statistics/activity.dart";
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
    final activityEvents = database.activityEvents;
    await database.delete(activityEvents).go();
    await database.close();
  });

  group("recordActivity() Basic Operations", () {
    test("records activity event with all fields", () async {
      await database.recordActivity(
        eventType: "link_created",
        entityType: "link",
        entityId: "test-entity-id",
      );

      final activityEvents = database.activityEvents;
      final events = await database.select(activityEvents).get();

      expect(events.length, equals(1));
      expect(events.first.eventType, equals("link_created"));
      expect(events.first.entityType, equals("link"));
      expect(events.first.entityId, equals("test-entity-id"));
      expect(events.first.id, matcher.isNotEmpty);
      expect(events.first.occurredAt, matcher.isNotNull);
    });

    test("records activity event without entityId", () async {
      await database.recordActivity(
        eventType: "tag_created",
        entityType: "tag",
      );

      final activityEvents = database.activityEvents;
      final events = await database.select(activityEvents).get();

      expect(events.length, equals(1));
      expect(events.first.eventType, equals("tag_created"));
      expect(events.first.entityType, equals("tag"));
      expect(events.first.entityId, matcher.isNull);
    });

    test("records multiple events with unique IDs", () async {
      await database.recordActivity(
        eventType: "link_created",
        entityType: "link",
        entityId: "link-1",
      );
      await database.recordActivity(
        eventType: "document_created",
        entityType: "document",
        entityId: "doc-1",
      );
      await database.recordActivity(
        eventType: "folder_created",
        entityType: "folder",
        entityId: "folder-1",
      );

      final activityEvents = database.activityEvents;
      final events = await database.select(activityEvents).get();

      expect(events.length, equals(3));

      final ids = events.map((e) => e.id).toSet();
      expect(ids.length, equals(3), reason: "All IDs should be unique");
    });
  });

  group("getActivityEvents() Query Operations", () {
    test("returns all events with no filters", () async {
      await database.recordActivity(
        eventType: "link_created",
        entityType: "link",
        entityId: "link-1",
      );
      await database.recordActivity(
        eventType: "tag_created",
        entityType: "tag",
        entityId: "tag-1",
      );
      await database.recordActivity(
        eventType: "document_created",
        entityType: "document",
        entityId: "doc-1",
      );

      final events = await database.getActivityEvents();

      expect(events.length, equals(3));
    });

    test("returns events ordered by occurredAt DESC", () async {
      await database.recordActivity(
        eventType: "first",
        entityType: "link",
      );
      await Future.delayed(const Duration(milliseconds: 1100));
      await database.recordActivity(
        eventType: "second",
        entityType: "link",
      );

      final events = await database.getActivityEvents();

      expect(events.length, equals(2));
      expect(events.first.eventType, equals("second"));
      expect(events.last.eventType, equals("first"));
    });

    test("filters by entityType", () async {
      await database.recordActivity(
        eventType: "link_created",
        entityType: "link",
      );
      await database.recordActivity(
        eventType: "link_viewed",
        entityType: "link",
      );
      await database.recordActivity(
        eventType: "tag_created",
        entityType: "tag",
      );

      final events = await database.getActivityEvents(entityType: "link");

      expect(events.length, equals(2));
      for (final event in events) {
        expect(event.entityType, equals("link"));
      }
    });

    test("filters by startDate", () async {
      await database.recordActivity(
        eventType: "old_event",
        entityType: "link",
      );
      await Future.delayed(const Duration(milliseconds: 1100));

      final cutoff = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 1100));

      await database.recordActivity(
        eventType: "new_event",
        entityType: "link",
      );

      final events = await database.getActivityEvents(startDate: cutoff);

      expect(events.length, equals(1));
      expect(events.first.eventType, equals("new_event"));
    });

    test("filters by endDate", () async {
      await database.recordActivity(
        eventType: "old_event",
        entityType: "link",
      );
      await Future.delayed(const Duration(milliseconds: 1100));

      final cutoff = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 1100));

      await database.recordActivity(
        eventType: "new_event",
        entityType: "link",
      );

      final events = await database.getActivityEvents(endDate: cutoff);

      expect(events.length, equals(1));
      expect(events.first.eventType, equals("old_event"));
    });

    test("filters by date range", () async {
      await database.recordActivity(
        eventType: "before",
        entityType: "link",
      );
      await Future.delayed(const Duration(milliseconds: 1100));

      final start = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 1100));

      await database.recordActivity(
        eventType: "in_range",
        entityType: "link",
      );
      await Future.delayed(const Duration(milliseconds: 1100));

      final end = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 1100));

      await database.recordActivity(
        eventType: "after",
        entityType: "link",
      );

      final events = await database.getActivityEvents(
        startDate: start,
        endDate: end,
      );

      expect(events.length, equals(1));
      expect(events.first.eventType, equals("in_range"));
    });

    test("returns empty list when no events match entityType", () async {
      await database.recordActivity(
        eventType: "link_created",
        entityType: "link",
      );

      final events =
          await database.getActivityEvents(entityType: "nonexistent");

      expect(events, matcher.isEmpty);
    });

    test("returns empty list when database is empty", () async {
      final events = await database.getActivityEvents();

      expect(events, matcher.isEmpty);
    });

    test("combines entityType with date filters", () async {
      await database.recordActivity(
        eventType: "link_created",
        entityType: "link",
      );
      await database.recordActivity(
        eventType: "tag_created",
        entityType: "tag",
      );
      await Future.delayed(const Duration(milliseconds: 1100));

      final start = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 1100));

      await database.recordActivity(
        eventType: "link_viewed",
        entityType: "link",
      );
      await database.recordActivity(
        eventType: "tag_deleted",
        entityType: "tag",
      );

      final events = await database.getActivityEvents(
        entityType: "link",
        startDate: start,
      );

      expect(events.length, equals(1));
      expect(events.first.eventType, equals("link_viewed"));
    });
  });

  group("getActivityCountsByType() Aggregation", () {
    test("returns counts grouped by eventType", () async {
      final now = DateTime.now();
      final start = now.subtract(const Duration(hours: 1));
      final end = now.add(const Duration(hours: 1));

      await database.recordActivity(
          eventType: "link_created", entityType: "link");
      await database.recordActivity(
          eventType: "link_created", entityType: "link");
      await database.recordActivity(
          eventType: "link_created", entityType: "link");
      await database.recordActivity(
          eventType: "tag_created", entityType: "tag");
      await database.recordActivity(
          eventType: "tag_created", entityType: "tag");
      await database.recordActivity(
          eventType: "folder_created", entityType: "folder");

      final counts = await database.getActivityCountsByType(
        startDate: start,
        endDate: end,
      );

      expect(counts["link_created"], equals(3));
      expect(counts["tag_created"], equals(2));
      expect(counts["folder_created"], equals(1));
    });

    test("returns empty map when no events in range", () async {
      await database.recordActivity(
          eventType: "link_created", entityType: "link");

      final futureStart = DateTime.now().add(const Duration(hours: 1));
      final futureEnd = DateTime.now().add(const Duration(hours: 2));

      final counts = await database.getActivityCountsByType(
        startDate: futureStart,
        endDate: futureEnd,
      );

      expect(counts, matcher.isEmpty);
    });

    test("returns empty map on empty database", () async {
      final counts = await database.getActivityCountsByType(
        startDate: DateTime.now().subtract(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(counts, matcher.isEmpty);
    });
  });

  group("getDailyActivityCounts() Timeline", () {
    test("returns daily counts grouped by date and entityType", () async {
      final now = DateTime.now();
      final start = now.subtract(const Duration(hours: 1));
      final end = now.add(const Duration(hours: 1));

      await database.recordActivity(
          eventType: "link_created", entityType: "link");
      await database.recordActivity(
          eventType: "link_viewed", entityType: "link");
      await database.recordActivity(
          eventType: "tag_created", entityType: "tag");

      final counts = await database.getDailyActivityCounts(
        startDate: start,
        endDate: end,
      );

      expect(counts, matcher.isNotEmpty);

      // All events are today, so we should have entries for "link" and "tag"
      final linkCounts =
          counts.where((c) => c.entityType == "link").toList();
      final tagCounts =
          counts.where((c) => c.entityType == "tag").toList();

      expect(linkCounts.length, equals(1));
      expect(linkCounts.first.count, equals(2));
      expect(tagCounts.length, equals(1));
      expect(tagCounts.first.count, equals(1));
    });

    test("returns empty list when no events in range", () async {
      final counts = await database.getDailyActivityCounts(
        startDate: DateTime.now().subtract(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(counts, matcher.isEmpty);
    });
  });

  group("watchRecentActivity() Stream", () {
    test("emits empty list when no events exist", () async {
      final stream = database.watchRecentActivity();

      await expectLater(
        stream,
        emits(predicate<List<ActivityEvent>>(
            (events) => events.isEmpty)),
      );
    });

    test("emits events after recording activity", () async {
      final stream = database.watchRecentActivity();

      await database.recordActivity(
        eventType: "link_created",
        entityType: "link",
        entityId: "link-1",
      );

      await expectLater(
        stream,
        emitsThrough(predicate<List<ActivityEvent>>(
            (events) =>
                events.isNotEmpty &&
                events.first.eventType == "link_created")),
      );
    });

    test("respects limit parameter", () async {
      for (int i = 0; i < 5; i++) {
        await database.recordActivity(
          eventType: "event_$i",
          entityType: "link",
        );
      }

      final stream = database.watchRecentActivity(limit: 3);

      await expectLater(
        stream,
        emits(predicate<List<ActivityEvent>>(
            (events) => events.length == 3)),
      );
    });

    test("emits latest events", () async {
      await database.recordActivity(
        eventType: "first",
        entityType: "link",
      );
      await database.recordActivity(
        eventType: "second",
        entityType: "link",
      );

      final stream = database.watchRecentActivity();

      await expectLater(
        stream,
        emits(predicate<List<ActivityEvent>>(
            (events) => events.length == 2)),
      );
    });
  });
}
