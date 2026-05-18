import "dart:io";

import "package:app_logger/app_logger.dart";
import "package:basedir/directory.dart";
import "package:database/dir_schema.dart";
import "package:database/file_operations.dart";
import "package:database/locator.dart";
import "package:database/src/core/handlers/database_lifecycle.dart";
import "package:path/path.dart" as p;

/// Disk-side file operations (import, export, backup) for the main
/// [AppDatabase].
///
/// Composed over an [AppDatabaseLifecycle] so a single live connection is
/// always coordinated: import/restore closes the current database, swaps
/// the file, and re-opens it via the lifecycle.
///
/// `backupDatabase` and `exportDatabase` rethrow on failure — callers
/// must wrap in try/catch if they want to tolerate silent failures.
class AppFileService {
  final AppDatabaseLifecycle lifecycle;
  final DatabaseFileOperations _fileOperations;

  AppFileService({
    required this.lifecycle,
    DatabaseFileOperations? fileOperations,
  }) : _fileOperations = fileOperations ?? DatabaseFileOperations();

  /// Import a database file.
  ///
  /// When [copyImport] is true the file is copied into the app's database
  /// directory; when false the file is adopted in place by updating the
  /// lifecycle's [DatabaseLocation] to point at it.
  ///
  /// Throws [ArgumentError] if the source file is missing; otherwise
  /// returns the resolved on-disk path of the now-active database.
  Future<File> importDatabase(
    File dbFile, {
    required bool copyImport,
    bool setupOnInit = true,
  }) async {
    if (!dbFile.existsSync()) {
      throw ArgumentError(
          "The provided database file does not exist. ${dbFile.path}");
    }

    await lifecycle.closeDatabase();

    final baseDirs = await _resolveBaseDirs();

    final File result;
    if (copyImport) {
      result = await _fileOperations.importByCopy(
        dbFile: dbFile,
        importDirectory: baseDirs.databaseDir,
      );
    } else {
      final current = _requireLocation();
      lifecycle.databaseLocation =
          current.withFilename(p.basename(dbFile.path));
      result = lifecycle.databaseLocation!.databaseFilePath;
    }

    await lifecycle.createDatabase(
      setupOnInit: setupOnInit,
      databasePath: result,
    );
    return result;
  }

  /// Copy the live database to the configured backup directory.
  /// Logs a warning and rethrows on failure.
  Future<File> backupDatabase() async {
    final baseDirs = await _resolveBaseDirs();
    final location = _requireLocation();
    try {
      return await _fileOperations.backupDatabase(
        dbFile: location.databaseFilePath,
        backupDirectory: baseDirs.backupAppDir,
      );
    } catch (e) {
      loggerGlobal.warning(
        "AppFileService",
        "Database backup failed: $e",
      );
      rethrow;
    }
  }

  /// Copy the live database to a user-chosen [exportPath] directory.
  /// Logs a warning and rethrows on failure.
  Future<File> exportDatabase(Directory exportPath) async {
    final location = _requireLocation();
    try {
      return await _fileOperations.exportDatabase(
        sourceDbFile: location.databaseFilePath,
        exportFilePath: File(p.join(
          exportPath.path,
          location.databaseFilename,
        )),
      );
    } catch (e) {
      loggerGlobal.warning(
        "AppFileService",
        "Database export failed: $e",
      );
      rethrow;
    }
  }

  DatabaseLocation _requireLocation() {
    final location = lifecycle.databaseLocation;
    if (location == null) {
      throw StateError(
          "Lifecycle has no databaseLocation. File ops require an "
          "initialized lifecycle.");
    }
    return location;
  }

  Future<BaseDirectories<ChenronDir>> _resolveBaseDirs() async {
    final baseDirs =
        await locator.get<Future<BaseDirectories<ChenronDir>?>>();
    if (baseDirs == null) {
      throw StateError("Base directories not resolved");
    }
    return baseDirs;
  }
}
