import "package:database/database.dart";
import "package:database/features.dart";

import "package:chenron/features/viewer/state/chenron_catalog_source.dart";
import "package:chenron/locator.dart";

import "package:app_logger/app_logger.dart";
import "package:signals/signals.dart";

class ViewerModel with ChenronCatalogSource {
  ViewerModel({AppDatabase? database}) : _database = database;

  final AppDatabase? _database;

  AppDatabase get _db =>
      _database ??
      locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;

  @override
  AppDatabase get catalogDatabase => _db;

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
