import "package:database/database.dart";
import "package:core/patterns/include_options.dart";
import "package:database/features.dart";

import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/locator.dart";

import "package:app_logger/app_logger.dart";
import "package:rxdart/rxdart.dart";
import "package:signals/signals.dart";

class ViewerModel implements ViewerPageRepository {
  ViewerModel({AppDatabase? database}) : _database = database;

  final AppDatabase? _database;

  AppDatabase get _db =>
      _database ??
      locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;

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

  Future<bool> removeFolder(String folder) async {
    try {
      await _db.removeFolder(folder);
      return true;
    } catch (e, stackTrace) {
      loggerGlobal.severe(
          "ViewerModel", "Error deleting folder", e, stackTrace);
      return false;
    }
  }

  Future<bool> removeLink(String linkId) async {
    try {
      await _db.removeLink(linkId);
      return true;
    } catch (e, stackTrace) {
      loggerGlobal.severe("ViewerModel", "Error deleting link", e, stackTrace);
      return false;
    }
  }

  Future<bool> removeDocument(String documentId) async {
    try {
      await _db.removeDocument(documentId);
      return true;
    } catch (e, stackTrace) {
      loggerGlobal.severe(
          "ViewerModel", "Error deleting document", e, stackTrace);
      return false;
    }
  }

  Stream<List<FolderResult>> watchAllFolders() {
    return _db.watchAllFolders(
        includeOptions:
            const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));
  }

  Stream<List<ViewerItem>> watchAllItems() {
    final folderStream = _db
        .watchAllFolders(
            includeOptions:
                const IncludeOptions<AppDataInclude>({AppDataInclude.tags}))
        .map(
          (folders) => folders.map(
            (folder) => ViewerItem(
              id: folder.data.id,
              title: folder.data.title,
              description: folder.data.description,
              type: FolderItemType.folder,
              tags: folder.tags,
              createdAt: folder.data.createdAt,
            ),
          ),
        );

    final linkStream = _db
        .watchAllLinks(
            includeOptions:
                const IncludeOptions<AppDataInclude>({AppDataInclude.tags}))
        .map(
          (links) => links.map(
            (link) => ViewerItem(
              id: link.data.id,
              title: "",
              description: link.data.path,
              type: FolderItemType.link,
              tags: link.tags,
              createdAt: link.data.createdAt,
              url: link.data.path,
            ),
          ),
        );

    return Rx.combineLatestList([folderStream, linkStream])
        .map((lists) => lists.expand((list) => list).toList());
  }
}
