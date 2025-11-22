import "package:chenron/database/database.dart";
import "package:chenron/database/operations/link/link_update_vepr.dart";
import "package:chenron/database/extensions/id.dart";
import "package:chenron/database/extensions/tags/create.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/utils/logger.dart";
import "package:drift/drift.dart";
import "package:meta/meta.dart";

extension LinkUpdateExtensions on AppDatabase {
  /// **DO NOT USE IN PRODUCTION **
  ///
  /// This method violates data integrity principles and should NOT be used
  /// in normal application flow.
  /// This is because link URLs are intended to be immutable once created.
  ///
  /// **This method only exists for:**
  /// - Emergency database repairs
  /// - Data migration edge cases
  /// - Test scenarios
  ///
  /// **Using this in production code will:**
  /// - Break URL-based deduplication
  /// - Violate referential integrity assumptions
  /// - Cause unexpected behavior in caching layers
  ///
  /// @see createLink() for creating new links
  /// @see removeLink() for deleting links
  @visibleForTesting
  @Deprecated(
      "Link URLs are immutable. To change a link, create a new link and delete the old one. "
      "This method only exists for emergency database repairs and should not be used in normal code.")
  Future<bool> updateLinkPath({
    required String linkId,
    required String newPath,
  }) async {
    final operation = LinkUpdatePathVEPR(this);

    final input = (linkId: linkId, newPath: newPath);

    return operation.run(input);
  }

  /// Adds tags to an existing link
  Future<List<String>> addTagsToLink({
    required String linkId,
    required List<Metadata> tags,
  }) async {
    return transaction(() async {
      try {
        loggerGlobal.fine(
            "LinkUpdate", "Adding ${tags.length} tags to link $linkId");

        final List<String> addedTagIds = [];

        for (var tag in tags) {
          // Check if this tag is already associated with the link
          final existingMetadata = await (select(metadataRecords)
                ..where((tbl) =>
                    tbl.itemId.equals(linkId) &
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
                itemId: linkId,
                metadataId: tagId,
                typeId: MetadataTypeEnum.tag.index,
              ),
            );
            addedTagIds.add(tagId);
          }
        }

        loggerGlobal.fine(
            "LinkUpdate", "Added ${addedTagIds.length} tags to link");
        return addedTagIds;
      } catch (e) {
        loggerGlobal.severe("LinkUpdate", "Error adding tags to link: $e");
        rethrow;
      }
    });
  }

  /// Removes tags from an existing link
  Future<int> removeTagsFromLink({
    required String linkId,
    required List<String> tagIds,
  }) async {
    return transaction(() async {
      try {
        loggerGlobal.fine(
            "LinkUpdate", "Removing ${tagIds.length} tags from link $linkId");

        final deletedCount = await (delete(metadataRecords)
              ..where((tbl) =>
                  tbl.itemId.equals(linkId) &
                  tbl.metadataId.isIn(tagIds) &
                  tbl.typeId.equals(MetadataTypeEnum.tag.index)))
            .go();

        loggerGlobal.fine(
            "LinkUpdate", "Removed $deletedCount tag associations");
        return deletedCount;
      } catch (e) {
        loggerGlobal.severe("LinkUpdate", "Error removing tags from link: $e");
        rethrow;
      }
    });
  }

  /// Updates archive URLs for a link
  Future<bool> updateLinkArchiveUrls({
    required String linkId,
    String? archiveOrgUrl,
    String? archiveIsUrl,
    String? localArchivePath,
  }) async {
    return transaction(() async {
      try {
        final updateCount =
            await (update(links)..where((tbl) => tbl.id.equals(linkId))).write(
          LinksCompanion(
            archiveOrgUrl: archiveOrgUrl != null
                ? Value(archiveOrgUrl)
                : const Value.absent(),
            archiveIsUrl: archiveIsUrl != null
                ? Value(archiveIsUrl)
                : const Value.absent(),
            localArchivePath: localArchivePath != null
                ? Value(localArchivePath)
                : const Value.absent(),
          ),
        );

        return updateCount > 0;
      } catch (e) {
        loggerGlobal.severe("LinkUpdate", "Error updating archive URLs: $e");
        rethrow;
      }
    });
  }
}
