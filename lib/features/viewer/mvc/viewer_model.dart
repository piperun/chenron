import "dart:async";

import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/folder/remove.dart";
import "package:chenron/database/extensions/link/read.dart";
import "package:chenron/database/extensions/link/remove.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/locator.dart";
import "package:chenron/models/item.dart";
import "package:chenron/utils/logger.dart";
import "package:rxdart/rxdart.dart";
import "package:signals/signals.dart";

class ViewerModel {
  Future<AppDatabase> loadDatabase() async {
    final database =
        await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
    return database.appDatabase;
  }

  Future<bool> removeFolder(String folder) async {
    try {
      final db = await loadDatabase();
      await db.removeFolder(folder);
      return true;
    } catch (e) {
      loggerGlobal.severe("ViewerModel" "Error deleting folder: $e", e);
      return false;
    }
  }

  Future<bool> removeLink(String linkId) async {
    try {
      final db = await loadDatabase();
      await db.removeLink(linkId);
      return true;
    } catch (e) {
      loggerGlobal.severe("ViewerModel" "Error deleting link: $e", e);
      return false;
    }
  }

  Future<bool> removeDocument(String documentId) async {
    // TODO: Implement document removal when document feature is added
    return true;
  }

  Stream<List<FolderResult>> watchAllFolders() async* {
    try {
      final db = await loadDatabase();
      yield* db.watchAllFolders(mode: IncludeFolderData.tags);
    } catch (e) {
      loggerGlobal.severe("ViewerModel" "Error watching folders: $e", e);
      yield [];
    }
  }

  Stream<List<ViewerItem>> watchAllItems() async* {
    final db = await loadDatabase();
    final folderStream = db.watchAllFolders(mode: IncludeFolderData.tags).map(
          (folders) => folders.map(
            (folder) => ViewerItem(
              id: folder.folder.id,
              title: folder.folder.title,
              description: folder.folder.description,
              type: FolderItemType.folder,
              tags: folder.tags,
            ),
          ),
        );

    final linkStream = db.watchAllLinks(mode: IncludeLinkData.tags).map(
          (links) => links.map(
            (link) => ViewerItem(
              id: link.link.id,
              title: "",
              description: link.link.content,
              type: FolderItemType.link,
              tags: link.tags,
            ),
          ),
        );

    yield* Rx.combineLatestList([folderStream, linkStream])
        .map((lists) => lists.expand((list) => list).toList());
  }
}
