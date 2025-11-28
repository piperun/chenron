import "package:database/main.dart";
import "package:database/models/item.dart";

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
      fileType: fileType,
      fileSize: fileSize,
      checksum: checksum,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
    );
  }
}

extension ConvertFolderToItem on Folder {
  FolderItem toFolderItem(String? itemId, {List<Tag> tags = const []}) {
    return FolderItem.folder(
      id: id,
      itemId: itemId,
      folderId: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
    );
  }
}
