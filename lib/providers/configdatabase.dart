import "package:chenron/database/extensions/operations/config_file_handler.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:chenron/utils/directory/directory.dart";
import "package:signals/signals.dart";

final Signal<Future<ConfigDatabaseFileHandler>>
    configDatabaseFileHandlerSignal =
    signal(initializeConfigDatabaseFileHandler());

Future<ConfigDatabaseFileHandler> initializeConfigDatabaseFileHandler() async {
  final chenronDirs =
      await locator.get<FutureSignal<ChenronDirectories>>().future;

  final databaseName = "config.sqlite";
  final databasePath = chenronDirs.configDir;

  final configDatabase = ConfigDatabaseFileHandler(
    databaseLocation: DatabaseLocation(
      databaseDirectory: databasePath,
      databaseFilename: databaseName,
    ),
  );
  configDatabase.createDatabase(setupOnInit: true);

  return configDatabase;
}
