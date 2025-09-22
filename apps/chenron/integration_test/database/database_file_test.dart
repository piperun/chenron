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

import "package:chenron/test_support/path_provider_fake.dart";
import "package:chenron/test_support/logger_setup.dart";

Future<void> setUpFakeData(AppDatabase database, {int len = 5}) async {
  for (int i = 0; i < len; i++) {
    await database.addTag("test_tag$i");
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Install fake path_provider and configure DI before any signals resolve
  setUpAll(() async {
    installFakePathProvider();
    installTestLogger();

    // Provide a test-specific base directory via GetIt without full locator setup
    await locator.reset();
    final tempBase = Directory.systemTemp.createTempSync('chenron_base_dir');
    final testDirs = ChenronDirectories(
      databaseName: File('app.sqlite'),
      baseDir: tempBase,
    );
    await testDirs.createDirectories();
    locator.registerSingleton<Signal<Future<ChenronDirectories?>>>(
      signal(Future.value(testDirs)),
    );
  });

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
      final invalidPath = File(p.join(baseDir!.dbDir.path, 'nonexistent.sqlite'));
      expect(
          databaseHandler.importDatabase(invalidPath,
              setupOnInit: false, copyImport: false),
          throwsA(isA<ArgumentError>()));
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
