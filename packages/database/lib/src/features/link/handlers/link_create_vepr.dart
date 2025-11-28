import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/metadata.dart";
import "package:database/src/core/handlers/relation_handler.dart";
import "package:database/src/core/handlers/vepr_operation.dart";
import "package:database/src/core/id.dart";
import "package:database/src/features/tag/handlers/insert_handler.dart";
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

      await db.batch((batch) async {
        // Use the shared insertTags helper
        createdTagIdsResult =
            await db.insertTags(batch: batch, tagMetadata: input.tags!);

        for (final tagResult in createdTagIdsResult!) {
          db.insertMetadataRelation(
            batch: batch,
            metadataId: tagResult.tagId,
            itemId: linkId,
            type: MetadataTypeEnum.tag,
          );
        }
      });

      logStep("Process.Tags",
          "Finished processing ${createdTagIdsResult?.length ?? 0} tags");
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
