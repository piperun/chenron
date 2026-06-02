import "package:database/database.dart";
import "package:database/src/core/id.dart";
import "package:app_logger/app_logger.dart";
import "package:drift/drift.dart";

extension ItemMembershipExtensions on AppDatabase {
  /// Returns all folders that contain the given item.
  Future<List<Folder>> getParentFolders({
    required String itemId,
  }) async {
    final query = select(folders).join([
      innerJoin(items, items.folderId.equalsExp(folders.id)),
    ])
      ..where(items.itemId.equals(itemId));

    final rows = await query.get();
    return rows.map((row) => row.readTable(folders)).toList();
  }

  /// Returns the transitive set of folder ids nested anywhere beneath
  /// [folderId] — its child folders, their child folders, and so on.
  ///
  /// Nesting is modelled as `items` rows of type [FolderItemType.folder]
  /// whose `folderId` is the parent and whose `itemId` is the contained
  /// child folder. The walk descends level by level, one
  /// `WHERE folder_id IN (...)` query per level, tracking visited ids so a
  /// pre-existing cycle in the data cannot loop forever. [folderId] itself
  /// is never included in the result.
  ///
  /// Use this to forbid choosing a descendant as a folder's parent, which
  /// would otherwise create a cycle (A contains B while B contains A).
  Future<Set<String>> getDescendantFolderIds({
    required String folderId,
  }) async {
    final descendants = <String>{};
    // Ids whose children still need to be fetched.
    var frontier = <String>{folderId};

    while (frontier.isNotEmpty) {
      final childRows = await (select(items)
            ..where((t) =>
                t.folderId.isIn(frontier) &
                t.typeId.equalsValue(FolderItemType.folder)))
          .get();

      final nextFrontier = <String>{};
      for (final row in childRows) {
        final childId = row.itemId;
        // Skip self-reference and anything already discovered to stay
        // cycle-safe and avoid re-querying the same subtree.
        if (childId == folderId || descendants.contains(childId)) {
          continue;
        }
        descendants.add(childId);
        nextFrontier.add(childId);
      }

      frontier = nextFrontier;
    }

    return descendants;
  }

  /// Adds an item (link/document/folder) to a folder.
  ///
  /// Returns the generated items-table row ID, or `null` if the
  /// item is already in that folder.
  Future<String?> addItemToFolder({
    required String itemId,
    required String folderId,
    required FolderItemType type,
  }) async {
    return transaction(() async {
      try {
        loggerGlobal.fine("ItemMembership",
            "Adding item $itemId to folder $folderId");

        // Belt-and-suspenders guard; the unique index on (folder_id, item_id)
        // enforces this at the DB level, but an explicit check avoids relying
        // solely on insertOrIgnore semantics.
        final existing = await (select(items)
              ..where((t) =>
                  t.itemId.equals(itemId) & t.folderId.equals(folderId)))
            .getSingleOrNull();

        if (existing != null) {
          loggerGlobal.fine("ItemMembership",
              "Item $itemId already in folder $folderId");
          return null;
        }

        final id = generateId();
        await into(items).insert(
          ItemsCompanion.insert(
            id: id,
            folderId: folderId,
            itemId: itemId,
            typeId: type,
          ),
        );

        loggerGlobal.fine(
            "ItemMembership", "Added item $itemId to folder $folderId");
        return id;
      } catch (e) {
        loggerGlobal.severe(
            "ItemMembership", "Error adding item to folder: $e");
        rethrow;
      }
    });
  }

  /// Removes an item from a folder.
  ///
  /// Returns the number of rows deleted (0 or 1).
  Future<int> removeItemFromFolder({
    required String itemId,
    required String folderId,
  }) async {
    return transaction(() async {
      try {
        loggerGlobal.fine("ItemMembership",
            "Removing item $itemId from folder $folderId");

        final deletedCount = await (delete(items)
              ..where((t) =>
                  t.itemId.equals(itemId) & t.folderId.equals(folderId)))
            .go();

        loggerGlobal.fine("ItemMembership",
            "Removed item $itemId from folder $folderId ($deletedCount rows)");
        return deletedCount;
      } catch (e) {
        loggerGlobal.severe(
            "ItemMembership", "Error removing item from folder: $e");
        rethrow;
      }
    });
  }
}
