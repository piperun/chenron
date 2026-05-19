import "package:database/database.dart";
import "package:database/src/core/handlers/run_vepr.dart";
import "package:database/src/core/id.dart";
import "package:database/src/features/link/read.dart";
import "package:database/src/features/tag/create.dart";
import "package:app_logger/app_logger.dart";
import "package:drift/drift.dart";
import "package:meta/meta.dart";

typedef _LinkUpdatePathExec = ({bool linkExists, bool pathConflicts});

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
  }) {
    return runVepr<_LinkUpdatePathExec, int, bool>(
      logSource: "updateLinkPath",
      validate: () {
        if (linkId.trim().isEmpty) {
          throw ArgumentError("Link ID cannot be empty.");
        }
        if (newPath.trim().isEmpty) {
          throw ArgumentError("New path cannot be empty.");
        }
        if (!newPath.startsWith("http://") &&
            !newPath.startsWith("https://")) {
          throw ArgumentError("Link path must start with http:// or https://");
        }
      },
      execute: () async {
        final existing = await getLink(linkId: linkId);
        if (existing == null) {
          return (linkExists: false, pathConflicts: false);
        }
        final conflict = await (select(links)
              ..where((tbl) =>
                  tbl.path.equals(newPath) & tbl.id.equals(linkId).not()))
            .getSingleOrNull();
        return (linkExists: true, pathConflicts: conflict != null);
      },
      process: (exec) async {
        if (!exec.linkExists) {
          throw StateError("Cannot update non-existent link: $linkId");
        }
        if (exec.pathConflicts) {
          throw StateError(
              "Cannot update link: new path conflicts with existing link");
        }
        return (update(links)..where((tbl) => tbl.id.equals(linkId)))
            .write(LinksCompanion(path: Value(newPath)));
      },
      build: (_, updateCount) => updateCount > 0,
    );
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

        final linkExists = await (select(links)
              ..where((l) => l.id.equals(linkId)))
            .getSingleOrNull();
        if (linkExists == null) {
          throw ArgumentError("Link with ID $linkId not found.");
        }

        final List<String> addedTagIds = [];

        for (var tag in tags) {
          // Check if this tag is already associated with the link
          final existingMetadata = await (select(metadataRecords)
                ..where((tbl) =>
                    tbl.itemId.equals(linkId) &
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
                itemId: linkId,
                metadataId: tagId,
                typeId: MetadataTypeEnum.tag,
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
                  tbl.typeId.equalsValue(MetadataTypeEnum.tag)))
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
