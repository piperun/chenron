import "package:database/database.dart";
import "package:signals/signals.dart";

final Signal<ConfigDatabaseLifecycle> configDatabaseFileHandlerSignal =
    signal(initializeConfigDatabaseLifecycle());

ConfigDatabaseLifecycle initializeConfigDatabaseLifecycle() {
  final configDatabase = ConfigDatabaseLifecycle();
  return configDatabase;
}
