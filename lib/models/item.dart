import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:chenron/database/database.dart";
import "package:cuid2/cuid2.dart";
import "package:drift/drift.dart";

sealed class ItemContent<T> {
  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
  final T value;
  ItemContent({required this.value});
}

class StringContent extends ItemContent<String> {
  final String? archiveOrg;
  final String? archiveIs;

  StringContent({required super.value, this.archiveOrg, this.archiveIs});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StringContent &&
        other.value == value &&
        other.archiveOrg == archiveOrg &&
        other.archiveIs == archiveIs;
  }

  @override
  int get hashCode => Object.hash(value, archiveOrg, archiveIs);
}

class MapContent extends ItemContent<Map<String, String>> {
  MapContent({required super.value});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MapContent &&
        const MapEquality<String, String>().equals(other.value, value);
  }

  @override
  int get hashCode => const MapEquality<String, String>().hash(value);
}

class FolderItem {
  final Key? key;
  final int? _listId;
  final String? _id;
  final String? _itemId;
  String? get id => _id;
  String? get itemId => _itemId;
  int? get listId => _listId;

  final ItemContent path;
  final DateTime? createdAt;
  final FolderItemType type;

  FolderItem._internal(this.key, this._listId, this._id, this._itemId,
      this.path, this.createdAt, this.type);

  factory FolderItem({
    Key? key,
    int? listId,
    String? id,
    String? itemId,
    required ItemContent content,
    DateTime? createdAt,
    required FolderItemType type,
  }) {
    return FolderItem._internal(
        key, listId, id, itemId, content, createdAt, type);
  }

  Insertable toCompanion(String folderId) {
    return ItemsCompanion.insert(
      id: _id ?? "",
      folderId: folderId,
      itemId: _itemId ?? "",
      typeId: type.index,
    );
  }

  Insertable toFolderItem(String id) {
    if (isCuid(id)) {
      switch (path) {
        case StringContent():
          return LinksCompanion.insert(
            id: id,
            path: (path as StringContent).value,
          );
        case MapContent():
          final doc = (path as MapContent).value;
          return DocumentsCompanion.insert(
            id: id,
            title: doc["title"] ?? "",
            path: doc["body"] ?? "",
          );
      }
    }
    throw Exception("Invalid id: not a CUID");
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FolderItem &&
        other.id == id &&
        other.itemId == itemId &&
        other.listId == listId &&
        other.path == path &&
        other.createdAt == createdAt &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, itemId, listId, path, createdAt, type);
}

enum FolderItemType {
  link,
  document,
  folder,
}
