import "dart:io";

import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";

class ConfigDatabaseFileHandler {
  final DatabaseLocation databaseLocation;
  //final DatabaseFileOperations _fileOperations;
  ConfigDatabase? _configDatabase;

  ConfigDatabaseFileHandler({required this.databaseLocation});

  ConfigDatabase get configDatabase {
    if (_configDatabase == null) {
      throw StateError(
          "AppDatabase has not been initialized. Call createDatabase() first.");
    }
    return _configDatabase!;
  }

  void createDatabase({
    String? databaseName,
    File? databasePath,
    bool setupOnInit = false,
  }) {
    final String dbName = databaseName ?? databaseLocation.databaseFilename;
    final String path =
        databasePath?.path ?? databaseLocation.databaseFilePath.path;

    _configDatabase?.close();
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
