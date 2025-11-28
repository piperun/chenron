import "package:database/database.dart";
import "package:database/extensions/id.dart";
import "package:database/extensions/tags/create.dart";
import "package:database/operations/vepr_operation.dart";
import "package:drift/drift.dart";

// Define Input type using a Record
typedef DocumentCreateInput = ({
  String title,
  String filePath,
  DocumentFileType fileType,
  int? fileSize,
  String? checksum,
  List<Metadata>? tags,
});

// Define Process Result type
typedef DocumentCreateProcessResult = ({
  List<TagResultIds>? createdTagIds,
});

/// Concrete VEPR implementation for creating a new Document.
class DocumentCreateVEPR extends VEPROperation<AppDatabase, DocumentCreateInput,
    String, DocumentCreateProcessResult, DocumentResultIds> {
  DocumentCreateVEPR(super.db);

  @override
  void onValidate() {
    logStep("Validate", "Starting validation for document: ${input.title}");

    if (input.title.trim().isEmpty) {
      throw ArgumentError("Document title cannot be empty.");
    }

    if (input.filePath.trim().isEmpty) {
      throw ArgumentError("Document file path cannot be empty.");
    }

    logStep("Validate", "Validation passed");
  }

  @override
  Future<String> onExecute() async {
    logStep("Execute", "Starting document record creation for: ${input.title}");

    // Check if document with this file path already exists
    final documents = db.documents;
    final Document? docExists = await (db.select(documents)
          ..where((tbl) => tbl.filePath.equals(input.filePath)))
        .getSingleOrNull();

    String docId;

    if (docExists == null) {
      docId = db.generateId();
      await db.documents.insertOne(
        DocumentsCompanion.insert(
          id: docId,
          title: input.title,
          filePath: input.filePath,
          fileType: input.fileType,
          fileSize: Value(input.fileSize),
          checksum: Value(input.checksum),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      logStep("Execute", "New document created with ID: $docId");
    } else {
      docId = docExists.id;
      logStep("Execute", "Existing document found with ID: $docId");
    }

    return docId;
  }

  @override
  Future<DocumentCreateProcessResult> onProcess() async {
    final docId = execResult;
    logStep("Process", "Starting tag processing for document ID: $docId");

    List<TagResultIds>? createdTagIdsResult;

    if (input.tags != null && input.tags!.isNotEmpty) {
      logStep("Process.Tags", "Processing ${input.tags!.length} tags");
      createdTagIdsResult = [];

      await db.batch((batch) async {
        for (var tag in input.tags!) {
          final tagId = await db.addTag(tag.value);

          createdTagIdsResult!.add(TagResultIds(
            tagId: tagId,
            wasCreated: false,
          ));

          // Create metadata relation
          batch.insert(
            db.metadataRecords,
            MetadataRecordsCompanion.insert(
              id: db.generateId(),
              itemId: docId,
              metadataId: tagId,
              typeId: MetadataTypeEnum.tag.index,
            ),
          );
        }
      });

      logStep("Process.Tags",
          "Finished processing ${createdTagIdsResult.length} tags");
    } else {
      logStep("Process.Tags", "No tags to process");
    }

    logStep("Process", "Finished tag processing");

    return (createdTagIds: createdTagIdsResult);
  }

  @override
  DocumentResultIds onBuildResult() {
    final docId = execResult;
    logStep("BuildResult", "Building final result for document ID: $docId");

    final result = DocumentResultIds(
      documentId: docId,
      tagIds: procResult.createdTagIds?.map((t) => t.tagId).toList(),
    );

    logStep("BuildResult", "Result built successfully");
    return result;
  }
}
