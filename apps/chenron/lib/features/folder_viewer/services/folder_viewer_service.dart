import "package:database/database.dart";
import "package:core/patterns/include_options.dart";
import "package:database/features.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";
import "package:app_logger/app_logger.dart";
import "package:shared_preferences/shared_preferences.dart";

class FolderViewerService
    implements
        ViewerPageRepository,
        ViewerTagFacetSearchRepository,
        ViewerInvalidationDomainRepository {
  FolderViewerService({AppDatabase? database}) : _database = database;

  static const _lockKey = "folder_viewer_header_locked";
  final AppDatabase? _database;

  AppDatabase get _db =>
      _database ??
      locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;

  @override
  Object get viewerInvalidationDomain => _db;

  /// Loads only folder metadata and tags.
  ///
  /// Parent and direct rows share the bounded viewer query path.
  Future<FolderResult> loadFolderMetadata(String folderId) async {
    final folder = await _db.getFolder(
      folderId: folderId,
      includeOptions: const IncludeOptions({AppDataInclude.tags}),
    );

    if (folder == null) {
      throw Exception("Folder not found");
    }

    return FolderResult(
      data: folder.data,
      tags: folder.tags,
      items: const <FolderItem>[],
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
  Future<List<ViewerTagFacet>> loadTagFacets(
    ViewerQuery query, {
    String searchText = "",
  }) =>
      _db.getViewerTagFacets(query, searchText: searchText);

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
  Future<int> countSelectionLease(ViewerSelectionLease lease) =>
      _db.getViewerSelectionLeaseCount(lease);

  @override
  Future<void> consumeSelectionLeaseBatch(
    ViewerSelectionLease lease,
    Iterable<ViewerItemKey> consumed,
  ) =>
      _db.consumeViewerSelectionLeaseBatch(lease, consumed);

  @override
  Future<void> releaseSelectionLease(ViewerSelectionLease lease) =>
      _db.releaseViewerSelectionLease(lease);

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
