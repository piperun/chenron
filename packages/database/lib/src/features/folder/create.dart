import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/folder.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/src/features/folder/handlers/folder_create_vepr.dart";

extension FolderCreateExtensions on AppDatabase {
  Future<FolderResultIds> createFolder({
    required FolderDraft folderInfo,
    List<Metadata>? tags,
    List<FolderItem>? items,
  }) async {
    final operation = FolderCreateVEPR(this);

    final FolderCreateInput input = (
      folderInfo: folderInfo,
      tags: tags,
      items: items,
    );

    return operation.run(input);
  }
}
