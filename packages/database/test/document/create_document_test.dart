import 'package:database/main.dart';
import 'package:database/models/document_file_type.dart';
import 'package:database/models/metadata.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:database/src/features/document/create.dart';
import 'package:chenron_mockups/chenron_mockups.dart';

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

    // Clean up any existing documents from previous tests
    await database.delete(database.documents).go();
  });

  tearDown(() async {
    await database.close();
  });

  group('Document Creation', () {
    test('create document successfully', () async {
      final result = await database.createDocument(
        title: 'Test Document',
        filePath: '/path/to/doc.pdf',
        fileType: DocumentFileType.pdf,
      );

      expect(result.documentId, isNotEmpty);

      final retrievedDoc = await (database.select(database.documents)
            ..where((tbl) => tbl.id.equals(result.documentId)))
          .getSingleOrNull();

      expect(retrievedDoc, isNotNull);
      expect(retrievedDoc!.title, equals('Test Document'));
      expect(retrievedDoc.filePath, equals('/path/to/doc.pdf'));
      expect(retrievedDoc.fileType, equals(DocumentFileType.pdf));
    });

    test('create multiple documents', () async {
      final result1 = await database.createDocument(
        title: 'Document 123456',
        filePath: '/path/1',
        fileType: DocumentFileType.docx,
      );
      final result2 = await database.createDocument(
        title: 'Document 234567',
        filePath: '/path/2',
        fileType: DocumentFileType.docx,
      );

      expect(result1.documentId, isNotEmpty);
      expect(result2.documentId, isNotEmpty);

      final allDocs = await database.select(database.documents).get();
      expect(allDocs.length, equals(2));
      expect(allDocs.map((d) => d.id).toSet(),
          equals({result1.documentId, result2.documentId}));
    });

    test('create document with tags', () async {
      final tags = [
        Metadata(
          metadataId: 'tag1',
          value: 'work',
          type: MetadataTypeEnum.tag,
        ),
        Metadata(
          metadataId: 'tag2',
          value: 'high',
          type: MetadataTypeEnum.tag,
        ),
        Metadata(
          metadataId: 'tag3',
          value: 'draft',
          type: MetadataTypeEnum.tag,
        ),
      ];

      final result = await database.createDocument(
        title: 'Tagged Document',
        filePath: '/path/to/tagged-doc.pdf',
        fileType: DocumentFileType.pdf,
        tags: tags,
      );

      expect(result.documentId, isNotEmpty);
      expect(result.tagIds, isNotNull);
      expect(result.tagIds!.length, equals(3));

      // Verify document was created
      final retrievedDoc = await (database.select(database.documents)
            ..where((tbl) => tbl.id.equals(result.documentId)))
          .getSingleOrNull();

      expect(retrievedDoc, isNotNull);
      expect(retrievedDoc!.title, equals('Tagged Document'));

      // Verify tags were associated with the document
      final metadataRecords = await (database.select(database.metadataRecords)
            ..where((tbl) => tbl.itemId.equals(result.documentId)))
          .get();

      expect(metadataRecords.length, equals(3));

      // Verify all tag IDs are correct
      final dbTagIds = metadataRecords.map((m) => m.metadataId).toSet();
      final expectedTagIds = result.tagIds!.toSet();
      expect(dbTagIds, equals(expectedTagIds));

      // Verify tag content in the tags table
      final dbTags = await database.select(database.tags).get();
      expect(dbTags.length, greaterThanOrEqualTo(3));

      final tagNames = dbTags.map((m) => m.name).toSet();
      expect(tagNames.containsAll(['work', 'high', 'draft']), isTrue);
    });
  });

  group('Document Creation Exceptions', () {
    test('createDocument returns existing document for duplicate file path',
        () async {
      final result1 = await database.createDocument(
        title: 'Original Document',
        filePath: '/path/unique.pdf',
        fileType: DocumentFileType.pdf,
      );

      // Should not throw, but return the existing document
      final result2 = await database.createDocument(
        title: 'Duplicate Path Document',
        filePath: '/path/unique.pdf',
        fileType: DocumentFileType.pdf,
      );

      expect(result2.documentId, equals(result1.documentId));
    });

    test('fails to insert duplicate file path directly (Constraint Check)',
        () async {
      await database.createDocument(
        title: 'Original Document',
        filePath: '/path/constraint_check.pdf',
        fileType: DocumentFileType.pdf,
      );

      // Try to insert directly to bypass VEPR check and trigger DB constraint
      expect(
        () => database.into(database.documents).insert(
              DocumentsCompanion.insert(
                id: 'new-id',
                title: 'Duplicate',
                filePath: '/path/constraint_check.pdf',
                fileType: DocumentFileType.pdf,
              ),
            ),
        throwsA(isA<Exception>()), // Expecting SqliteException
      );
    });

    test('fails to create document with short title', () async {
      expect(
        () => database.createDocument(
          title: 'Short', // Less than 6 characters
          filePath: '/path/short-title.pdf',
          fileType: DocumentFileType.pdf,
        ),
        throwsA(isA<Exception>()), // Expecting InvalidDataException
      );
    });
  });
}
