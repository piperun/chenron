import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/id.dart";
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
class LinkCreateVEPR extends VEPROperation<
    AppDatabase,
    LinkCreateInput,
    String,
    LinkCreateProcessResult,
    LinkResultIds> {
  LinkCreateVEPR(super.db);

  @override
  void validate(LinkCreateInput input) {
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
  Future<String> execute(LinkCreateInput input) async {
    logStep("Execute", "Starting link record creation for: ${input.url}");
    
    // Check if link already exists
    Link? linkExists = await (db.select(db.links)
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
  Future<LinkCreateProcessResult> process(
      LinkCreateInput input, String linkId) async {
    logStep("Process", "Starting tag processing for link ID: $linkId");
    
    List<TagResultIds>? createdTagIdsResult;
    
    if (input.tags != null && input.tags!.isNotEmpty) {
      logStep("Process.Tags", "Processing ${input.tags!.length} tags");
      createdTagIdsResult = [];
      
      await db.batch((batch) async {
        for (var tag in input.tags!) {
          final result = await _getOrCreateTag(tag.value);
          
          createdTagIdsResult!.add(TagResultIds(
            tagId: result.tagId,
            wasCreated: result.wasCreated,
          ));
          
          // Create metadata relation
          batch.insert(
            db.metadataRecords,
            MetadataRecordsCompanion.insert(
              id: db.generateId(),
              itemId: linkId,
              metadataId: result.tagId,
              typeId: MetadataTypeEnum.tag.index,
            ),
          );
        }
      });
      
      logStep("Process.Tags", "Finished processing ${createdTagIdsResult.length} tags");
    } else {
      logStep("Process.Tags", "No tags to process");
    }
    
    logStep("Process", "Finished tag processing");
    
    return (createdTagIds: createdTagIdsResult);
  }

  @override
  LinkResultIds buildResult(String linkId, LinkCreateProcessResult processResult) {
    logStep("BuildResult", "Building final result for link ID: $linkId");
    
    final result = LinkResultIds(
      linkId: linkId,
      tagIds: processResult.createdTagIds,
    );
    
    logStep("BuildResult", "Result built successfully");
    return result;
  }

  /// Helper method to get or create a tag
  /// Returns a record with tagId and wasCreated flag
  Future<({String tagId, bool wasCreated})> _getOrCreateTag(String tagName) async {
    final existingTag = await (db.select(db.tags)
          ..where((t) => t.name.equals(tagName)))
        .getSingleOrNull();
    
    if (existingTag != null) {
      return (tagId: existingTag.id, wasCreated: false);
    }
    
    final newTagId = db.generateId();
    await db.tags.insertOne(TagsCompanion.insert(
      id: newTagId,
      name: tagName,
    ));
    
    return (tagId: newTagId, wasCreated: true);
  }
}
