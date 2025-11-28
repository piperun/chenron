import "package:database/main.dart";
import "package:database/models/document_file_type.dart";
import "package:database/models/metadata.dart";
import "package:flutter_test/flutter_test.dart";

import "package:database/src/features/document/create.dart";
import "package:database/src/features/document/update.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:drift/drift.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;
  late String docId;

  setUp(() async {
    database = AppDatabase(
      databaseName: "test_db",
      setupOnInit: true,
      debugMode: true,
    );

    // Clean up from any previous tests
    await database.delete(database.documents).go();
    await database.delete(database.metadataRecords).go();
    await database.delete(database.tags).go();

    final result = await database.createDocument(
      title: "Original Title",
      filePath: "/path/to/doc.pdf",
      fileType: DocumentFileType.pdf,
    );
    docId = result.documentId;
  });

  tearDown(() async {
    await database.close();
  });

  group("Document Update", () {
    test("update document title", () async {
      final success = await database.updateDocument(
        documentId: docId,
        title: "Updated Title",
      );

      expect(success, isTrue);

      final doc = await (database.select(database.documents)
            ..where((tbl) => tbl.id.equals(docId)))
          .getSingle();

      expect(doc.title, equals("Updated Title"));
    });

    test("update document metadata", () async {
      final success = await database.updateDocument(
        documentId: docId,
        fileSize: 2048,
        checksum: "newhash",
      );

      expect(success, isTrue);

      final doc = await (database.select(database.documents)
            ..where((tbl) => tbl.id.equals(docId)))
          .getSingle();

      expect(doc.fileSize, equals(2048));
      expect(doc.checksum, equals("newhash"));
    });

    test("verify updatedAt changes on update", () async {
      final originalDoc = await (database.select(database.documents)
            ..where((tbl) => tbl.id.equals(docId)))
          .getSingle();

      // Wait a bit to ensure timestamp differs
      await Future.delayed(const Duration(milliseconds: 1000));

      await database.updateDocument(
        documentId: docId,
        title: "New Title",
      );

      final updatedDoc = await (database.select(database.documents)
            ..where((tbl) => tbl.id.equals(docId)))
          .getSingle();

      expect(updatedDoc.updatedAt.isAfter(originalDoc.updatedAt), isTrue);
    });

    test("add tags to document", () async {
      final tags = [
        Metadata(
          value: "tag1",
          type: MetadataTypeEnum.tag,
        ),
        Metadata(
          value: "tag2",
          type: MetadataTypeEnum.tag,
        ),
      ];

      final addedIds = await database.addTagsToDocument(
        documentId: docId,
        tags: tags,
      );

      expect(addedIds.length, equals(2));

      final metadataRecords = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(docId)))
          .get();

      expect(metadataRecords.length, equals(2));

      final dbTagIds = metadataRecords.map((m) => m.metadataId).toSet();
      expect(dbTagIds.containsAll(addedIds), isTrue);
    });

    test("add existing tags to document", () async {
      // First add a tag
      final tags1 = [
        Metadata(
          value: "shared-tag",
          type: MetadataTypeEnum.tag,
        ),
      ];
      await database.addTagsToDocument(
        documentId: docId,
        tags: tags1,
      );

      // Try to add the same tag again plus a new one
      final tags2 = [
        Metadata(
          value: "shared-tag",
          type: MetadataTypeEnum.tag,
        ),
        Metadata(
          value: "new-tag",
          type: MetadataTypeEnum.tag,
        ),
      ];

      final addedIds = await database.addTagsToDocument(
        documentId: docId,
        tags: tags2,
      );

      // Should only return the ID of the newly added association
      // Wait, addTagsToDocument implementation checks:
      // if (!alreadyLinked) { ... addedTagIds.add(tagId); }
      // So it should return only the new one.
      expect(addedIds.length, equals(1));

      final metadataRecords = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(docId)))
          .get();

      expect(metadataRecords.length, equals(2)); // shared-tag and new-tag
    });

    test("remove tags from document", () async {
      // Add tags first
      final tags = [
        Metadata(
          value: "remove-me",
          type: MetadataTypeEnum.tag,
        ),
        Metadata(
          value: "keep-me",
          type: MetadataTypeEnum.tag,
        ),
      ];

      final addedIds = await database.addTagsToDocument(
        documentId: docId,
        tags: tags,
      );

      expect(addedIds.length, equals(2));

      // Robustly identify which ID is which
      final tagsInDb = await (database.select(database.tags)
            ..where((tbl) => tbl.id.isIn(addedIds)))
          .get();

      final removeId = tagsInDb.firstWhere((t) => t.name == "remove-me").id;
      final keepId = tagsInDb.firstWhere((t) => t.name == "keep-me").id;

      // Remove one tag
      final removedCount = await database.removeTagsFromDocument(
        documentId: docId,
        tagIds: [removeId],
      );

      expect(removedCount, equals(1));

      final metadataRecords = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(docId)))
          .get();

      expect(metadataRecords.length, equals(1));
      expect(metadataRecords.first.metadataId, equals(keepId));
    });
  });

  group("Document Update Exceptions", () {
    test(
        "fails to update document to use an existing file path (Constraint Check)",
        () async {
      // Create a second document
      await database.createDocument(
        title: "Second Document",
        filePath: "/path/existing.pdf",
        fileType: DocumentFileType.pdf,
      );

      // Try to update the main document (docId) to use the second document's path
      // Since the extension doesn't allow updating filePath, we use a direct query
      // to verify the database constraint exists.
      expect(
        () => (database.update(database.documents)
              ..where((t) => t.id.equals(docId)))
            .write(
          const DocumentsCompanion(
            filePath: Value("/path/existing.pdf"),
          ),
        ),
        throwsA(isA<Exception>()), // Expecting SqliteException
      );
    });

    test("fails to update document with short title", () async {
      expect(
        () => database.updateDocument(
          documentId: docId,
          title: "Short",
        ),
        throwsA(isA<Exception>()),
      );
    });

    test("fails to update non-existent document", () async {
      expect(
        () => database.updateDocument(
          documentId: "non-existent-id",
          title: "New Title",
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
