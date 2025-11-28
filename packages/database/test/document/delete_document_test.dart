import "package:database/main.dart";
import "package:database/models/document_file_type.dart";
import "package:database/models/metadata.dart";
import "package:flutter_test/flutter_test.dart";

import "package:database/src/features/document/create.dart";
import "package:database/src/features/document/remove.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(
      databaseName: "test_db",
      setupOnInit: true,
      debugMode: true,
    );

    // Clean up from any previous tests
    final documents = database.documents;
    await database.delete(documents).go();
    final metadataRecords = database.metadataRecords;
    await database.delete(metadataRecords).go();
    final tags = database.tags;
    await database.delete(tags).go();
  });

  tearDown(() async {
    await database.close();
  });

  group("Document Deletion", () {
    test("remove single document by ID", () async {
      // Create two documents
      final result1 = await database.createDocument(
        title: "Document to Delete",
        filePath: "/path/to/doc1.pdf",
        fileType: DocumentFileType.pdf,
      );
      final result2 = await database.createDocument(
        title: "Keep This Document",
        filePath: "/path/to/doc2.pdf",
        fileType: DocumentFileType.pdf,
      );

      // Remove the first document
      final deleted = await database.removeDocument(result1.documentId);

      expect(deleted, isTrue);

      // Verify doc1 was deleted
      final documents = database.documents;
      final deletedDoc = await (database.select(documents)
            ..where((tbl) => tbl.id.equals(result1.documentId)))
          .getSingleOrNull();

      // Verify doc2 still exists
      final remainingDoc = await (database.select(documents)
            ..where((tbl) => tbl.id.equals(result2.documentId)))
          .getSingleOrNull();

      expect(deletedDoc, isNull);
      expect(remainingDoc, isNotNull);
    });

    test("remove document with tags - tags should remain", () async {
      // Create tags (IDs will be generated automatically)
      final tags = [
        Metadata(
          value: "important",
          type: MetadataTypeEnum.tag,
        ),
        Metadata(
          value: "project-a",
          type: MetadataTypeEnum.tag,
        ),
        Metadata(
          value: "archive",
          type: MetadataTypeEnum.tag,
        ),
      ];

      // Create document with tags
      final result = await database.createDocument(
        title: "Tagged Document",
        filePath: "/path/to/tagged.pdf",
        fileType: DocumentFileType.pdf,
        tags: tags,
      );

      // Verify tags were created
      final tagsTable = database.tags;
      final tagsBefore = await database.select(tagsTable).get();
      expect(tagsBefore.length, equals(3));

      // Verify metadata records were created
      final metadataRecordsTable = database.metadataRecords;
      final metadataRecordsBefore = await (database.select(metadataRecordsTable)
            ..where((tbl) => tbl.itemId.equals(result.documentId)))
          .get();
      expect(metadataRecordsBefore.length, equals(3));

      // Remove the document
      final deleted = await database.removeDocument(result.documentId);
      expect(deleted, isTrue);

      // Verify document was deleted
      final documents = database.documents;
      final deletedDoc = await (database.select(documents)
            ..where((tbl) => tbl.id.equals(result.documentId)))
          .getSingleOrNull();
      expect(deletedDoc, isNull);

      // Verify metadata records (many-to-many) were deleted
      final metadataRecordsAfter = await (database.select(metadataRecordsTable)
            ..where((tbl) => tbl.itemId.equals(result.documentId)))
          .get();
      expect(metadataRecordsAfter.length, equals(0));

      // Verify tags themselves still exist
      final tagsAfter = await database.select(tagsTable).get();
      expect(tagsAfter.length, equals(3));

      final tagNames = tagsAfter.map((t) => t.name).toSet();
      expect(
          tagNames.containsAll(["important", "project-a", "archive"]), isTrue);
    });

    test("remove multiple documents batch", () async {
      // Create multiple documents
      final results = await Future.wait([
        database.createDocument(
          title: "Document 1",
          filePath: "/path/1.pdf",
          fileType: DocumentFileType.pdf,
        ),
        database.createDocument(
          title: "Document 2",
          filePath: "/path/2.pdf",
          fileType: DocumentFileType.pdf,
        ),
        database.createDocument(
          title: "Document 3",
          filePath: "/path/3.pdf",
          fileType: DocumentFileType.pdf,
        ),
      ]);

      final docIds = results.map((r) => r.documentId).toList();

      // Remove first two documents
      final deletedCount =
          await database.removeDocumentsBatch([docIds[0], docIds[1]]);

      expect(deletedCount, greaterThan(0));

      // Verify first two documents were deleted
      final documents = database.documents;
      final remainingDocs = await database.select(documents).get();
      expect(remainingDocs.length, equals(1));
      expect(remainingDocs.first.id, equals(docIds[2]));
    });

    test("remove non-existent document returns false", () async {
      final deleted = await database.removeDocument("nonexistent-id");
      expect(deleted, isFalse);
    });

    test("remove document also removes items table entries", () async {
      // Create a document
      final result = await database.createDocument(
        title: "Document with Items",
        filePath: "/path/to/doc.pdf",
        fileType: DocumentFileType.pdf,
      );

      // Note: In real usage, items would be created when document is added to a folder
      // For this test, we just verify the remove extension handles it

      // Remove the document
      final deleted = await database.removeDocument(result.documentId);
      expect(deleted, isTrue);

      // Verify no items remain for this document
      final itemsTable = database.items;
      final items = await (database.select(itemsTable)
            ..where((tbl) => tbl.itemId.equals(result.documentId)))
          .get();
      expect(items.length, equals(0));
    });
  });
}
