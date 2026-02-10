import "package:database/main.dart";
import "package:database/models/item.dart";
import "package:database/src/core/convert.dart";
import "package:drift/drift.dart";

extension FolderItemPaginationExtensions on AppDatabase {
  /// Returns the total number of items in a folder.
  Future<int> getFolderItemCount(String folderId) async {
    final countExp = items.id.count();
    final query = selectOnly(items)
      ..addColumns([countExp])
      ..where(items.folderId.equals(folderId));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  /// Loads items for a folder with LIMIT/OFFSET pagination.
  ///
  /// Uses a multi-step query approach to avoid JOIN row multiplication
  /// with LIMIT (one item with N tags would produce N rows).
  Future<List<FolderItem>> getFolderItemsPaginated({
    required String folderId,
    required int limit,
    required int offset,
  }) async {
    // Step 1: Get paginated junction rows
    final itemQuery = select(items)
      ..where((i) => i.folderId.equals(folderId))
      ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
      ..limit(limit, offset: offset);
    final itemRows = await itemQuery.get();

    if (itemRows.isEmpty) return [];

    // Step 2: Group entity IDs by type
    final linkIds = <String>[];
    final docIds = <String>[];
    final folderIds = <String>[];
    for (final row in itemRows) {
      switch (row.typeId) {
        case 1:
          linkIds.add(row.itemId);
        case 2:
          docIds.add(row.itemId);
        case 3:
          folderIds.add(row.itemId);
      }
    }

    // Step 3: Batch load entities by type
    final linkMap = linkIds.isEmpty
        ? <String, Link>{}
        : {
            for (final l
                in await (select(links)..where((l) => l.id.isIn(linkIds)))
                    .get())
              l.id: l,
          };

    final docMap = docIds.isEmpty
        ? <String, Document>{}
        : {
            for (final d
                in await (select(documents)..where((d) => d.id.isIn(docIds)))
                    .get())
              d.id: d,
          };

    final folderMap = folderIds.isEmpty
        ? <String, Folder>{}
        : {
            for (final f
                in await (select(folders)..where((f) => f.id.isIn(folderIds)))
                    .get())
              f.id: f,
          };

    // Step 4: Batch load tags for all items via metadata_records
    final allEntityIds = itemRows.map((r) => r.itemId).toList();
    final tagsByEntityId = await _loadTagsForEntities(allEntityIds);

    // Step 5: Assemble FolderItem objects
    final result = <FolderItem>[];
    for (final row in itemRows) {
      final entityTags = tagsByEntityId[row.itemId] ?? [];
      FolderItem? folderItem;

      switch (row.typeId) {
        case 1:
          final link = linkMap[row.itemId];
          if (link != null) {
            folderItem = link.toFolderItem(row.id, tags: entityTags);
          }
        case 2:
          final doc = docMap[row.itemId];
          if (doc != null) {
            folderItem = doc.toFolderItem(row.id, tags: entityTags);
          }
        case 3:
          final folder = folderMap[row.itemId];
          if (folder != null) {
            folderItem = folder.toFolderItem(row.id, tags: entityTags);
          }
      }

      if (folderItem != null) {
        result.add(folderItem);
      }
    }

    return result;
  }

  /// Loads tags grouped by entity ID for a batch of entities.
  Future<Map<String, List<Tag>>> _loadTagsForEntities(
    List<String> entityIds,
  ) async {
    if (entityIds.isEmpty) return {};

    // Query metadata records for these entities
    final metadataQuery = select(metadataRecords)
      ..where((m) => m.itemId.isIn(entityIds));
    final metadataRows = await metadataQuery.get();

    if (metadataRows.isEmpty) return {};

    // Collect unique tag IDs
    final tagIds = metadataRows.map((m) => m.metadataId).toSet().toList();

    // Batch load tags
    final tagMap = {
      for (final t
          in await (select(tags)..where((t) => t.id.isIn(tagIds))).get())
        t.id: t,
    };

    // Group tags by entity ID
    final result = <String, List<Tag>>{};
    for (final m in metadataRows) {
      final tag = tagMap[m.metadataId];
      if (tag != null) {
        result.putIfAbsent(m.itemId, () => []).add(tag);
      }
    }

    return result;
  }
}
