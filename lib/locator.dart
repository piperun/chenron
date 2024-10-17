import "package:chenron/database/extensions/operations/config_file_handler.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/providers/appdatabase_provider.dart";
import "package:chenron/providers/basedir.dart";
import "package:chenron/providers/configdatabase.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/providers/stepper_provider.dart";
import "package:chenron/utils/directory/directory.dart";
import "package:get_it/get_it.dart";
import "package:signals/signals_flutter.dart";

final locator = GetIt.I;

void locatorSetup() {
  // FIXME: For some reason Dependency Injection just LOVES to do multiple updates
  // to the same signal. There are still to many factors to debug this.
  // For now, we'll just use global signal for databases for now.
  // This is a temporary solution until we can figure out why this is happening.
  // Because it really shouldn't be so damn hard for a dependency injection library
  // to pinky promise not to update the same signal multiple times.

  locator.registerSingleton<Signal<Future<AppDatabaseHandler>>>(
      signal(initializeAppDatabaseAccessor()));
  locator.registerSingleton<FutureSignal<ConfigDatabaseFileHandler>>(
      futureSignal(initializeConfigDatabaseFileHandler));

  locator.registerSingleton<FutureSignal<ChenronDirectories>>(
      futureSignal(initializeChenronDirs));
  locator.registerSingleton<Signal<FolderStepper>>(
      signal(FolderStepper(), autoDispose: true));
  locator.registerSingleton<Signal<FolderDraft>>(
      signal(FolderDraft(), autoDispose: true));
}
