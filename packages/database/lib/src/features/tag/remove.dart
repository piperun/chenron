import "package:database/main.dart";

extension TagRemoveExtensions on AppDatabase {
  Future<bool> removeTag(String tagId) async {
    return transaction(() async {
      final deletions = await Future.wait([
        (delete(tags)..where((t) => t.id.equals(tagId))).go(),
        (delete(metadataRecords)..where((t) => t.metadataId.equals(tagId)))
            .go(),
      ]);

      return deletions.any((count) => count > 0);
    });
  }
}
