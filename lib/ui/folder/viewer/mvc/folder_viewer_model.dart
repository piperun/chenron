import "dart:async";

import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/folder/remove.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/utils/logger.dart";
import "package:signals/signals.dart";

class FolderViewerModel {
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
      loggerGlobal.severe("FolderViewerModel" "Error deleting folder: $e", e);
      return false;
    }
  }

  Stream<List<FolderResult>> watchAllFolders() async* {
    try {
      final db = await loadDatabase();
      yield* db.watchAllFolders(mode: IncludeFolderData.tags);
    } catch (e) {
      loggerGlobal.severe("FolderViewerModel" "Error watching folders: $e", e);
      yield [];
    }
  }
}
