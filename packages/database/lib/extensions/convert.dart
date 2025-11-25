import "package:database/models/item.dart";
import "package:database/database.dart";

extension ConvertLinkToItem on Link {
  FolderItem toFolderItem(String? itemId, {List<Tag> tags = const []}) {
    return FolderItem(
      id: id,
      itemId: itemId,
      createdAt: createdAt,
      content: StringContent(
          value: path, archiveOrg: archiveOrgUrl, archiveIs: archiveIsUrl),
      type: FolderItemType.link,
      tags: tags,
    );
  }
}

extension ConvertDocumentToItem on Document {
  FolderItem toFolderItem(String? itemId, {List<Tag> tags = const []}) {
    return FolderItem(
      id: id,
      itemId: itemId,
      createdAt: createdAt,
      content: MapContent(value: {
        "title": title,
        "body": path,
      }),
      type: FolderItemType.document,
      tags: tags,
    );
  }
}


