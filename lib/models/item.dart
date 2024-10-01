import 'dart:convert';

import 'package:chenron/database/database.dart';
import 'package:cuid2/cuid2.dart';
import 'package:drift/drift.dart';

sealed class ItemContent {}

class StringContent extends ItemContent {
  final String value;
  final String? archiveOrg;
  final String? archiveIs;
  StringContent({required this.value, this.archiveOrg, this.archiveIs});
}

class MapContent extends ItemContent {
  final Map<String, String> value;
  MapContent(this.value);
}

class FolderItem {
  final String? _id;
  final String? _itemId;
  String? get id => _id;
  String? get itemId => _itemId;

  ItemContent content;
  final DateTime? createdAt;
  FolderItemType type;

  FolderItem._internal(
      this._id, this._itemId, this.content, this.createdAt, this.type);

  factory FolderItem({
    String? id,
    String? itemId,
    required ItemContent content,
    DateTime? createdAt,
    required FolderItemType type,
  }) {
    return FolderItem._internal(id, itemId, content, createdAt, type);
  }

  Insertable toCompanion(String folderId) {
    return ItemsCompanion.insert(
      id: _id ?? '',
      folderId: folderId,
      itemId: _itemId ?? '',
      typeId: type.index,
    );
  }

  Insertable toFolderItem(String id) {
    if (isCuid(id)) {
      switch (content) {
        case StringContent():
          return LinksCompanion.insert(
            id: id,
            content: (content as StringContent).value,
          );
        case MapContent():
          final doc = (content as MapContent).value;
          return DocumentsCompanion.insert(
            id: id,
            title: doc['title'] ?? '',
            content: utf8.encode(doc['body'] ?? ''),
          );
        default:
          throw Exception('Invalid content type');
      }
    }
    throw Exception('Invalid id: not a CUID');
  }
}

enum FolderItemType {
  link,
  document,
}
