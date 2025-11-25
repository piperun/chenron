import "package:database/extensions/operations/config_file_handler.dart";
import "package:signals/signals.dart";

final Signal<ConfigDatabaseFileHandler> configDatabaseFileHandlerSignal =
    signal(initializeConfigDatabaseFileHandler());

ConfigDatabaseFileHandler initializeConfigDatabaseFileHandler() {
  final configDatabase = ConfigDatabaseFileHandler();
  return configDatabase;
}

