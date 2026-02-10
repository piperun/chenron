import "package:database/main.dart";
import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";
import "package:app_logger/app_logger.dart";
import "package:shared_preferences/shared_preferences.dart";

class FolderViewerService {
  static const _lockKey = "folder_viewer_header_locked";

  AppDatabase get _db =>
      locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;

  /// Loads folder metadata (data + tags) and parent folder items.
  /// Does NOT load the folder's own items — those come via pagination.
  Future<FolderResult> loadFolderMetadata(String folderId) async {
    final folder = await _db.getFolder(
      folderId: folderId,
      includeOptions: const IncludeOptions({AppDataInclude.tags}),
    );

    if (folder == null) {
      throw Exception("Folder not found");
    }

    final parentFolders = await _loadParentFolders(_db, folderId);
    final parentItems = parentFolders
        .map((parentFolder) => parentFolder.toFolderItem(null))
        .toList();

    return FolderResult(
      data: folder.data,
      tags: folder.tags,
      items: parentItems,
    );
  }

  Future<int> getFolderItemCount(String folderId) {
    return _db.getFolderItemCount(folderId);
  }

  Future<List<FolderItem>> getFolderItemsPaginated(
    String folderId,
    int limit,
    int offset,
  ) {
    return _db.getFolderItemsPaginated(
      folderId: folderId,
      limit: limit,
      offset: offset,
    );
  }

  Future<FolderResult> loadFolderWithParents(String folderId) async {
    final folder = await _db.getFolder(
      folderId: folderId,
      includeOptions:
          const IncludeOptions({AppDataInclude.items, AppDataInclude.tags}),
    );

    if (folder == null) {
      throw Exception("Folder not found");
    }

    final parentFolders = await _loadParentFolders(_db, folderId);

    final parentItems = parentFolders
        .map((parentFolder) => parentFolder.toFolderItem(null))
        .toList();

    final allItems = [...parentItems, ...folder.items];

    return FolderResult(
      data: folder.data,
      tags: folder.tags,
      items: allItems,
    );
  }

  Future<List<Folder>> _loadParentFolders(
      AppDatabase db, String folderId) async {
    try {
      final items = db.items;
      final query = db.select(items)
        ..where((item) => item.itemId.equals(folderId));
      final results = await query.get();
      final parentFolderIds = results.map((item) => item.folderId).toList();

      if (parentFolderIds.isEmpty) return [];

      final List<Folder> parentFolders = [];
      for (final parentId in parentFolderIds) {
        final folders = db.folders;
        final folderQuery = db.select(folders)
          ..where((folder) => folder.id.equals(parentId));
        final folderResults = await folderQuery.get();
        if (folderResults.isNotEmpty) {
          parentFolders.add(folderResults.first);
        }
      }

      return parentFolders;
    } catch (e) {
      loggerGlobal.warning("FOLDER_VIEWER", "Error loading parent folders: $e");
      return [];
    }
  }

  Future<bool> deleteFolder(String folderId) {
    return _db.removeFolder(folderId);
  }

  Future<bool> loadLockState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_lockKey) ?? false;
    } catch (e, stackTrace) {
      loggerGlobal.warning(
          "FolderViewer", "Failed to load lock state", e, stackTrace);
      return false;
    }
  }

  Future<void> saveLockState({required bool isLocked}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockKey, isLocked);
  }
}
