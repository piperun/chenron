import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/base_query_builder.dart";
import "package:chenron/database/extensions/convert.dart";
import "package:chenron/database/schema/items_schema.dart";
import "package:chenron/models/item.dart";
import "package:drift/drift.dart";

class ItemJoins implements RowJoins<Items, FolderItem> {
  final AppDatabase db;
  ItemJoins(this.db);
  @override
  List<Join> joins(Expression<String> relationId) => [
        leftOuterJoin(db.items, db.items.folderId.equalsExp(relationId)),
        leftOuterJoin(db.links, db.links.id.equalsExp(db.items.itemId)),
        leftOuterJoin(db.documents, db.documents.id.equalsExp(db.items.itemId)),
      ];

  @override
  FolderItem? readJoins(TypedResult? row) {
    if (row == null) return null;
    final item = row.readTableOrNull(db.items);
    if (item != null) {
      if (item.typeId == FolderItemType.link.index) {
        final link = row.readTableOrNull(db.links);
        if (link != null) {
          return link.toFolderItem(item.id);
        }
      } else if (item.typeId == FolderItemType.document.index) {
        final doc = row.readTableOrNull(db.documents);
        if (doc != null) {
          return doc.toFolderItem(item.id);
        }
      }
    }
    return null;
  }
}
