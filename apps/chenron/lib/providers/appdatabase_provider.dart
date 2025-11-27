import "package:database/extensions/operations/database_file_handler.dart";
import "package:signals/signals.dart";

final appDatabaseAccessorSignal = signal(initializeAppDatabaseAccessor());

AppDatabaseHandler initializeAppDatabaseAccessor() {
  // Database location will be set later during main_setup
  // Similar to how ConfigDatabase works
  return AppDatabaseHandler();
}
