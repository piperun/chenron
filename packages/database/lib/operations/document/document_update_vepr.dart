import "package:database/database.dart";
import "package:database/operations/vepr_operation.dart";
import "package:drift/drift.dart";

// Define Input type using a Record
typedef DocumentUpdateInput = ({
  String documentId,
  String? title,
  int? fileSize,
  String? checksum,
});

// Define Process Result type
typedef DocumentUpdateProcessResult = ({
  int updateCount,
});

/// Concrete VEPR implementation for updating a Document.
class DocumentUpdateVEPR extends VEPROperation<AppDatabase, DocumentUpdateInput,
    String, DocumentUpdateProcessResult, bool> {
  DocumentUpdateVEPR(super.db);

  @override
  void onValidate() {
    logStep("Validate",
        "Starting validation for document update: ${input.documentId}");

    if (input.title != null && input.title!.trim().isEmpty) {
      throw ArgumentError("Document title cannot be empty.");
    }

    // At least one field must be provided for update
    if (input.title == null &&
        input.fileSize == null &&
        input.checksum == null) {
      throw ArgumentError("At least one field must be provided for update.");
    }

    logStep("Validate", "Validation passed");
  }

  @override
  Future<String> onExecute() async {
    logStep("Execute", "Starting document update for: ${input.documentId}");

    // Check if document exists
    final doc = await (db.select(db.documents)
          ..where((tbl) => tbl.id.equals(input.documentId)))
        .getSingleOrNull();

    if (doc == null) {
      throw ArgumentError("Document with ID ${input.documentId} not found.");
    }

    logStep("Execute", "Document found, proceeding with update");
    return input.documentId;
  }

  @override
  Future<DocumentUpdateProcessResult> onProcess() async {
    final docId = execResult;
    logStep("Process", "Updating document fields for ID: $docId");

    final companion = DocumentsCompanion(
      title: input.title != null ? Value(input.title!) : const Value.absent(),
      fileSize:
          input.fileSize != null ? Value(input.fileSize) : const Value.absent(),
      checksum:
          input.checksum != null ? Value(input.checksum) : const Value.absent(),
    );

    final updateCount = await (db.update(db.documents)
          ..where((tbl) => tbl.id.equals(docId)))
        .write(companion);

    logStep("Process", "Updated $updateCount document record(s)");

    return (updateCount: updateCount);
  }

  @override
  bool onBuildResult() {
    final updateCount = procResult.updateCount;
    logStep(
        "BuildResult", "Building final result: updated $updateCount records");

    final result = updateCount > 0;

    logStep("BuildResult", "Result built successfully: $result");
    return result;
  }
}
