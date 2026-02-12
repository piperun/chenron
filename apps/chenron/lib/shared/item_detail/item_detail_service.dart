import "package:database/database.dart";
import "package:database/main.dart";
import "package:chenron/shared/item_detail/item_detail_data.dart";

/// Handles all DB interactions for the item detail dialog.
class ItemDetailService {
  final AppDatabase _db;

  ItemDetailService(this._db);

  /// Fetches complete item data including tags and parent folders.
  Future<ItemDetailData?> fetchItem(
    String itemId,
    FolderItemType type,
  ) async {
    final parents = await _db.getParentFolders(itemId: itemId);

    switch (type) {
      case FolderItemType.link:
        final result = await _db.getLink(
          linkId: itemId,
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}),
        );
        if (result == null) return null;
        return ItemDetailData.fromLink(result, parents);

      case FolderItemType.document:
        final result = await _db.getDocument(
          documentId: itemId,
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}),
        );
        if (result == null) return null;
        return ItemDetailData.fromDocument(result, parents);

      case FolderItemType.folder:
        final result = await _db.getFolder(
          folderId: itemId,
          includeOptions: const IncludeOptions<AppDataInclude>(
              {AppDataInclude.tags, AppDataInclude.items}),
        );
        if (result == null) return null;
        return ItemDetailData.fromFolder(result, parents);
    }
  }

  /// Adds a tag to an item.
  Future<void> addTag(
    String itemId,
    FolderItemType type,
    String tagName,
  ) async {
    final tag = Metadata(value: tagName, type: MetadataTypeEnum.tag);

    switch (type) {
      case FolderItemType.link:
        await _db.addTagsToLink(linkId: itemId, tags: [tag]);
      case FolderItemType.document:
        await _db.addTagsToDocument(documentId: itemId, tags: [tag]);
      case FolderItemType.folder:
        await _db.addTagsToFolder(folderId: itemId, tags: [tag]);
    }
  }

  /// Removes a tag from an item by tag ID.
  Future<void> removeTag(
    String itemId,
    FolderItemType type,
    String tagId,
  ) async {
    switch (type) {
      case FolderItemType.link:
        await _db.removeTagsFromLink(linkId: itemId, tagIds: [tagId]);
      case FolderItemType.document:
        await _db.removeTagsFromDocument(
            documentId: itemId, tagIds: [tagId]);
      case FolderItemType.folder:
        await _db.removeTagsFromFolder(folderId: itemId, tagIds: [tagId]);
    }
  }

  /// Adds an item to a folder.
  Future<void> addToFolder(
    String itemId,
    FolderItemType type,
    String folderId,
  ) async {
    await _db.addItemToFolder(
      itemId: itemId,
      folderId: folderId,
      type: type,
    );
  }

  /// Removes an item from a folder.
  Future<void> removeFromFolder(String itemId, String folderId) async {
    await _db.removeItemFromFolder(
      itemId: itemId,
      folderId: folderId,
    );
  }

  /// Fetches all folders for the folder selection dialog.
  Future<List<Folder>> fetchAllFolders() async {
    final results = await _db.getAllFolders();
    return results.map((r) => r.data).toList();
  }
}
