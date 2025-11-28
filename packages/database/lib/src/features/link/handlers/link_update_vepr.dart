import "package:database/main.dart";
import "package:database/src/core/handlers/vepr_operation.dart";
import "package:drift/drift.dart";
import "package:meta/meta.dart";

// Define Input type using a Record
typedef LinkUpdatePathInput = ({
  String linkId,
  String newPath,
});

// Define Execute Result type
typedef LinkUpdatePathExecuteResult = ({
  bool linkExists,
  bool pathConflicts,
});

// Define Process Result type (no processing needed for simple update)
typedef LinkUpdatePathProcessResult = ({
  int updateCount,
});

/// ⚠️ **INTERNAL USE ONLY** ⚠️
///
/// Concrete VEPR implementation for updating a link's path.
///
/// This operation violates the immutability principle of links.
/// See [LinkUpdateExtensions.updateLinkPath] for usage warnings.
@visibleForTesting
class LinkUpdatePathVEPR extends VEPROperation<AppDatabase, LinkUpdatePathInput,
    LinkUpdatePathExecuteResult, LinkUpdatePathProcessResult, bool> {
  LinkUpdatePathVEPR(super.db);

  @override
  void onValidate() {
    logStep("Validate", "Starting validation for link ID: ${input.linkId}");

    if (input.linkId.trim().isEmpty) {
      throw ArgumentError("Link ID cannot be empty.");
    }

    if (input.newPath.trim().isEmpty) {
      throw ArgumentError("New path cannot be empty.");
    }

    // Basic URL validation
    if (!input.newPath.startsWith("http://") &&
        !input.newPath.startsWith("https://")) {
      throw ArgumentError("Link path must start with http:// or https://");
    }

    logStep("Validate", "Validation passed");
  }

  @override
  Future<LinkUpdatePathExecuteResult> onExecute() async {
    logStep("Execute", "Checking link existence and path conflicts");

    // Check if link exists
    // Check if link exists
    final links = db.links;
    final linkExists = await (db.select(links)
          ..where((tbl) => tbl.id.equals(input.linkId)))
        .getSingleOrNull();

    if (linkExists == null) {
      logStep("Execute", "Link does not exist");
      return (linkExists: false, pathConflicts: false);
    }

    // Check if new path conflicts with another link
    // Check if new path conflicts with another link
    // Note: 'links' variable is already defined above if we are in the same scope,
    // but let's redefine or reuse. Since it's local to the previous block? No, it's in onExecute.
    // I'll reuse 'links' if it's in scope, or define it if not.
    // Wait, I defined 'links' in the previous chunk. It is in scope of onExecute.
    final pathConflict = await (db.select(links)
          ..where((tbl) =>
              tbl.path.equals(input.newPath) &
              tbl.id.equals(input.linkId).not()))
        .getSingleOrNull();

    final hasConflict = pathConflict != null;

    if (hasConflict) {
      logStep(
          "Execute", "Path conflicts with existing link: ${pathConflict.id}");
    }

    logStep("Execute", "Link exists: true, Path conflicts: $hasConflict");

    return (linkExists: true, pathConflicts: hasConflict);
  }

  @override
  Future<LinkUpdatePathProcessResult> onProcess() async {
    logStep("Process", "Starting link path update");

    if (!execResult.linkExists) {
      throw StateError("Cannot update non-existent link: ${input.linkId}");
    }

    if (execResult.pathConflicts) {
      throw StateError(
          "Cannot update link: new path conflicts with existing link");
    }

    // Perform the update
    // Perform the update
    final links = db.links;
    final updateCount = await (db.update(links)
          ..where((tbl) => tbl.id.equals(input.linkId)))
        .write(
      LinksCompanion(
        path: Value(input.newPath),
      ),
    );

    logStep("Process", "Updated $updateCount link(s)");

    return (updateCount: updateCount);
  }

  @override
  bool onBuildResult() {
    logStep("BuildResult", "Building final result");

    final success = procResult.updateCount > 0;

    logStep("BuildResult", "Update success: $success");
    return success;
  }
}
