import 'dart:convert';

import 'package:chenron/models/folder.dart';
import 'package:chenron/models/item.dart';
import 'package:chenron/database/database.dart';

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
  FolderItem toFolderItem() {
    return FolderItem(
      id: id,
      itemId: id,
      createdAt: createdAt,
      content: StringContent(content),
      type: FolderItemType.link,
    );
  }
}

extension ConvertDocumentToItem on Document {
  FolderItem toFolderItem() {
    return FolderItem(
      id: id,
      itemId: id,
      createdAt: createdAt,
      content: MapContent({
        'title': title,
        'body': utf8.decode(content),
      }),
      type: FolderItemType.document,
    );
  }
}
