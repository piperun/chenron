import "package:database/database.dart";
import "package:database/operations/folder/folder_create_vepr.dart";

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

    // 2. Use the run macro
    return operation.run(input);
  }
}


