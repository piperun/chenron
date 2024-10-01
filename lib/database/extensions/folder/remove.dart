import "package:chenron/database/database.dart";

extension FolderExtensions on AppDatabase {
  Future<bool> removeFolder(String folderId) async {
    return transaction(() async {
      final deletions = await Future.wait([
        (delete(folders)..where((t) => t.id.equals(folderId))).go(),
        (delete(items)..where((t) => t.folderId.equals(folderId))).go(),
        (delete(metadataRecords)..where((t) => t.itemId.equals(folderId))).go(),
      ]);

      return deletions.any((count) => count > 0);
    });
  }
}
