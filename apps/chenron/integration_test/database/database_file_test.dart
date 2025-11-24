import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/database/extensions/tags/create.dart";
import "package:chenron/locator.dart";
import "package:basedir/directory.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:path/path.dart" as p;
import "dart:io";

import "package:signals/signals.dart";

import "package:chenron_mockups/chenron_mockups.dart";
import "package:chenron/base_dirs/schema.dart";

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
    final tempBase = Directory.systemTemp.createTempSync("chenron_base_dir");

    final testDirs = BaseDirectories<ChenronDir>(
      appName: "chenron",
      platformBaseDir: tempBase,
      schema: chenronSchema,
      debugMode: true,
    );
    await testDirs.create(include: {
      ChenronDir.database,
      ChenronDir.backupApp,
      ChenronDir.backupConfig,
      ChenronDir.log,
    });

    locator.registerSingleton<Signal<Future<BaseDirectories<ChenronDir>?>>>(
      signal(Future.value(testDirs)),
    );
  });

  late DatabaseLocation databaseLocation;
  late AppDatabaseHandler databaseHandler;
  const String createdFilename = "original_test_db.sqlite";
  late File createdFilePath;
  late File? importedFilePath;
  late File? exportedFilePath;
  late BaseDirectories<ChenronDir>? baseDirs;

  setUp(
    () async {
      baseDirs = await locator
          .get<Signal<Future<BaseDirectories<ChenronDir>?>>>()
          .value;
      if (baseDirs == null) {
        throw Exception("Base directories are null");
      }

      createdFilePath =
          File(p.join(baseDirs!.databaseDir.path, createdFilename));
      databaseLocation = DatabaseLocation(
          databaseDirectory: baseDirs!.databaseDir,
          databaseFilename: createdFilename);

      databaseHandler = AppDatabaseHandler(databaseLocation: databaseLocation);
      await databaseHandler.createDatabase(
          databaseName: createdFilename, setupOnInit: true);
      await setUpFakeData(databaseHandler.appDatabase);
    },
  );
  tearDown(() async {});

  group("Database Import Tests", () {
    test("importDatabase creates a new database file", () async {
      importedFilePath = await databaseHandler.importDatabase(createdFilePath,
          setupOnInit: false, copyImport: true);
      expect(importedFilePath?.existsSync(), true,
          reason: "File at $createdFilePath does not exist");
    });
    test("importDatabase imports database file", () async {
      importedFilePath = await databaseHandler.importDatabase(createdFilePath,
          setupOnInit: false, copyImport: false);
      expect(importedFilePath?.existsSync(), true,
          reason: "File at $createdFilePath does not exist");
    });
    test("importDatabase throws when given invalid path", () async {
      final invalidPath =
          File(p.join(baseDirs!.databaseDir.path, "nonexistent.sqlite"));
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

      expect(exportedFilePath?.existsSync(), true,
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
      final File? backupResult = await databaseHandler.backupDatabase();
      expect(backupResult, isNotNull);
      expect(backupResult?.existsSync(), true,
          reason: "File at $createdFilePath does not exist");
    });
  });
}
