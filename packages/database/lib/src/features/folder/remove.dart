import "package:database/database.dart";

extension FolderRemoveExtensions on AppDatabase {
  Future<bool> removeFolder(String folderId) async {
    return transaction(() async {
      final deletions = await Future.wait([
        (delete(folders)..where((t) => t.id.equals(folderId))).go(),
        // Items contained in this folder (its children).
        (delete(items)..where((t) => t.folderId.equals(folderId))).go(),
        // This folder's own membership rows in any parent folders — without
        // this a nested folder leaves a junction row pointing at a folder
        // that no longer exists, which over-counts parents and loads a null
        // entity on the next read.
        (delete(items)..where((t) => t.itemId.equals(folderId))).go(),
        (delete(metadataRecords)..where((t) => t.itemId.equals(folderId))).go(),
      ]);

      return deletions.any((count) => count > 0);
    });
  }
}
