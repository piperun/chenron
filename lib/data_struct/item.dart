import 'dart:convert';

import 'package:chenron/database/database.dart';
import 'package:cuid2/cuid2.dart';
import 'package:drift/drift.dart';

sealed class ItemContent {}

class StringContent extends ItemContent {
  final String value;
  StringContent(this.value);
}

class MapContent extends ItemContent {
  final Map<String, String> value;
  MapContent(this.value);
}

/// WARNING: The document handling is deprecated, it's only here for testing.
// FIXME: REIMPLEMENT DOCUMENT
// FIXME: ALSO REMOVE CLIENT SIDE ID GENERATION IN V0.8+
class FolderItem {
  String id;
  String itemId;
  ItemContent content;
  FolderItemType type;
  bool isNewItem = false;

  FolderItem({
    String? id,
    String? itemId,
    required this.content,
    required this.type,
  })  : id = id ?? cuidSecure(30),
        itemId = itemId ?? cuidSecure(30);

  Insertable toCompanion(String folderId) {
    return ItemsCompanion.insert(
        id: id, folderId: folderId, itemId: itemId, typeId: type.index);
  }

  Insertable toFolderItem() {
    switch (content) {
      case StringContent(value: String url):
        return LinksCompanion.insert(
          id: itemId,
          content: url,
        );
      case MapContent(value: var doc):
        return DocumentsCompanion.insert(
          id: itemId,
          title: doc["title"] ?? '',
          content: utf8.encode(doc["body"] ?? ''),
        );
      default:
        throw Exception('Invalid content type');
    }
  }
}

enum FolderItemType {
  link,
  document,
}
