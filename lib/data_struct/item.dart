import 'dart:convert';

import 'package:chenron/database/database.dart';
import 'package:cuid2/cuid2.dart';
import 'package:drift/drift.dart';

/// WARNING: The document handling is deprecated, it's only here for testing.
class FolderItem {
  String id;
  String itemId;
  dynamic content;
  FolderItemType type;

  FolderItem({
    String? id,
    String? itemId,
    required this.content,
    required this.type,
  })  : id = id ?? cuidSecure(30),
        itemId = itemId ?? cuidSecure(30) {
    assert(content is String || content is Map<String, String>,
        'Content must be String or Map<String, String>');
  }

  Insertable toCompanion(String folderId) {
    return ItemsCompanion.insert(
        id: id, folderId: folderId, itemId: itemId, typeId: type.index);
  }

  Insertable toFolderItem() {
    switch (type) {
      case FolderItemType.link:
        return LinksCompanion.insert(
          id: itemId,
          url: content,
        );
      case FolderItemType.document:
        return DocumentsCompanion.insert(
          id: itemId,
          title: content["title"],
          content: utf8.encode(content["body"]),
        );
    }
  }
}

enum FolderItemType {
  link,
  document,
}
