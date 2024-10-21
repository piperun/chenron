import "dart:convert";

import "package:chenron/models/folder.dart";
import "package:chenron/models/item.dart";
import "package:chenron/database/database.dart";

extension ConvertFolderToInfo on Folder {
  FolderInfo toFolderInfo() {
    return FolderInfo(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
    );
  }
}

extension ConvertLinkToItem on Link {
  FolderItem toFolderItem(String? itemId) {
    return FolderItem(
      id: id,
      itemId: itemId,
      createdAt: createdAt,
      content: StringContent(
          value: content, archiveOrg: archiveOrgUrl, archiveIs: archiveIsUrl),
      type: FolderItemType.link,
    );
  }
}

extension ConvertDocumentToItem on Document {
  FolderItem toFolderItem(String? itemId) {
    return FolderItem(
      id: id,
      itemId: itemId,
      createdAt: createdAt,
      content: MapContent(value: {
        "title": title,
        "body": utf8.decode(content),
      }),
      type: FolderItemType.document,
    );
  }
}
