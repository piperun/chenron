import "package:database/database.dart";
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

    // Step 2: Group item IDs by type
    final linkIds = <String>[];
    final docIds = <String>[];
    final folderIds = <String>[];
    for (final row in itemRows) {
      switch (row.typeId) {
        case FolderItemType.link:
          linkIds.add(row.itemId);
        case FolderItemType.document:
          docIds.add(row.itemId);
        case FolderItemType.folder:
          folderIds.add(row.itemId);
      }
    }

    // Step 3 + 4: Batch-load entities (by type) AND tags concurrently.
    // Both only depend on the junction rows we already have — there's
    // no reason to make the tags load wait for the entities to come
    // back. Awaiting them in parallel cuts a network round-trip off
    // the first-page latency.
    final allItemIds = itemRows.map((r) => r.itemId).toList();
    final entitiesFuture = Future.wait([
      linkIds.isEmpty
          ? Future.value(<Link>[])
          : (select(links)..where((l) => l.id.isIn(linkIds))).get(),
      docIds.isEmpty
          ? Future.value(<Document>[])
          : (select(documents)..where((d) => d.id.isIn(docIds))).get(),
      folderIds.isEmpty
          ? Future.value(<Folder>[])
          : (select(folders)..where((f) => f.id.isIn(folderIds))).get(),
    ]);
    final tagsFuture = _loadTagsForItems(allItemIds);

    final entityResults = await entitiesFuture;
    final tagsByItemId = await tagsFuture;

    final linkMap = {for (final l in entityResults[0] as List<Link>) l.id: l};
    final docMap = {
      for (final d in entityResults[1] as List<Document>) d.id: d,
    };
    final folderMap = {
      for (final f in entityResults[2] as List<Folder>) f.id: f,
    };

    // Step 5: Assemble FolderItem objects
    final result = <FolderItem>[];
    for (final row in itemRows) {
      final itemTags = tagsByItemId[row.itemId] ?? [];
      FolderItem? folderItem;

      switch (row.typeId) {
        case FolderItemType.link:
          final link = linkMap[row.itemId];
          if (link != null) {
            folderItem = link.toFolderItem(row.id,
                tags: itemTags, addedAt: row.createdAt);
          }
        case FolderItemType.document:
          final doc = docMap[row.itemId];
          if (doc != null) {
            folderItem = doc.toFolderItem(row.id,
                tags: itemTags, addedAt: row.createdAt);
          }
        case FolderItemType.folder:
          final folder = folderMap[row.itemId];
          if (folder != null) {
            folderItem = folder.toFolderItem(row.id,
                tags: itemTags, addedAt: row.createdAt);
          }
      }

      if (folderItem != null) {
        result.add(folderItem);
      }
    }

    return result;
  }

  /// Loads tags grouped by item ID for a batch of items.
  ///
  /// Single round-trip: joins `metadata_records` to `tags` so the
  /// pagination first-paint doesn't pay for two sequential queries
  /// (metadata-records lookup → tag-batch lookup) when one will do.
  Future<Map<String, List<Tag>>> _loadTagsForItems(
    List<String> itemIds,
  ) async {
    if (itemIds.isEmpty) return {};

    final query = select(metadataRecords).join([
      innerJoin(tags, tags.id.equalsExp(metadataRecords.metadataId)),
    ])
      ..where(metadataRecords.itemId.isIn(itemIds));
    final rows = await query.get();

    final result = <String, List<Tag>>{};
    for (final row in rows) {
      final record = row.readTable(metadataRecords);
      final tag = row.readTable(tags);
      result.putIfAbsent(record.itemId, () => <Tag>[]).add(tag);
    }
    return result;
  }
}
