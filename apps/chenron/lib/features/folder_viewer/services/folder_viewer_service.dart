import "package:database/database.dart";
import "package:core/patterns/include_options.dart";
import "package:database/features.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";
import "package:app_logger/app_logger.dart";
import "package:shared_preferences/shared_preferences.dart";

class FolderViewerService implements ViewerPageRepository {
  FolderViewerService({AppDatabase? database}) : _database = database;

  static const _lockKey = "folder_viewer_header_locked";
  final AppDatabase? _database;

  AppDatabase get _db =>
      _database ??
      locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;

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

  Future<int> getFolderItemCount(String folderId) =>
      count(ViewerQuery(folderId: folderId));

  Future<List<FolderItem>> getFolderItemsPaginated(
    String folderId,
    int limit,
    int offset,
  ) =>
      loadPage(
        ViewerQuery(folderId: folderId),
        limit: limit,
        offset: offset,
      );

  Future<FolderResult> loadFolderWithParents(String folderId) async {
    final folder = await _db.getFolder(
      folderId: folderId,
      includeOptions:
          const IncludeOptions({AppDataInclude.items, AppDataInclude.tags}),
    );
    if (folder == null) throw Exception("Folder not found");

    final parentFolders = await _loadParentFolders(_db, folderId);
    return FolderResult(
      data: folder.data,
      tags: folder.tags,
      items: <FolderItem>[
        ...parentFolders.map((folder) => folder.toFolderItem(null)),
        ...folder.items,
      ],
    );
  }

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) =>
      _db.getViewerPage(query, limit: limit, offset: offset);

  @override
  Future<int> count(ViewerQuery query) => _db.getViewerItemCount(query);

  @override
  Future<List<ViewerTagFacet>> loadTagFacets(ViewerQuery query) =>
      _db.getViewerTagFacets(query);

  @override
  Stream<void> invalidations() => _db.watchViewerInvalidations();

  @override
  Future<ViewerSelectionLease> createSelectionLease({
    required ViewerQuery query,
    Set<ViewerItemKey>? onlyKeys,
    Set<ViewerItemKey> excludedKeys = const <ViewerItemKey>{},
  }) =>
      _db.createViewerSelectionLease(
        query: query,
        onlyKeys: onlyKeys,
        excludedKeys: excludedKeys,
      );

  @override
  Future<List<FolderItem>> loadSelectionLeaseBatch(
    ViewerSelectionLease lease, {
    required int limit,
  }) =>
      _db.getViewerSelectionLeaseBatch(lease, limit: limit);

  @override
  Future<void> consumeSelectionLeaseBatch(
    ViewerSelectionLease lease,
    Iterable<ViewerItemKey> consumed,
  ) =>
      _db.consumeViewerSelectionLeaseBatch(lease, consumed);

  @override
  Future<void> releaseSelectionLease(ViewerSelectionLease lease) =>
      _db.releaseViewerSelectionLease(lease);

  Future<List<Folder>> _loadParentFolders(
      AppDatabase db, String folderId) async {
    try {
      final items = db.items;
      final query = db.select(items)
        ..where((item) => item.itemId.equals(folderId));
      final results = await query.get();
      final parentFolderIds = results.map((item) => item.folderId).toList();

      if (parentFolderIds.isEmpty) return [];

      final folderQuery = db.select(db.folders)
        ..where((folder) => folder.id.isIn(parentFolderIds));
      return await folderQuery.get();
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
