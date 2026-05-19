import "package:database/database.dart";
import "package:database/features.dart";
import "package:database/src/core/handlers/run_vepr.dart";

import "package:app_logger/app_logger.dart";
import "package:drift/drift.dart";

extension DocumentUpdateExtensions on AppDatabase {
  /// Updates document metadata (title, file size, checksum)
  Future<bool> updateDocument({
    required String documentId,
    String? title,
    int? fileSize,
    String? checksum,
  }) {
    return runVepr<String, int, bool>(
      logSource: "updateDocument",
      validate: () {
        if (title != null && title.trim().isEmpty) {
          throw ArgumentError("Document title cannot be empty.");
        }
        if (title == null && fileSize == null && checksum == null) {
          throw ArgumentError(
              "At least one field must be provided for update.");
        }
      },
      execute: () async {
        final doc = await getDocument(documentId: documentId);
        if (doc == null) {
          throw ArgumentError("Document with ID $documentId not found.");
        }
        return documentId;
      },
      process: (docId) async {
        return (update(documents)..where((tbl) => tbl.id.equals(docId)))
            .write(DocumentsCompanion(
          title: title != null ? Value(title) : const Value.absent(),
          fileSize: fileSize != null ? Value(fileSize) : const Value.absent(),
          checksum: checksum != null ? Value(checksum) : const Value.absent(),
        ));
      },
      build: (_, updateCount) => updateCount > 0,
    );
  }

  /// Adds tags to an existing document
  Future<List<String>> addTagsToDocument({
    required String documentId,
    required List<Metadata> tags,
  }) async {
    return transaction(() async {
      try {
        loggerGlobal.fine("DocumentUpdate",
            "Adding ${tags.length} tags to document $documentId");

        final docExists = await (select(documents)
              ..where((d) => d.id.equals(documentId)))
            .getSingleOrNull();
        if (docExists == null) {
          throw ArgumentError(
              "Document with ID $documentId not found.");
        }

        final List<String> addedTagIds = [];

        for (var tag in tags) {
          // Check if this tag is already associated with the document
          final existingMetadata = await (select(metadataRecords)
                ..where((tbl) =>
                    tbl.itemId.equals(documentId) &
                    tbl.typeId.equalsValue(MetadataTypeEnum.tag)))
              .get();

          // Get or create the tag
          final tagId = await addTag(tag.value);

          // Check if already associated
          final alreadyLinked =
              existingMetadata.any((m) => m.metadataId == tagId);

          if (!alreadyLinked) {
            // Create metadata record
            await into(metadataRecords).insert(
              MetadataRecordsCompanion.insert(
                id: generateId(),
                itemId: documentId,
                metadataId: tagId,
                typeId: MetadataTypeEnum.tag,
              ),
            );
            addedTagIds.add(tagId);
          }
        }

        loggerGlobal.fine(
            "DocumentUpdate", "Added ${addedTagIds.length} tags to document");
        return addedTagIds;
      } catch (e) {
        loggerGlobal.severe(
            "DocumentUpdate", "Error adding tags to document: $e");
        rethrow;
      }
    });
  }

  /// Removes tags from an existing document
  Future<int> removeTagsFromDocument({
    required String documentId,
    required List<String> tagIds,
  }) async {
    return transaction(() async {
      try {
        loggerGlobal.fine("DocumentUpdate",
            "Removing ${tagIds.length} tags from document $documentId");

        final deletedCount = await (delete(metadataRecords)
              ..where((tbl) =>
                  tbl.itemId.equals(documentId) &
                  tbl.metadataId.isIn(tagIds) &
                  tbl.typeId.equalsValue(MetadataTypeEnum.tag)))
            .go();

        loggerGlobal.fine(
            "DocumentUpdate", "Removed $deletedCount tag associations");
        return deletedCount;
      } catch (e) {
        loggerGlobal.severe(
            "DocumentUpdate", "Error removing tags from document: $e");
        rethrow;
      }
    });
  }
}
