import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/database/extensions/tags/create.dart";
import "package:chenron/locator.dart";
import "package:chenron/utils/directory/directory.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:path/path.dart" as p;
import "dart:io";

import "package:signals/signals.dart";

Future<void> setUpFakeData(AppDatabase database, {int len = 5}) async {
  for (int i = 0; i < len; i++) {
    await database.addTag("test_tag$i");
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseLocation databaseLocation;
  late AppDatabaseHandler databaseHandler;
  const String createdFilename = "original_test_db.sqlite";
  late File createdFilePath;
  late File? importedFilePath;
  late File? exportedFilePath;
  late ChenronDirectories? baseDir;

  setUp(
    () async {
      baseDir = await locator.get<Signal<Future<ChenronDirectories?>>>().value;
      if (baseDir == null) {
        throw Exception("Base directory is null");
      }

      createdFilePath = File(p.join(baseDir!.dbDir.path, createdFilename));
      databaseLocation = DatabaseLocation(
          databaseDirectory: baseDir!.dbDir, databaseFilename: createdFilename);

      databaseHandler = AppDatabaseHandler(databaseLocation: databaseLocation);
      databaseHandler.createDatabase(
          databaseName: createdFilename, setupOnInit: true);
      await setUpFakeData(databaseHandler.appDatabase);
    },
  );
  tearDown(() async {});

  group("Database Import Tests", () {
    test("importDatabase creates a new database file", () async {
      importedFilePath = await databaseHandler.importDatabase(createdFilePath,
          setupOnInit: false, copyImport: true);
      expect(await importedFilePath?.exists(), true,
          reason: "File at $createdFilePath does not exist");
    });
    test("importDatabase imports database file", () async {
      importedFilePath = await databaseHandler.importDatabase(createdFilePath,
          setupOnInit: false, copyImport: false);
      expect(await importedFilePath?.exists(), true,
          reason: "File at $createdFilePath does not exist");
    });
    test("importDatabase throws when given invalid path", () async {
      expect(
          databaseHandler.importDatabase(createdFilePath,
              setupOnInit: false, copyImport: false),
          throwsA(isA<Error>()));
    });
  });
  group("Export Database Tests", () {
    tearDown(() async {
      if (exportedFilePath != null) {
        await exportedFilePath?.delete();
      }
    });
    test("exportDatabase exports database file", () async {
      exportedFilePath =
          await databaseHandler.exportDatabase(Directory.systemTemp);

      expect(await exportedFilePath?.exists(), true,
          reason: "File at $createdFilePath does not exist");
    });
    test("exportDatabase throws when source database file does not exist",
        () async {
      final invalidDirectory =
          Directory(p.join(Directory.systemTemp.path, "invalid_dir"));
      exportedFilePath = await databaseHandler.exportDatabase(invalidDirectory);
      expect(
        exportedFilePath,
        isNull,
      );
    });
  });
  group("Backup Database Tests", () {
    test("backupDatabase creates a backup of the database file", () async {
      File? backupResult = await databaseHandler.backupDatabase();
      expect(backupResult, isNotNull);
      expect(await backupResult?.exists(), true,
          reason: "File at $createdFilePath does not exist");
    });
  });
}
