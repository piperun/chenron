import "package:database/database.dart";
import "package:database/main.dart";

/// Fetches available links/documents and filters out items
/// already present in the current folder.
class ItemPickerService {
  final AppDatabase _db;

  ItemPickerService(this._db);

  /// Returns all links NOT already in [currentFolderItems].
  Future<List<LinkResult>> getAvailableLinks({
    required List<FolderItem> currentFolderItems,
  }) async {
    final List<LinkResult> allLinks = await _db.getAllLinks(
      includeOptions: const IncludeOptions({AppDataInclude.tags}),
    );
    final Set<String> existingIds = _existingLinkIds(currentFolderItems);
    return allLinks
        .where((LinkResult link) => !existingIds.contains(link.data.id))
        .toList();
  }

  /// Searches links by [query], excluding those already in the folder.
  Future<List<LinkResult>> searchAvailableLinks({
    required String query,
    required List<FolderItem> currentFolderItems,
  }) async {
    final List<LinkResult> results = await _db.searchLinks(
      query: query,
      includeOptions: const IncludeOptions({AppDataInclude.tags}),
    );
    final Set<String> existingIds = _existingLinkIds(currentFolderItems);
    return results
        .where((LinkResult link) => !existingIds.contains(link.data.id))
        .toList();
  }

  /// Returns all documents NOT already in [currentFolderItems].
  Future<List<Document>> getAvailableDocuments({
    required List<FolderItem> currentFolderItems,
  }) async {
    final List<Document> allDocs = await _db.select(_db.documents).get();
    final Set<String> existingIds = _existingDocumentIds(currentFolderItems);
    return allDocs
        .where((Document doc) => !existingIds.contains(doc.id))
        .toList();
  }

  Set<String> _existingLinkIds(List<FolderItem> items) {
    return items
        .whereType<LinkItem>()
        .map((LinkItem item) => item.id)
        .whereType<String>()
        .toSet();
  }

  Set<String> _existingDocumentIds(List<FolderItem> items) {
    return items
        .whereType<DocumentItem>()
        .map((DocumentItem item) => item.id)
        .whereType<String>()
        .toSet();
  }
}
