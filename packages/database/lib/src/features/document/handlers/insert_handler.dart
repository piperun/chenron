import "package:database/models/created_ids.dart";
import "package:database/models/item.dart";
import "package:database/src/core/id.dart";

import "package:database/main.dart";
import "package:drift/drift.dart";

extension DocumentInsertHandler on AppDatabase {
  List<DocumentResultIds> insertDocuments({
    required Batch batch,
    required List<DocumentItem> docs,
  }) {
    final List<DocumentResultIds> results = <DocumentResultIds>[];
    if (docs.isEmpty) return results;

    for (final DocumentItem doc in docs) {
      final String documentId = doc.id ?? generateId();
      batch.insert(
        documents,
        DocumentsCompanion.insert(
          id: documentId,
          title: doc.title,
          filePath: doc.filePath,
          fileType: doc.fileType,
          fileSize: Value(doc.fileSize),
          checksum: Value(doc.checksum),
          createdAt: Value(doc.createdAt ?? DateTime.now()),
          updatedAt: Value(doc.updatedAt ?? DateTime.now()),
        ),
        mode: InsertMode.insertOrIgnore,
      );

      results.add(
          CreatedIds.document(documentId: documentId) as DocumentResultIds);
    }

    return results;
  }
}
