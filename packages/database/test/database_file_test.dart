import "dart:io";

import "package:basedir/directory.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/dir_schema.dart";
import "package:database/locator.dart";
import "package:database/main.dart";
import "package:database/src/features/tag/create.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as p;

Future<void> setUpFakeData(AppDatabase database, {int len = 5}) async {
  for (int i = 0; i < len; i++) {
    await database.addTag("test_tag$i");
  }
}

void main() {
  setUpAll(() async {
    installFakePathProvider();
    installTestLogger();

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

    locator.registerSingleton<Future<BaseDirectories<ChenronDir>?>>(
      Future.value(testDirs),
    );
  });

  late DatabaseLocation databaseLocation;
  late AppDatabaseLifecycle lifecycle;
  late AppFileService fileService;
  const String createdFilename = "original_test_db.sqlite";
  late File createdFilePath;
  late File? importedFilePath;
  late File? exportedFilePath;
  late BaseDirectories<ChenronDir>? baseDirs;

  setUp(() async {
    baseDirs = await locator.get<Future<BaseDirectories<ChenronDir>?>>();
    if (baseDirs == null) {
      throw Exception("Base directories are null");
    }

    createdFilePath =
        File(p.join(baseDirs!.databaseDir.path, createdFilename));
    databaseLocation = DatabaseLocation(
        databaseDirectory: baseDirs!.databaseDir,
        databaseFilename: createdFilename);

    lifecycle = AppDatabaseLifecycle(databaseLocation: databaseLocation);
    await lifecycle.createDatabase(
        databaseName: createdFilename, setupOnInit: true);
    fileService = AppFileService(lifecycle: lifecycle);
    await setUpFakeData(lifecycle.appDatabase);
  });

  tearDown(() async {});

  group("Database Import Tests", () {
    test("importDatabase creates a new database file", () async {
      importedFilePath = await fileService.importDatabase(createdFilePath,
          setupOnInit: false, copyImport: true);
      expect(importedFilePath?.existsSync(), true,
          reason: "File at $createdFilePath does not exist");
    });
    test("importDatabase imports database file", () async {
      importedFilePath = await fileService.importDatabase(createdFilePath,
          setupOnInit: false, copyImport: false);
      expect(importedFilePath?.existsSync(), true,
          reason: "File at $createdFilePath does not exist");
    });
    test("importDatabase throws when given invalid path", () async {
      final invalidPath =
          File(p.join(baseDirs!.databaseDir.path, "nonexistent.sqlite"));
      expect(
          fileService.importDatabase(invalidPath,
              setupOnInit: false, copyImport: false),
          throwsA(isA<ArgumentError>()));
    });
  });
  group("Export Database Tests", () {
    tearDown(() async {
      final f = exportedFilePath;
      if (f != null && f.existsSync()) {
        await f.delete();
      }
      exportedFilePath = null;
    });
    test("exportDatabase exports database file", () async {
      exportedFilePath = await fileService.exportDatabase(Directory.systemTemp);

      expect(exportedFilePath?.existsSync(), true,
          reason: "File at $createdFilePath does not exist");
    });
    test("exportDatabase throws when destination directory is invalid",
        () async {
      final invalidDirectory =
          Directory(p.join(Directory.systemTemp.path, "invalid_dir"));
      await expectLater(
        fileService.exportDatabase(invalidDirectory),
        throwsA(anything),
      );
    });
  });
  group("Backup Database Tests", () {
    test("backupDatabase creates a backup of the database file", () async {
      final backupResult = await fileService.backupDatabase();
      expect(backupResult.existsSync(), true,
          reason: "File at ${backupResult.path} does not exist");
    });
  });
}
