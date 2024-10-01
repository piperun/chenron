import "package:chenron/database/database.dart";

extension LinkRemoveExtensions on AppDatabase {
  Future<bool> removeLink(String linkId) async {
    return transaction(() async {
      final deletions = await Future.wait([
        (delete(links)..where((t) => t.id.equals(linkId))).go(),
        (delete(items)..where((t) => t.itemId.equals(linkId))).go(),
        (delete(metadataRecords)..where((t) => t.itemId.equals(linkId))).go(),
      ]);

      return deletions.any((count) => count > 0);
    });
  }

  Future<int> removeLinksBatch(List<String> linkIds) async {
    return transaction(() async {
      final deletions = await Future.wait([
        (delete(links)..where((t) => t.id.isIn(linkIds))).go(),
        (delete(items)..where((t) => t.itemId.isIn(linkIds))).go(),
        (delete(metadataRecords)..where((t) => t.itemId.isIn(linkIds))).go(),
      ]);

      return deletions.reduce((sum, count) => sum + count);
    });
  }
}
