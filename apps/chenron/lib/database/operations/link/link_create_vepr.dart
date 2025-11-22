import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/id.dart";
import "package:chenron/database/extensions/tags/create.dart";
import "package:chenron/database/operations/vepr_operation.dart";
import "package:chenron/models/created_ids.dart";
import "package:chenron/models/metadata.dart";
import "package:drift/drift.dart";

// Define Input type using a Record
typedef LinkCreateInput = ({
  String url,
  List<Metadata>? tags,
});

// Define Process Result type
typedef LinkCreateProcessResult = ({
  List<TagResultIds>? createdTagIds,
});

/// Concrete VEPR implementation for creating a new Link.
class LinkCreateVEPR extends VEPROperation<AppDatabase, LinkCreateInput, String,
    LinkCreateProcessResult, LinkResultIds> {
  LinkCreateVEPR(super.db);

  @override
  void onValidate() {
    logStep("Validate", "Starting validation for URL: ${input.url}");

    if (input.url.trim().isEmpty) {
      throw ArgumentError("Link URL cannot be empty.");
    }

    // Basic URL validation (you can enhance this)
    if (!input.url.startsWith("http://") && !input.url.startsWith("https://")) {
      throw ArgumentError("Link URL must start with http:// or https://");
    }

    logStep("Validate", "Validation passed");
  }

  @override
  Future<String> onExecute() async {
    logStep("Execute", "Starting link record creation for: ${input.url}");

    // Check if link already exists
    final links = db.links;
    final Link? linkExists = await (db.select(links)
          ..where((tbl) => tbl.path.equals(input.url)))
        .getSingleOrNull();

    String linkId;

    if (linkExists == null) {
      linkId = db.generateId();
      await db.links.insertOne(
        LinksCompanion.insert(id: linkId, path: input.url),
        mode: InsertMode.insertOrIgnore,
      );
      logStep("Execute", "New link created with ID: $linkId");
    } else {
      linkId = linkExists.id;
      logStep("Execute", "Existing link found with ID: $linkId");
    }

    return linkId;
  }

  @override
  Future<LinkCreateProcessResult> onProcess() async {
    final linkId = execResult;
    logStep("Process", "Starting tag processing for link ID: $linkId");

    List<TagResultIds>? createdTagIdsResult;

    if (input.tags != null && input.tags!.isNotEmpty) {
      logStep("Process.Tags", "Processing ${input.tags!.length} tags");
      createdTagIdsResult = [];

      await db.batch((batch) async {
        for (var tag in input.tags!) {
          final tagId = await db.addTag(tag.value);

          createdTagIdsResult!.add(TagResultIds(
            tagId: tagId,
            // We don't know if it was created or not from addTag's simple return,
            // but for the result object we can default to false or change the return type of addTag.
            // Given the current implementation of addTag returns just ID, we'll assume false or omit.
            // However, TagResultIds has a default false for wasCreated.
            wasCreated: false,
          ));

          // Create metadata relation
          batch.insert(
            db.metadataRecords,
            MetadataRecordsCompanion.insert(
              id: db.generateId(),
              itemId: linkId,
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
  LinkResultIds onBuildResult() {
    final linkId = execResult;
    logStep("BuildResult", "Building final result for link ID: $linkId");

    final result = LinkResultIds(
      linkId: linkId,
      tagIds: procResult.createdTagIds,
    );

    logStep("BuildResult", "Result built successfully");
    return result;
  }
}
