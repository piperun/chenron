import "package:database/models/item.dart";
import "package:database/database.dart";

extension ConvertLinkToItem on Link {
  FolderItem toFolderItem(String? itemId, {List<Tag> tags = const []}) {
    return FolderItem.link(
      id: id,
      itemId: itemId,
      url: path,
      archiveOrg: archiveOrgUrl,
      archiveIs: archiveIsUrl,
      createdAt: createdAt,
      tags: tags,
    );
  }
}

extension ConvertDocumentToItem on Document {
  FolderItem toFolderItem(String? itemId, {List<Tag> tags = const []}) {
    return FolderItem.document(
      id: id,
      itemId: itemId,
      title: title,
      filePath: filePath,
      mimeType: mimeType,
      fileSize: fileSize,
      checksum: checksum,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
    );
  }
}
