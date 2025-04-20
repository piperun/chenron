import "package:chenron/database/extensions/operations/config_file_handler.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/features/theme/controller/theme_controller.dart";
import "package:chenron/providers/appdatabase_provider.dart";
import "package:chenron/providers/basedir.dart";
import "package:chenron/providers/configdatabase.dart";
import "package:chenron/providers/folder_provider.dart";
import "package:chenron/utils/directory/directory.dart";
import "package:get_it/get_it.dart";
import "package:signals/signals_flutter.dart";
import 'package:chenron/features/settings/service/config_service.dart';
import 'package:chenron/features/settings/controller/config_controller.dart';

final locator = GetIt.I;

void locatorSetup() {
  locator.registerSingleton<Signal<Future<AppDatabaseHandler>>>(
      signal(initializeAppDatabaseAccessor()));
  locator.registerSingleton<Signal<ConfigDatabaseFileHandler>>(
      signal(initializeConfigDatabaseFileHandler()));

  locator.registerSingleton<Signal<Future<ChenronDirectories?>>>(
      signal(initializeChenronDirs()));
  locator.registerSingleton<Signal<FolderSignal>>(
      signal(FolderSignal(), autoDispose: true));
  locator.registerSingleton<ThemeController>(ThemeController());

  locator.registerLazySingleton<ConfigService>(() => ConfigService());
  locator.registerLazySingleton<ConfigController>(() => ConfigController());
}
