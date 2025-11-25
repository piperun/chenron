import "package:database/extensions/operations/database_file_handler.dart";
import "package:chenron/providers/basedir.dart";

import "package:signals/signals.dart";
import "package:chenron/base_dirs/schema.dart";

final appDatabaseAccessorSignal = signal(initializeAppDatabaseAccessor());

Future<AppDatabaseHandler> initializeAppDatabaseAccessor() async {
  final baseDirs = await baseDirsSignal.value;

  final databaseDirectory = baseDirs!.databaseDir;
  const databaseFilename = "app.sqlite";

  final appDatabase = AppDatabaseHandler(
    databaseLocation: DatabaseLocation(
      databaseDirectory: databaseDirectory,
      databaseFilename: databaseFilename,
    ),
  );
  appDatabase.initDatabase();

  return appDatabase;
}
/*
  static Signal<AppDatabase>? _instance;
  static final Signal<AppDatabase> instance = () {
    if (_instance == null) {
      final db = AppDatabase();
      _instance = signal(db)..onDispose(db.close);
    }
    return _instance!;
  }();
}
*/

