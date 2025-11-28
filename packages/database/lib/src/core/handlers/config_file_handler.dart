import "dart:io";

import "package:database/main.dart";
import "package:database/src/core/handlers/database_file_handler.dart";

class ConfigDatabaseFileHandler {
  DatabaseLocation? databaseLocation;
  ConfigDatabase? _configDatabase;

  ConfigDatabaseFileHandler({this.databaseLocation});

  ConfigDatabase get configDatabase {
    if (_configDatabase == null) {
      throw StateError(
          "ConfigDatabase has not been initialized. Call createDatabase() first.");
    }
    return _configDatabase!;
  }

  Future<void> createDatabase({
    String? databaseName,
    File? databasePath,
    bool setupOnInit = false,
  }) async {
    if (databaseLocation == null) {
      throw StateError(
          "DatabaseLocation is null. Please provide a valid DatabaseLocation.");
    }
    final String dbName = databaseName ?? databaseLocation!.databaseFilename;
    final String path =
        databasePath?.path ?? databaseLocation!.databaseFilePath.path;

    await _configDatabase?.close();
    _configDatabase = ConfigDatabase(
      databaseName: dbName,
      customPath: path,
      setupOnInit: setupOnInit,
    );

    if (setupOnInit) {
      _configDatabase?.setup();
    }
  }
}
