import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/id.dart";
import "package:chenron/database/operations/vepr_operation.dart";
import "package:chenron/models/created_ids.dart";
import "package:drift/drift.dart";

// Define Input type
typedef TagCreateInput = ({
  String tagName,
});

// Define Process Result type
typedef TagCreateProcessResult = ({bool success});

/// Concrete VEPR implementation for creating a new Tag.
/// Implements "Get or Create" logic.
class TagCreateVEPR extends VEPROperation<AppDatabase, TagCreateInput,
    TagResultIds, TagCreateProcessResult, TagResultIds> {
  TagCreateVEPR(super.db);

  @override
  void onValidate() {
    logStep("Validate", "Starting validation for tag: ${input.tagName}");

    if (input.tagName.trim().isEmpty) {
      throw ArgumentError("Tag name cannot be empty.");
    }

    logStep("Validate", "Validation passed");
  }

  @override
  Future<TagResultIds> onExecute() async {
    logStep("Execute", "Starting tag creation/retrieval for: ${input.tagName}");

    // Check if tag already exists
    final existingTag = await (db.select(db.tags)
          ..where((t) => t.name.equals(input.tagName)))
        .getSingleOrNull();

    if (existingTag != null) {
      logStep("Execute", "Existing tag found with ID: ${existingTag.id}");
      return TagResultIds(tagId: existingTag.id, wasCreated: false);
    }

    final tagId = db.generateId();
    await db.tags.insertOne(
      TagsCompanion.insert(id: tagId, name: input.tagName),
      mode: InsertMode.insertOrIgnore,
    );

    logStep("Execute", "New tag created with ID: $tagId");
    return TagResultIds(tagId: tagId, wasCreated: true);
  }

  @override
  Future<TagCreateProcessResult> onProcess() async {
    // No post-processing needed for simple tag creation
    return (success: true);
  }

  @override
  TagResultIds onBuildResult() {
    return execResult;
  }
}
