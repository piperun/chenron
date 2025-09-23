import "dart:io";
import "package:chenron/database/database.dart";
import "package:chenron/database/file_operations.dart";
import "package:chenron/locator.dart";
import "package:basedir/directory.dart";
import "package:chenron/utils/logger.dart";
import "package:path/path.dart" as p;
import "package:signals/signals.dart";
import "package:chenron/base_dirs/schema.dart";

class DatabaseLocation {
  /// This only returns the directory
  final Directory databaseDirectory;
  String databaseFilename;

  /// Gets the full path to the database file as a [File] object.
  File get databaseFilePath {
    return File(p.join(databaseDirectory.path, databaseFilename));
  }

  DatabaseLocation({
    required this.databaseDirectory,
    required this.databaseFilename,
  }) {
    _checkDatabaseDirectory(databaseDirectory);
    _checkDatabaseName(databaseFilename);
  }

  void _checkDatabaseDirectory(Directory dir) {
    if (!dir.existsSync()) {
      throw ArgumentError("The provided database directory does not exist.");
    }
  }

  void _checkDatabaseName(String name) {
    final basename = p.basename(name);
    if (basename != name) {
      throw ArgumentError(
          "databaseFilename should not contain directory paths.");
    }
  }
}

class AppDatabaseHandler {
  final DatabaseLocation databaseLocation;
  final DatabaseFileOperations _fileOperations;
  AppDatabase? _appDatabase;

  static final Map<String, AppDatabaseHandler> _instances = {};

  AppDatabaseHandler({
    required this.databaseLocation,
  }) : _fileOperations = DatabaseFileOperations();

  AppDatabase get appDatabase {
    if (_appDatabase == null) {
      throw StateError(
          "AppDatabase has not been initialized. Call createDatabase() first.");
    }
    return _appDatabase!;
  }

  void initDatabase() {
    if (_appDatabase != null) {
      return;
    }
    _appDatabase = AppDatabase(
      databaseName: databaseLocation.databaseFilename,
      customPath: databaseLocation.databaseFilePath.path,
      setupOnInit: true,
    );
    _appDatabase?.setup();
  }

  void createDatabase({
    String? databaseName,
    File? databasePath,
    bool setupOnInit = false,
  }) {
    final String dbName = databaseName ?? databaseLocation.databaseFilename;
    final String path =
        databasePath?.path ?? databaseLocation.databaseFilePath.path;

    _appDatabase?.close();
    _appDatabase = AppDatabase(
      databaseName: dbName,
      customPath: path,
      setupOnInit: setupOnInit,
    );

    if (setupOnInit) {
      _appDatabase?.setup();
    }
  }

  Future<File?> importDatabase(
    File dbFile, {
    required bool copyImport,
    bool setupOnInit = true,
  }) async {
    File? result;
    if (_checkDatabaseFile(dbFile)) {
      await _appDatabase?.close();

      final baseDirsFutureSignal = locator
          .get<Signal<Future<BaseDirectories<ChenronDir>?>>>();
      final baseDirs = await baseDirsFutureSignal.value ??
          (throw StateError('Base directories not resolved'));
      if (copyImport) {
        result = await _fileOperations.importByCopy(
            dbFile: dbFile, importDirectory: baseDirs.databaseDir);
      } else {
        // Directly use the provided database file
        databaseLocation.databaseFilename = p.basename(dbFile.path);
        result = databaseLocation.databaseFilePath;
      }
      createDatabase(setupOnInit: setupOnInit, databasePath: result);

      // Update the cache key if necessary
      final String key = databaseLocation.databaseFilePath.path;
      _instances[key] = this;
    }
    return result;
  }

  Future<File?> backupDatabase() async {
    File? result;
    final baseDirsFutureSignal =
        locator.get<Signal<Future<BaseDirectories<ChenronDir>?>>>();
    final baseDirs = await baseDirsFutureSignal.value ??
        (throw StateError('Base directories not resolved'));
    try {
      result = await _fileOperations.backupDatabase(
        dbFile: databaseLocation.databaseFilePath,
        backupDirectory: baseDirs.backupAppDir,
      );
    } catch (e) {
      // Handle the exception here
      loggerGlobal.warning(
        "AppDatabaseHandler",
        "An error occurred during database backup: $e",
      );
    }
    return result;
  }

  Future<File?> exportDatabase(Directory exportPath) async {
    File? result;
    try {
      result = await _fileOperations.exportDatabase(
        sourceDbFile: databaseLocation.databaseFilePath,
        exportFilePath:
            File(p.join(exportPath.path, databaseLocation.databaseFilename)),
      );
    } catch (e) {
      loggerGlobal.warning(
          "AppDatabaseHandler", "An error occurred during database export: $e");
    }
    return result;
  }

  Future<void> reloadDatabase() async {
    await _appDatabase?.close();
    createDatabase();
  }

  /// Closes the database and removes the instance from the cache.
  Future<void> closeDatabase() async {
    await _appDatabase?.close();
    _appDatabase = null;
    final String key = databaseLocation.databaseFilePath.path;
    _instances.remove(key);
  }

  bool _checkDatabaseFile(File databaseFile) {
    if (!databaseFile.existsSync()) {
      throw ArgumentError(
          "The provided database file does not exist. ${databaseFile.path}");
    } else {
      return true;
    }
  }
}
