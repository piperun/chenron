import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/providers/basedir.dart";

import "package:signals/signals.dart";

final appDatabaseAccessorSignal = signal(initializeAppDatabaseAccessor());

Future<AppDatabaseHandler> initializeAppDatabaseAccessor() async {
  final chenronDirs = await chenronDirsSignal.value;

  final databaseName = chenronDirs!.databaseName;
  final databasePath = chenronDirs.dbDir;

  final appDatabase = AppDatabaseHandler(
    databaseLocation: DatabaseLocation(
      databaseDirectory: databasePath,
      databaseFilename: databaseName.path,
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
