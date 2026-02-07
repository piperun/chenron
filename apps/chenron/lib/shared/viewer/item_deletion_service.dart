import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:signals/signals.dart";

class ItemDeletionService {
  /// Deletes multiple items from the database.
  /// Returns the count of successfully deleted items.
  Future<int> deleteItems(List<FolderItem> items) async {
    final db = locator.get<Signal<AppDatabaseHandler>>().value;
    final appDb = db.appDatabase;

    int deletedCount = 0;
    for (final item in items) {
      if (item.id == null) continue;
      final success = await _deleteItem(appDb, item);
      if (success) deletedCount++;
    }
    return deletedCount;
  }

  Future<bool> _deleteItem(AppDatabase db, FolderItem item) async {
    // Deletion activity events are tracked automatically by SQLite triggers
    switch (item.type) {
      case FolderItemType.folder:
        return db.removeFolder(item.id!);
      case FolderItemType.link:
        return db.removeLink(item.id!);
      case FolderItemType.document:
        return db.removeDocument(item.id!);
    }
  }
}
