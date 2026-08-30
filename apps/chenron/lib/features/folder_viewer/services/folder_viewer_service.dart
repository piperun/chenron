import "package:database/database.dart";
import "package:core/patterns/include_options.dart";
import "package:database/features.dart";
import "package:chenron/features/viewer/state/chenron_catalog_source.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";
import "package:app_logger/app_logger.dart";
import "package:shared_preferences/shared_preferences.dart";

class FolderViewerService with ChenronCatalogSource {
  FolderViewerService({AppDatabase? database}) : _database = database;

  static const _lockKey = "folder_viewer_header_locked";
  final AppDatabase? _database;

  AppDatabase get _db =>
      _database ??
      locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;

  @override
  AppDatabase get catalogDatabase => _db;

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
