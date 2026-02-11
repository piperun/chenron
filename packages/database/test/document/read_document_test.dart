// ignore_for_file: avoid_print

import "package:core/patterns/include_options.dart";
import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:database/models/document_file_type.dart";
import "package:database/models/metadata.dart";
import "package:flutter_test/flutter_test.dart";

import "package:database/src/features/document/read.dart";
import "package:database/src/features/document/create.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;
  late String activeDocId;

  setUp(() async {
    database = AppDatabase(
        databaseName: "test_db", setupOnInit: true, debugMode: true);

    // Clean up from any previous tests
    // Clean up from any previous tests
    final documents = database.documents;
    await database.delete(documents).go();
    final metadataRecords = database.metadataRecords;
    await database.delete(metadataRecords).go();
    final tags = database.tags;
    await database.delete(tags).go();

    final activeDocResult = await database.createDocument(
      title: "Active Document",
      filePath: "/path/active.pdf",
      fileType: DocumentFileType.pdf,
      tags: [
        Metadata(value: "tech", type: MetadataTypeEnum.tag),
        Metadata(value: "programming", type: MetadataTypeEnum.tag),
      ],
    );
    activeDocId = activeDocResult.documentId;

    await database.createDocument(
      title: "Inactive Document",
      filePath: "/path/inactive.txt",
      fileType: DocumentFileType.markdown,
      tags: [
        Metadata(value: "news", type: MetadataTypeEnum.tag),
        Metadata(value: "media", type: MetadataTypeEnum.tag),
      ],
    );
  });

  tearDown(() async {
    final documents = database.documents;
    await database.delete(documents).go();
    final metadataRecords = database.metadataRecords;
    await database.delete(metadataRecords).go();
    final tags = database.tags;
    await database.delete(tags).go();
    await database.close();
  });

  group("getDocument() Operations", () {
    test("returns null for non-existent document", () async {
      final DocumentResult? result =
          await database.getDocument(documentId: "non_existent_id");
      expect(result, isNull);
    });

    test("retrieves document without tags", () async {
      final result = await database.getDocument(
        documentId: activeDocId,
      );

      expect(result, isNotNull);
      expect(result!.data.title, equals("Active Document"));
      expect(result.data.filePath, equals("/path/active.pdf"));
      expect(result.tags, isNull);
    });

    test("retrieves document with tags", () async {
      final result = await database.getDocument(
        documentId: activeDocId,
        includeOptions:
            const IncludeOptions<AppDataInclude>({AppDataInclude.tags}),
      );

      expect(result, isNotNull);
      expect(result!.tags?.length, equals(2));
      expect(
        result.tags!.map((t) => t.name).toSet(),
        equals({"tech", "programming"}),
      );
    });
  });

  group("getAllDocuments() Operations", () {
    test("retrieves all documents without tags", () async {
      final results = await database.getAllDocuments();

      expect(results.length, equals(2));
      expect(results.map((r) => r.data.title).toList(), contains("Active Document"));
      expect(
          results.map((r) => r.data.title).toList(), contains("Inactive Document"));
      expect(results.every((r) => r.tags == null), isTrue);
    });

    test("retrieves all documents with tags", () async {
      final results = await database.getAllDocuments(
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));

      expect(results.length, equals(2));

      final activeResult =
          results.firstWhere((r) => r.data.title == "Active Document");
      expect(activeResult.tags?.length, equals(2));
      expect(
        activeResult.tags!.map((t) => t.name).toSet(),
        equals({"tech", "programming"}),
      );

      final inactiveResult =
          results.firstWhere((r) => r.data.title == "Inactive Document");
      expect(inactiveResult.tags?.length, equals(2));
      expect(
        inactiveResult.tags!.map((t) => t.name).toSet(),
        equals({"news", "media"}),
      );
    });
  });

  group("watchDocument() Operations", () {
    test("emits error for non-existent document", () async {
      final stream = database.watchDocument(documentId: "non_existent_id");
      expect(stream, emits(null));
    });

    test("watches document without tags", () async {
      final stream = database.watchDocument(
        documentId: activeDocId,
      );

      expect(
        stream,
        emitsThrough(predicate<DocumentResult>((result) =>
            result.data.title == "Active Document" && result.tags == null)),
      );
    });

    test("watches document with tags", () async {
      final stream = database.watchDocument(
        documentId: activeDocId,
        includeOptions:
            const IncludeOptions<AppDataInclude>({AppDataInclude.tags}),
      );

      expect(
        stream,
        emitsThrough(predicate<DocumentResult>((result) =>
            result.tags?.length == 2 &&
            result.tags!
                .map((t) => t.name)
                .toSet()
                .containsAll(["tech", "programming"]))),
      );
    });
  });

  group("watchAllDocuments() Operations", () {
    test("watches all documents without tags", () async {
      final stream = database.watchAllDocuments();

      expect(
        stream,
        emitsThrough(predicate<List<DocumentResult>>((results) {
          return results.length == 2 &&
              results.every((r) => r.tags == null) &&
              results
                  .map((r) => r.data.title)
                  .toSet()
                  .containsAll(["Active Document", "Inactive Document"]);
        })),
      );
    });

    test("watches all documents with tags", () async {
      final stream = database.watchAllDocuments(
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));

      expect(
        stream,
        emitsThrough(predicate<List<DocumentResult>>((results) =>
            results.length == 2 &&
            results.every((r) => r.tags?.length == 2) &&
            results.any((r) => r.tags!
                .map((t) => t.name)
                .toSet()
                .containsAll(["tech", "programming"])) &&
            results.any((r) => r.tags!
                .map((t) => t.name)
                .toSet()
                .containsAll(["news", "media"])))),
      );
    });
  });
}
