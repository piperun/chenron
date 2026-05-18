import "dart:io";

import "package:database/database.dart";
import "package:drift/drift.dart";
import "package:meta/meta.dart";
import "package:path/path.dart" as p;

/// Where a database file lives on disk.
///
/// Immutable — callers create a new instance via [withFilename] rather
/// than mutating an existing one. Validation runs in the constructor so
/// downstream code can trust both fields.
class DatabaseLocation {
  final Directory databaseDirectory;
  final String databaseFilename;

  DatabaseLocation({
    required this.databaseDirectory,
    required this.databaseFilename,
  }) {
    if (!databaseDirectory.existsSync()) {
      throw ArgumentError("The provided database directory does not exist.");
    }
    if (p.basename(databaseFilename) != databaseFilename) {
      throw ArgumentError(
          "databaseFilename must not contain directory paths.");
    }
  }

  File get databaseFilePath =>
      File(p.join(databaseDirectory.path, databaseFilename));

  /// Returns a new location with the same directory but a different
  /// filename. Useful for adopt-in-place imports.
  DatabaseLocation withFilename(String filename) => DatabaseLocation(
        databaseDirectory: databaseDirectory,
        databaseFilename: filename,
      );
}

/// Owns the lifecycle of a Drift database: build, expose, close, reload.
///
/// File operations (import/export/backup) live on a separate service so
/// the [ConfigDatabase] lifecycle stays small and ergonomic and only the
/// app database can be backed up or restored.
///
/// [databaseLocation] is mutable to support the two-stage init pattern
/// in `MainSetup` (register shell, assign location once base directories
/// resolve) and to support adopt-in-place imports that change the on-disk
/// filename. Callers must set it before calling [createDatabase].
abstract class DatabaseLifecycle<T extends DatabaseConnectionUser> {
  DatabaseLocation? databaseLocation;
  T? _database;

  DatabaseLifecycle({this.databaseLocation});

  T get database {
    if (_database == null) {
      throw StateError(
          "Database has not been initialized. Call createDatabase() first.");
    }
    return _database!;
  }

  /// Subclasses construct the typed database with the resolved name + path.
  @protected
  T buildDatabase({
    required String databaseName,
    required String customPath,
    required bool setupOnInit,
  });

  /// Optional post-init hook. Called when [createDatabase]'s `setupOnInit`
  /// is true, after the connection has been opened.
  @protected
  Future<void> onAfterSetup(T db) async {}

  /// (Re-)open the database. Awaits both the close of any prior instance
  /// and the optional setup hook before returning.
  Future<void> createDatabase({
    String? databaseName,
    File? databasePath,
    bool setupOnInit = false,
  }) async {
    final location = databaseLocation;
    if (location == null) {
      throw StateError(
          "databaseLocation has not been set. Assign one before calling "
          "createDatabase().");
    }
    final dbName = databaseName ?? location.databaseFilename;
    final path = databasePath?.path ?? location.databaseFilePath.path;

    await _database?.close();
    _database = buildDatabase(
      databaseName: dbName,
      customPath: path,
      setupOnInit: setupOnInit,
    );

    if (setupOnInit) await onAfterSetup(_database!);
  }

  Future<void> reloadDatabase() async {
    await _database?.close();
    await createDatabase();
  }

  Future<void> closeDatabase() async {
    await _database?.close();
    _database = null;
  }
}

/// Lifecycle owner for the main [AppDatabase].
///
/// Use [AppFileService] for import / export / backup operations.
class AppDatabaseLifecycle extends DatabaseLifecycle<AppDatabase> {
  AppDatabaseLifecycle({super.databaseLocation});

  /// Typed alias for [database]. Reads more naturally at call sites.
  AppDatabase get appDatabase => database;

  @override
  AppDatabase buildDatabase({
    required String databaseName,
    required String customPath,
    required bool setupOnInit,
  }) =>
      AppDatabase(
        databaseName: databaseName,
        customPath: customPath,
        setupOnInit: setupOnInit,
      );

  @override
  Future<void> onAfterSetup(AppDatabase db) => db.setup();
}

/// Lifecycle owner for the [ConfigDatabase].
class ConfigDatabaseLifecycle extends DatabaseLifecycle<ConfigDatabase> {
  ConfigDatabaseLifecycle({super.databaseLocation});

  /// Typed alias for [database]. Reads more naturally at call sites.
  ConfigDatabase get configDatabase => database;

  @override
  ConfigDatabase buildDatabase({
    required String databaseName,
    required String customPath,
    required bool setupOnInit,
  }) =>
      ConfigDatabase(
        databaseName: databaseName,
        customPath: customPath,
        setupOnInit: setupOnInit,
      );

  @override
  Future<void> onAfterSetup(ConfigDatabase db) => db.setup();
}
