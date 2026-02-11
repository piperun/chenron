import "package:chenron/providers/appdatabase_provider.dart";
import "package:chenron/providers/basedir.dart";
import "package:chenron/providers/configdatabase.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:basedir/directory.dart";
import "package:get_it/get_it.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/theme/state/theme_manager.dart";
import "package:database/database.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/base_dirs/schema.dart";
import "package:chenron/services/activity_tracker.dart";

final locator = GetIt.I;

void locatorSetup() {
  locator
      .registerSingleton<Signal<AppDatabaseHandler>>(appDatabaseAccessorSignal);
  locator.registerSingleton<Signal<ConfigDatabaseFileHandler>>(
      signal(initializeConfigDatabaseFileHandler()));

  locator.registerSingleton<Signal<Future<BaseDirectories<ChenronDir>?>>>(
      baseDirsSignal);
  locator.registerSingleton<Signal<FolderSignal>>(
      signal(FolderSignal(), autoDispose: true));

  locator.registerLazySingleton<ThemeManager>(() {
    final configHandlerSignal = locator<Signal<ConfigDatabaseFileHandler>>();
    final ConfigDatabaseFileHandler configHandler = configHandlerSignal.value;
    final ConfigDatabase configDb = configHandler.configDatabase;
    return ThemeManager(configDb);
  });

  // Register ConfigService
  locator.registerLazySingleton<ConfigService>(ConfigService.new);

  // Register DataSettingsService
  locator.registerLazySingleton<DataSettingsService>(DataSettingsService.new);

  // Register ConfigController
  locator.registerLazySingleton<ConfigController>(ConfigController.new);

  // Register DatabaseBackupScheduler
  locator.registerLazySingleton<DatabaseBackupScheduler>(() {
    final appDbHandler = locator.get<Signal<AppDatabaseHandler>>().value;
    final configHandler =
        locator.get<Signal<ConfigDatabaseFileHandler>>().value;
    return DatabaseBackupScheduler(
      databaseHandler: appDbHandler,
      configHandler: configHandler,
    );
  });

  // Register ActivityTracker
  locator.registerLazySingleton<ActivityTracker>(() {
    final db = locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;
    return ActivityTracker(db);
  });
}
