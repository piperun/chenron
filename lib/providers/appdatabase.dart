import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/providers/basedir.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

// Necessary for code-generation to work
part "appdatabase.g.dart";

/// This will create a provider named `activityProvider`
/// which will cache the result of this function.
@riverpod
Future<AppDatabaseHandler> appDatabase(AppDatabaseRef ref) async {
  ProviderContainer container = ProviderContainer();
  final baseDir = await container.read(chenronBaseDirsProvider.future);
  final databaseName = baseDir.databaseName;
  final databasePath = baseDir.dbDir;
  final appDatabase = AppDatabaseHandler(
    databaseLocation: DatabaseLocation(
        databaseDirectory: databasePath, databaseFilename: databaseName.path),
  );
  appDatabase.createDatabase(setupOnInit: true);

  return appDatabase;
}
