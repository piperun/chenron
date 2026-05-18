import "package:chenron/providers/appdatabase_provider.dart";
import "package:chenron/providers/basedir.dart";
import "package:chenron/providers/configdatabase.dart";
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
      .registerSingleton<Signal<AppDatabaseLifecycle>>(appDatabaseAccessorSignal);
  locator.registerSingleton<Signal<ConfigDatabaseLifecycle>>(
      signal(initializeConfigDatabaseLifecycle()));

  locator.registerSingleton<Signal<Future<BaseDirectories<ChenronDir>?>>>(
      baseDirsSignal);

  locator.registerLazySingleton<ThemeManager>(() {
    final configHandlerSignal = locator<Signal<ConfigDatabaseLifecycle>>();
    final ConfigDatabaseLifecycle configHandler = configHandlerSignal.value;
    final ConfigDatabase configDb = configHandler.configDatabase;
    return ThemeManager(configDb);
  });

  // Register ConfigService
  locator.registerLazySingleton<ConfigService>(ConfigService.new);

  // Register DataSettingsService
  locator.registerLazySingleton<DataSettingsService>(DataSettingsService.new);

  // Register ConfigController
  locator.registerLazySingleton<ConfigController>(ConfigController.new);

  // Register AppFileService (depends on the app database lifecycle)
  locator.registerLazySingleton<AppFileService>(() {
    final lifecycle = locator.get<Signal<AppDatabaseLifecycle>>().value;
    return AppFileService(lifecycle: lifecycle);
  });

  // Register DatabaseBackupScheduler
  locator.registerLazySingleton<DatabaseBackupScheduler>(() {
    final fileService = locator.get<AppFileService>();
    final configLifecycle =
        locator.get<Signal<ConfigDatabaseLifecycle>>().value;
    return DatabaseBackupScheduler(
      fileService: fileService,
      configLifecycle: configLifecycle,
    );
  });

  // Register ActivityTracker
  locator.registerLazySingleton<ActivityTracker>(() {
    final db = locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;
    return ActivityTracker(db);
  });
}
