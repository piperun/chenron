import 'package:database/main.dart';

extension DocumentRemoveExtensions on AppDatabase {
  Future<bool> removeDocument(String documentId) async {
    return transaction(() async {
      final deletions = await Future.wait([
        (delete(documents)..where((t) => t.id.equals(documentId))).go(),
        (delete(items)..where((t) => t.itemId.equals(documentId))).go(),
        (delete(metadataRecords)..where((t) => t.itemId.equals(documentId)))
            .go(),
      ]);

      return deletions.any((count) => count > 0);
    });
  }

  Future<int> removeDocumentsBatch(List<String> documentIds) async {
    return transaction(() async {
      final deletions = await Future.wait([
        (delete(documents)..where((t) => t.id.isIn(documentIds))).go(),
        (delete(items)..where((t) => t.itemId.isIn(documentIds))).go(),
        (delete(metadataRecords)..where((t) => t.itemId.isIn(documentIds)))
            .go(),
      ]);

      return deletions.reduce((sum, count) => sum + count);
    });
  }
}
