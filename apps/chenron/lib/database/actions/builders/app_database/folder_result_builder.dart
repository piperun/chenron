import "package:chenron/database/extensions/convert.dart";
import "package:drift/drift.dart";
import "package:chenron/database/actions/builders/result_builder.dart";
import "package:chenron/database/database.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/models/item.dart";

class FolderResultBuilder implements ResultBuilder<FolderResult> {
  final Folder _folder;
  final List<Tag> _tags = [];
  final List<FolderItem> _items = [];
  final AppDatabase _db;

  FolderResultBuilder(this._folder, this._db);

  @override
  String get entityId => _folder.id;

  @override
  void processRow(TypedResult row, Set<Enum> includeOptions) {
    if (includeOptions.contains(AppDataInclude.tags)) {
      final tag = row.readTableOrNull(_db.tags);
      if (tag != null && !_tags.any((t) => t.id == tag.id)) {
        _tags.add(tag);
      }
    }

    if (includeOptions.contains(AppDataInclude.items)) {
      final item = row.readTableOrNull(_db.items);
      if (item != null) {
        FolderItem? folderItem;

        if (item.typeId == FolderItemType.link.index) {
          final link = row.readTableOrNull(_db.links);
          if (link != null) folderItem = link.toFolderItem(item.id);
        } else if (item.typeId == FolderItemType.document.index) {
          final doc = row.readTableOrNull(_db.documents);
          if (doc != null) folderItem = doc.toFolderItem(item.id);
        }

        if (folderItem != null && !_items.any((i) => i.id == folderItem!.id)) {
          _items.add(folderItem);
        }
      }
    }
  }

  @override
  FolderResult build() {
    return FolderResult(
      data: _folder,
      tags: _tags,
      items: _items,
    );
  }
}
