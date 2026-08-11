import "package:database/database.dart";
import "package:database/features.dart";

import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/locator.dart";

import "package:app_logger/app_logger.dart";
import "package:signals/signals.dart";

class ViewerModel
    implements
        ViewerPageRepository,
        ViewerTagFacetSearchRepository,
        ViewerInvalidationDomainRepository {
  ViewerModel({AppDatabase? database}) : _database = database;

  final AppDatabase? _database;

  AppDatabase get _db =>
      _database ??
      locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;

  @override
  Object get viewerInvalidationDomain => _db;

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
}
