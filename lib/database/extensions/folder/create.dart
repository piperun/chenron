import "package:chenron/database/database.dart";
import "package:chenron/database/operations/folder/folder_create_vepr.dart";
import "package:chenron/models/folder.dart";
import "package:chenron/models/created_ids.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/utils/logger.dart";

extension FolderExtensions on AppDatabase {
  /// Creates a new folder along with its optional tags and items using the VEPR pattern.
  Future<FolderResultIds> createFolder({
    required FolderDraft folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
  }) async {
    // Public API method acts as the RUNNER

    // 1. Instantiate the specific VEPR implementation
    final operation = FolderCreateVEPR(this); // Pass the AppDatabase instance

    final FolderCreateInput input = (
      folderInfo: folderInfo,
      tags: tags,
      items: items,
    );

    return transaction(() async {
      try {
        // Call the VEPR steps sequentially
        operation.logStep("Runner", "Starting createFolder operation");
        operation.validate(input);
        final execResult = await operation.execute(input);
        final procResult = await operation.process(input, execResult);
        final finalResult = operation.buildResult(execResult, procResult);
        operation.logStep("Runner", "Operation completed successfully");
        return finalResult;
      } catch (e) {
        // Log the error before rethrowing
        loggerGlobal.severe(
            "FolderCreateRunner", "Error during createFolder operation: $e");
        // Transaction will handle rollback
        rethrow;
      }
    });
  }
}
