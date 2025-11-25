import "dart:io";
import "dart:isolate";
import "package:crypto/crypto.dart";
import "package:cuid2/cuid2.dart";
import "package:intl/intl.dart";
import "package:path/path.dart" as p;
import "package:sqlite3/sqlite3.dart";

/// A base class providing file operations for database management.
/// This class can be inherited, mixed in, or composed to provide
/// database file handling capabilities.
class DatabaseFileOperations {
  /// Backs up the [dbFile] to the specified [backupDirectory].
  ///
  /// The backup file is named using the standard convention:
  /// `<database_name>_backup_<YYYYMMDD_HHMMSS>.sqlite`.
  ///
  /// Throws an [ArgumentError] if the [backupDirectory] does not exist.
  Future<File> backupDatabase({
    required File dbFile,
    required Directory backupDirectory,
  }) async {
    if (!backupDirectory.existsSync()) {
      throw ArgumentError("The backup directory does not exist.");
    }
    File result;

    final databaseName = p.basenameWithoutExtension(dbFile.path);

    final String formattedDate =
        DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());
    final String backupFileName =
        "${databaseName}_backup_$formattedDate.sqlite";
    final File backupFilePath =
        File(p.join(backupDirectory.path, backupFileName));

    try {
      result = await exportDatabase(
          sourceDbFile: dbFile, exportFilePath: backupFilePath);
    } catch (e) {
      rethrow;
    }
    return result;
  }

  /// Imports the [dbFile] by copying it to the [importDirectory].
  ///
  /// If a file with the same hash already exists in the [importDirectory],
  /// that file is returned instead of copying.
  ///
  /// The copied file is named as:
  /// `imported_<database_name>_<cuid>.sqlite`, where `cuid` is an 8-character
  /// unique identifier.
  ///
  /// Throws an [ArgumentError] if the [importDirectory] does not exist.
  Future<File> importByCopy({
    required File dbFile,
    required Directory importDirectory,
  }) async {
    if (!importDirectory.existsSync()) {
      throw ArgumentError("The import directory does not exist.");
    }

    final sourceBytes = await dbFile.readAsBytes();
    final sourceHash = sha256.convert(sourceBytes).toString();

    final existingFiles = importDirectory.listSync();
    for (var entity in existingFiles) {
      if (entity is File) {
        final entityBytes = await entity.readAsBytes();
        final entityHash = sha256.convert(entityBytes).toString();
        if (entityHash == sourceHash) {
          // Matching file found, use this file
          return entity;
        }
      }
    }

    final cuidString = cuidSecure(8); // Generate a unique 8-character CUID

    final databaseName = p.basenameWithoutExtension(dbFile.path);
    final newFileName = "imported_${databaseName}_$cuidString.sqlite";
    final File importFilePath = File(p.join(importDirectory.path, newFileName));

    // Copy the database file to the import directory
    await dbFile.copy(importFilePath.path);

    return importFilePath;
  }

  /// Exports the [dbFile] to the [exportFilePath] using SQLite's `VACUUM INTO` command.
  ///
  /// This ensures a consistent backup of the database.
  Future<File> exportDatabase({
    required File sourceDbFile,
    required File exportFilePath,
  }) async {
    await Isolate.run(() {
      final database = sqlite3.open(sourceDbFile.path);
      try {
        database.execute("VACUUM INTO ?", [exportFilePath.path]);
      } catch (e) {
        rethrow;
      } finally {
        database.dispose();
      }
    });
    return exportFilePath;
  }
}


