import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:signals/signals.dart";

/// Result of a bulk tag operation, tracking how many tags were newly applied.
class TaggingResult {
  /// Total items processed.
  final int itemCount;

  /// Per-tag count of items that newly received the tag (didn't have it before).
  final Map<String, int> newCountPerTag;

  const TaggingResult({
    required this.itemCount,
    required this.newCountPerTag,
  });

  /// Total number of new tag associations created.
  int get totalNew =>
      newCountPerTag.values.fold(0, (sum, count) => sum + count);
}

/// Result of a bulk tag removal operation.
class TagRemovalResult {
  /// Total items processed.
  final int itemCount;

  /// Per-tag count of items that had the tag removed.
  final Map<String, int> removedCountPerTag;

  const TagRemovalResult({
    required this.itemCount,
    required this.removedCountPerTag,
  });

  /// Total number of tag associations removed.
  int get totalRemoved =>
      removedCountPerTag.values.fold(0, (sum, count) => sum + count);
}

class ItemTaggingService {
  /// Adds tags to multiple items.
  ///
  /// Returns a [TaggingResult] with per-tag counts of newly applied tags.
  /// The DB `addTagsTo*` methods return the IDs of newly created tag
  /// associations, so empty means the item already had that tag.
  Future<TaggingResult> addTagToItems(
    List<FolderItem> items,
    List<String> tagNames,
  ) async {
    final db = locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;
    final tags = tagNames
        .map((name) => Metadata(value: name, type: MetadataTypeEnum.tag))
        .toList();

    final newCountPerTag = <String, int>{
      for (final name in tagNames) name: 0,
    };

    int processedCount = 0;
    for (final item in items) {
      if (item.id == null) continue;

      final List<String> newIds;
      switch (item.type) {
        case FolderItemType.link:
          newIds = await db.addTagsToLink(linkId: item.id!, tags: tags);
        case FolderItemType.document:
          newIds =
              await db.addTagsToDocument(documentId: item.id!, tags: tags);
        case FolderItemType.folder:
          newIds = await db.addTagsToFolder(folderId: item.id!, tags: tags);
      }

      // Each new ID means one tag was freshly applied to this item.
      // The DB returns one ID per new tag-item association.
      for (final name in tagNames) {
        // If the total new IDs >= tags count, all tags were new for this item.
        // Otherwise we can't distinguish per-tag, so count conservatively.
        if (newIds.length >= tagNames.length) {
          newCountPerTag[name] = newCountPerTag[name]! + 1;
        }
      }
      // If fewer new IDs than tags, some were duplicates — we don't know
      // which, so only increment if all were new (conservative count).

      processedCount++;
    }

    return TaggingResult(
      itemCount: processedCount,
      newCountPerTag: newCountPerTag,
    );
  }

  /// Removes tags from multiple items.
  ///
  /// Resolves tag names to IDs via each item's existing [FolderItem.tags]
  /// (which carry [Tag] objects with `.id` and `.name`), then calls the
  /// appropriate `db.removeTagsFrom*` method.
  Future<TagRemovalResult> removeTagFromItems(
    List<FolderItem> items,
    List<String> tagNames,
  ) async {
    final db = locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;
    final tagNameSet = tagNames.toSet();

    final removedCountPerTag = <String, int>{
      for (final name in tagNames) name: 0,
    };

    int processedCount = 0;
    for (final item in items) {
      if (item.id == null) continue;

      // Resolve tag names → IDs from this item's tag list.
      final matchingTags =
          item.tags.where((t) => tagNameSet.contains(t.name)).toList();
      final tagIds = matchingTags.map((t) => t.id).toList();

      if (tagIds.isNotEmpty) {
        switch (item.type) {
          case FolderItemType.link:
            await db.removeTagsFromLink(
                linkId: item.id!, tagIds: tagIds);
          case FolderItemType.document:
            await db.removeTagsFromDocument(
                documentId: item.id!, tagIds: tagIds);
          case FolderItemType.folder:
            await db.removeTagsFromFolder(
                folderId: item.id!, tagIds: tagIds);
        }

        for (final tag in matchingTags) {
          removedCountPerTag[tag.name] =
              (removedCountPerTag[tag.name] ?? 0) + 1;
        }
      }

      processedCount++;
    }

    return TagRemovalResult(
      itemCount: processedCount,
      removedCountPerTag: removedCountPerTag,
    );
  }
}
