import "package:database/database.dart";

import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/locator.dart";
import "package:database/main.dart";

import "package:logger/logger.dart";
import "package:rxdart/rxdart.dart";
import "package:signals/signals.dart";

class ViewerModel {
  AppDatabase get _db =>
      locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;

  Future<bool> removeFolder(String folder) async {
    try {
      await _db.removeFolder(folder);
      return true;
    } catch (e) {
      loggerGlobal.severe("ViewerModel" "Error deleting folder: $e", e);
      return false;
    }
  }

  Future<bool> removeLink(String linkId) async {
    try {
      await _db.removeLink(linkId);
      return true;
    } catch (e) {
      loggerGlobal.severe("ViewerModel" "Error deleting link: $e", e);
      return false;
    }
  }

  Future<bool> removeDocument(String documentId) async {
    try {
      await _db.removeDocument(documentId);
      return true;
    } catch (e) {
      loggerGlobal.severe("ViewerModel" "Error deleting document: $e", e);
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
