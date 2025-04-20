import 'package:chenron/database/database.dart'; // Need AppDatabase
import "package:chenron/database/extensions/folder/insert.dart";
import 'package:chenron/database/extensions/id.dart';
import 'package:chenron/database/extensions/insert_ext.dart';
import 'package:chenron/database/operations/vepr_operation.dart';
import 'package:chenron/models/created_ids.dart';
import 'package:chenron/models/folder.dart';
import 'package:chenron/models/item.dart';
import 'package:chenron/models/metadata.dart';
import 'package:drift/drift.dart';

// Define a clear Input type using a Record for clarity
typedef FolderCreateInput = ({
  FolderDraft folderInfo,
  List<Metadata>? tags,
  List<FolderItem>? items
});

// Define a clear Process Result type using a Record with NAMED fields
// Ensure these names are used consistently below.
typedef FolderCreateProcessResult = ({
  List<TagResultIds>? createdTagIds,
  List<ItemResultIds>? createdItemIds
});

/// Concrete VEPR implementation for creating a new Folder.
/// Specifies AppDatabase as the DB type.
class FolderCreateVEPR extends VEPROperation<
    AppDatabase, // Specify the Database type here!
    FolderCreateInput,
    String,
    FolderCreateProcessResult,
    FolderResultIds> {
  // Constructor passes the AppDatabase instance up to the superclass.
  // The type check happens implicitly: AppDatabase IS-A GeneratedDatabase.
  FolderCreateVEPR(super.db);

  @override
  void validate(FolderCreateInput input) {
    logStep("Validate", "Starting validation for '${input.folderInfo.title}'");
    if (input.folderInfo.title.trim().isEmpty) {
      throw ArgumentError("Folder title cannot be empty.");
    }
    // Add any other folder-specific validation here
    logStep("Validate", "Validation passed");
  }

  @override
  Future<String> execute(FolderCreateInput input) async {
    logStep("Execute",
        "Starting folder record creation for '${input.folderInfo.title}'");
    String id = db.generateId();
    final newFolder = FoldersCompanion.insert(
      id: id,
      title: input.folderInfo.title,
      description: input.folderInfo.description,
    );
    await db.folders.insertOne(newFolder);
    logStep("Execute", "Folder record created with ID: $id");
    return id;
  }

  @override
  Future<FolderCreateProcessResult> process(
      // Return type is correct
      FolderCreateInput input,
      String folderId) async {
    // Method is async
    logStep("Process", "Starting relation processing for folder ID: $folderId");
    List<TagResultIds>? createdTagIdsResult; // Use different local var names
    List<ItemResultIds>? createdItemIdsResult; // Use different local var names

    await db.batch((batch) async {
      // Process Tags
      if (input.tags != null && input.tags!.isNotEmpty) {
        logStep("Process.Tags", "Processing ${input.tags!.length} tags");
        createdTagIdsResult = // Assign to local var
            await db.insertTags(batch: batch, tagMetadata: input.tags!);
        for (final tagResult in createdTagIdsResult!) {
          db.insertMetadataRelation(
            batch: batch,
            metadataId: tagResult.tagId,
            itemId: folderId,
            type: MetadataTypeEnum.tag,
          );
        }
        logStep("Process.Tags",
            "Finished processing ${createdTagIdsResult?.length ?? 0} tags");
      } else {
        logStep("Process.Tags", "No tags to process");
      }

      // Process Items
      if (input.items != null && input.items!.isNotEmpty) {
        logStep("Process.Items", "Processing ${input.items!.length} items");
        createdItemIdsResult = // Assign to local var
            await db.insertFolderItems(
                batch: batch, folderId: folderId, itemInserts: input.items!);
        logStep("Process.Items",
            "Finished processing ${createdItemIdsResult?.length ?? 0} items");
      } else {
        logStep("Process.Items", "No items to process");
      }
    });
    logStep("Process", "Finished relation processing");

    // Return a record literal matching the typedef structure EXACTLY
    // Use the names defined in the typedef: createdTagIds, createdItemIds
    return (
      createdTagIds: createdTagIdsResult,
      createdItemIds: createdItemIdsResult
    );
  }

  @override
  FolderResultIds buildResult(
      String folderId, FolderCreateProcessResult processResult) {
    logStep("BuildResult", "Building final result for folder ID: $folderId");
    // Access the fields using the names defined in the typedef
    final result = FolderResultIds(
      folderId: folderId,
      tagIds: processResult.createdTagIds, // Access using .createdTagIds
      itemIds: processResult.createdItemIds, // Access using .createdItemIds
    );
    logStep("BuildResult", "Result built successfully");
    return result;
  }
}
