import "dart:io";

import "package:chenron/base_dirs/schema.dart";
import "package:chenron/locator.dart";
import "package:basedir/directory.dart";
import "package:database/database.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:signals/signals.dart";
import "package:app_logger/app_logger.dart";

const _kAppDatabasePathKey = "app_database_path";

class DataSettingsService {
  Future<String> getDefaultDatabasePath() async {
    final baseDirsFuture =
        locator.get<Signal<Future<BaseDirectories<ChenronDir>?>>>();
    final baseDirs = await baseDirsFuture.value;
    if (baseDirs == null) {
      throw StateError("Base directories not resolved");
    }
    return baseDirs.dir(ChenronDir.database).path;
  }

  Future<String?> getCustomDatabasePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAppDatabasePathKey);
  }

  Future<void> setCustomDatabasePath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_kAppDatabasePathKey);
      loggerGlobal.info(
          "DataSettingsService", "Cleared custom database path.");
    } else {
      await prefs.setString(_kAppDatabasePathKey, path);
      loggerGlobal.info(
          "DataSettingsService", "Set custom database path: $path");
    }
  }

  Future<File?> exportDatabase(Directory destination) async {
    final appDbHandler = locator.get<Signal<AppDatabaseHandler>>().value;
    return appDbHandler.exportDatabase(destination);
  }

  Future<File?> importDatabase(File sourceFile) async {
    final appDbHandler = locator.get<Signal<AppDatabaseHandler>>().value;
    return appDbHandler.importDatabase(
      sourceFile,
      copyImport: true,
      setupOnInit: true,
    );
  }
}
