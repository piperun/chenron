import "package:database/database.dart";
import "package:signals/signals.dart";

final Signal<ConfigDatabaseFileHandler> configDatabaseFileHandlerSignal =
    signal(initializeConfigDatabaseFileHandler());

ConfigDatabaseFileHandler initializeConfigDatabaseFileHandler() {
  final configDatabase = ConfigDatabaseFileHandler();
  return configDatabase;
}
