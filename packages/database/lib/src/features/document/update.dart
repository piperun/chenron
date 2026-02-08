import "package:database/main.dart";
import "package:database/models/metadata.dart";
import "package:database/src/core/id.dart";
import "package:database/src/features/document/handlers/document_update_vepr.dart";
import "package:database/src/features/tag/create.dart";

import "package:logger/logger.dart";
import "package:drift/drift.dart";

extension DocumentUpdateExtensions on AppDatabase {
  /// Updates document metadata (title, file size, checksum)
  Future<bool> updateDocument({
    required String documentId,
    String? title,
    int? fileSize,
    String? checksum,
  }) async {
    final operation = DocumentUpdateVEPR(this);

    final input = (
      documentId: documentId,
      title: title,
      fileSize: fileSize,
      checksum: checksum,
    );

    return operation.run(input);
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
                    tbl.typeId.equals(MetadataTypeEnum.tag.index)))
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
                typeId: MetadataTypeEnum.tag.index,
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
                  tbl.typeId.equals(MetadataTypeEnum.tag.index)))
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
