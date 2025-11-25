import "package:database/database.dart";
import "package:database/schema/user_config_schema.dart";
import "package:logger/logger.dart";
import "package:drift/drift.dart";

extension UserThemeRemoveExtensions on ConfigDatabase {
  Future<void> removeUserTheme({
    required String id,
  }) async {
    await _removeThemesWhere(
      (tbl) => tbl.id.equals(id),
      singleThemeLog: true,
    );
  }

  Future<void> removeUserThemes({
    required List<String> ids,
  }) async {
    if (ids.isEmpty) {
      loggerGlobal.warning(
          "UserTheme", "Attempted to remove themes with empty ID list.");
      return;
    }
    await _removeThemesWhere(
      (tbl) => tbl.id.isIn(ids),
      singleThemeLog: ids.length == 1,
    );
  }

  Future<void> _removeThemesWhere(
    Expression<bool> Function(UserThemes tbl) filter, {
    bool singleThemeLog = false,
  }) async {
    return transaction(() async {
      try {
        final deletedCount = await (delete(userThemes)..where(filter)).go();

        if (singleThemeLog) {
          if (deletedCount > 0) {
            loggerGlobal.info("UserTheme", "User theme deleted successfully.");
          } else {
            loggerGlobal.warning("UserTheme",
                "Attempted to delete a single user theme, but it was not found.");
          }
        } else {
          if (deletedCount > 0) {
            loggerGlobal.info(
                "UserTheme", "$deletedCount user themes deleted successfully.");
          } else {
            loggerGlobal.warning("UserTheme",
                "Attempted to delete multiple user themes, but none were found matching the criteria.");
          }
        }
      } catch (e) {
        final errorMsg = singleThemeLog
            ? "Error deleting user theme: $e"
            : "Error deleting multiple user themes: $e";
        loggerGlobal.severe("UserTheme", errorMsg);
        rethrow;
      }
    });
  }
}


