import "dart:async";

import "package:database/database.dart";
import "package:database/extensions/folder/read.dart";
import "package:database/extensions/folder/remove.dart";
import "package:database/extensions/link/read.dart";
import "package:database/extensions/link/remove.dart";
import "package:database/extensions/operations/database_file_handler.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/locator.dart";
import "package:database/models/db_result.dart" show FolderResult;
import "package:database/models/item.dart";
import "package:logger/logger.dart";
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
      yield* db.watchAllFolders(
          includeOptions:
              const IncludeOptions<AppDataInclude>({AppDataInclude.tags}));
    } catch (e) {
      loggerGlobal.severe("ViewerModel" "Error watching folders: $e", e);
      yield [];
    }
  }

  Stream<List<ViewerItem>> watchAllItems() async* {
    final db = await loadDatabase();
    final folderStream = db
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

    final linkStream = db
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

    yield* Rx.combineLatestList([folderStream, linkStream])
        .map((lists) => lists.expand((list) => list).toList());
  }
}

