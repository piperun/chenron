import "package:database/main.dart";
import "package:database/models/document_file_type.dart";
import "package:database/models/folder.dart";
import "package:database/src/features/link/create.dart";
import "package:database/src/features/link/remove.dart";
import "package:database/src/features/folder/create.dart";
import "package:database/src/features/folder/remove.dart";
import "package:database/src/features/document/create.dart";
import "package:database/src/features/document/remove.dart";
import "package:database/src/features/tag/create.dart";
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
    // Delete entities first (triggers will fire and create more events)
    final metadataRecords = database.metadataRecords;
    await database.delete(metadataRecords).go();
    final items = database.items;
    await database.delete(items).go();
    final links = database.links;
    await database.delete(links).go();
    final documents = database.documents;
    await database.delete(documents).go();
    final folders = database.folders;
    await database.delete(folders).go();
    final tags = database.tags;
    await database.delete(tags).go();
    // Clean activity_events LAST to also remove trigger-generated events from above
    final activityEvents = database.activityEvents;
    await database.delete(activityEvents).go();
    await database.close();
  });

  /// Helper to query activity events filtered by eventType and entityType
  Future<List<ActivityEvent>> getEventsByType(
    AppDatabase db, {
    required String eventType,
    required String entityType,
  }) async {
    final activityEvents = db.activityEvents;
    return (db.select(activityEvents)
          ..where((t) => t.eventType.equals(eventType))
          ..where((t) => t.entityType.equals(entityType)))
        .get();
  }

  group("Link Activity Triggers", () {
    test("AFTER INSERT on links creates link_created event", () async {
      final result = await database.createLink(link: "https://example.com");

      final events = await getEventsByType(
        database,
        eventType: "link_created",
        entityType: "link",
      );

      expect(events, matcher.isNotEmpty);
      final event = events.first;
      expect(event.entityId, equals(result.linkId));
      expect(event.occurredAt, matcher.isNotNull);
    });

    test("AFTER DELETE on links creates link_deleted event", () async {
      final result = await database.createLink(link: "https://example.com");
      final linkId = result.linkId;

      await database.removeLink(linkId);

      final events = await getEventsByType(
        database,
        eventType: "link_deleted",
        entityType: "link",
      );

      expect(events, matcher.isNotEmpty);
      final event = events.first;
      expect(event.entityId, equals(linkId));
    });
  });

  group("Document Activity Triggers", () {
    test("AFTER INSERT on documents creates document_created event",
        () async {
      final result = await database.createDocument(
        title: "Test Document",
        filePath: "/doc/test.pdf",
        fileType: DocumentFileType.pdf,
      );

      final events = await getEventsByType(
        database,
        eventType: "document_created",
        entityType: "document",
      );

      expect(events, matcher.isNotEmpty);
      final event = events.first;
      expect(event.entityId, equals(result.documentId));
    });

    test("AFTER DELETE on documents creates document_deleted event",
        () async {
      final result = await database.createDocument(
        title: "Test Document",
        filePath: "/doc/test.pdf",
        fileType: DocumentFileType.pdf,
      );
      final docId = result.documentId;

      await database.removeDocument(docId);

      final events = await getEventsByType(
        database,
        eventType: "document_deleted",
        entityType: "document",
      );

      expect(events, matcher.isNotEmpty);
      final event = events.first;
      expect(event.entityId, equals(docId));
    });
  });

  group("Folder Activity Triggers", () {
    test("AFTER INSERT on folders creates folder_created event", () async {
      final result = await database.createFolder(
        folderInfo: FolderDraft(
          title: "Test Folder",
          description: "Testing triggers",
        ),
      );

      final events = await getEventsByType(
        database,
        eventType: "folder_created",
        entityType: "folder",
      );

      expect(events, matcher.isNotEmpty);
      final event = events.first;
      expect(event.entityId, equals(result.folderId));
    });

    test("AFTER DELETE on folders creates folder_deleted event", () async {
      final result = await database.createFolder(
        folderInfo: FolderDraft(
          title: "Test Folder",
          description: "Testing triggers",
        ),
      );
      final folderId = result.folderId;

      await database.removeFolder(folderId);

      final events = await getEventsByType(
        database,
        eventType: "folder_deleted",
        entityType: "folder",
      );

      expect(events, matcher.isNotEmpty);
      final event = events.first;
      expect(event.entityId, equals(folderId));
    });
  });

  group("Tag Activity Triggers", () {
    test("AFTER INSERT on tags creates tag_created event", () async {
      final tagId = await database.addTag("trig-test");

      final events = await getEventsByType(
        database,
        eventType: "tag_created",
        entityType: "tag",
      );

      expect(events, matcher.isNotEmpty);
      final event = events.first;
      expect(event.entityId, equals(tagId));
    });

    test("AFTER DELETE on tags creates tag_deleted event", () async {
      final tagId = await database.addTag("tag-delete");

      // Delete the tag directly
      final tags = database.tags;
      await (database.delete(tags)..where((t) => t.id.equals(tagId))).go();

      final events = await getEventsByType(
        database,
        eventType: "tag_deleted",
        entityType: "tag",
      );

      expect(events, matcher.isNotEmpty);
      final event = events.first;
      expect(event.entityId, equals(tagId));
    });
  });

  group("Trigger ID and Timestamp Validation", () {
    test("trigger-generated IDs are 30-char lowercase hex strings", () async {
      await database.createLink(link: "https://example.com");

      final events = await getEventsByType(
        database,
        eventType: "link_created",
        entityType: "link",
      );

      expect(events, matcher.isNotEmpty);
      final event = events.first;
      expect(event.id.length, equals(30));
      expect(
        RegExp(r"^[0-9a-f]{30}$").hasMatch(event.id),
        matcher.isTrue,
        reason: "ID should be a 30-char lowercase hex string",
      );
    });

    test("trigger-generated IDs are unique across events", () async {
      await database.createLink(link: "https://flutter.dev");
      await database.createLink(link: "https://dart.dev");
      await database.addTag("uid-test");

      final activityEvents = database.activityEvents;
      final events = await database.select(activityEvents).get();

      final ids = events.map((e) => e.id).toSet();
      expect(ids.length, equals(events.length),
          reason: "All trigger-generated IDs should be unique");
    });

    test("trigger timestamps are set correctly", () async {
      final before = DateTime.now().subtract(const Duration(seconds: 2));

      await database.createLink(link: "https://example.com");

      final after = DateTime.now().add(const Duration(seconds: 2));

      final events = await getEventsByType(
        database,
        eventType: "link_created",
        entityType: "link",
      );

      expect(events, matcher.isNotEmpty);
      final event = events.first;
      expect(event.occurredAt.isAfter(before), matcher.isTrue,
          reason: "Event timestamp should be after test start");
      expect(event.occurredAt.isBefore(after), matcher.isTrue,
          reason: "Event timestamp should be before test end");
    });
  });

  group("Multiple Triggers in Sequence", () {
    test("creating and deleting an entity produces both events", () async {
      final result = await database.createLink(link: "https://example.com");
      final linkId = result.linkId;

      await database.removeLink(linkId);

      // Query all events for this entity
      final activityEvents = database.activityEvents;
      final events = await (database.select(activityEvents)
            ..where((t) => t.entityId.equals(linkId)))
          .get();

      expect(events.length, equals(2));

      final eventTypes = events.map((e) => e.eventType).toSet();
      expect(eventTypes.contains("link_created"), matcher.isTrue);
      expect(eventTypes.contains("link_deleted"), matcher.isTrue);
    });

    test("creating multiple entity types produces correct events", () async {
      await database.createLink(link: "https://example.com");
      await database.createDocument(
        title: "Test Doc",
        filePath: "/doc/test.md",
        fileType: DocumentFileType.markdown,
      );
      await database.createFolder(
        folderInfo: FolderDraft(
          title: "Test Folder",
          description: "Testing",
        ),
      );
      await database.addTag("multi-trig");

      final activityEvents = database.activityEvents;
      final events = await database.select(activityEvents).get();

      // Should have at least 4 "created" events
      expect(events.length, matcher.greaterThanOrEqualTo(4));

      final eventTypes = events.map((e) => e.eventType).toSet();
      expect(eventTypes.contains("link_created"), matcher.isTrue);
      expect(eventTypes.contains("document_created"), matcher.isTrue);
      expect(eventTypes.contains("folder_created"), matcher.isTrue);
      expect(eventTypes.contains("tag_created"), matcher.isTrue);
    });
  });
}
