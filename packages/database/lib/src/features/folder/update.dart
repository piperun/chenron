import "package:database/main.dart";
import "package:database/models/created_ids.dart";
import "package:database/models/cud.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:database/src/features/folder/handlers/folder_update_vepr.dart";
import "package:drift/drift.dart";

extension FolderUpdateExtensions on AppDatabase {
  Future<
      (
        FolderResultIds,
        Map<String, List<MetadataResultIds>>,
        Map<String, List<ItemResultIds>>,
      )> updateFolder(
    String folderId, {
    String? title,
    String? description,
    Value<int?>? color,
    CUD<Metadata>? tagUpdates,
    CUD<FolderItem>? itemUpdates,
  }) async {
    final operation = FolderUpdateVEPR(this);

    final FolderUpdateInput input = (
      folderId: folderId,
      title: title,
      description: description,
      color: color,
      tagUpdates: tagUpdates,
      itemUpdates: itemUpdates,
    );

    return operation.run(input);
  }
}
