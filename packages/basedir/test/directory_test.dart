import 'dart:io';

import 'package:basedir/directory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

// Local test enum keys for schema
enum TestDir { database, backupApp, backupConfig, log }

const DirSchema<TestDir> testSchema =
    DirSchema<TestDir>(paths: <TestDir, List<String>>{
  TestDir.database: <String>['database'],
  TestDir.backupApp: <String>['backup', 'app'],
  TestDir.backupConfig: <String>['backup', 'config'],
  TestDir.log: <String>['log'],
});

void main() {
  group("Directory Initialization and Checks", () {
    late Directory platformBase;

    setUp(() async {
      platformBase = await Directory.systemTemp.createTemp("basedir_test");
    });

    tearDown(() async {
      if (await platformBase.exists()) {
        await platformBase.delete(recursive: true);
      }
    });

    group("isDirWritable Tests", () {
      test("returns true for a writable directory", () async {
        final bool isWritable = await isDirWritable(platformBase);
        expect(isWritable, isTrue);
      });

      test("returns false for a non-writable directory", () async {
        // Make the directory read-only (platform-dependent)
        if (!Platform.isWindows) {
          final ProcessResult result =
              await Process.run("chmod", <String>["-w", platformBase.path]);
          expect(result.exitCode, equals(0));
        } else {
          // On Windows, simulate by removing write permissions using ACL
          final ProcessResult result = await Process.run("icacls", <String>[
            platformBase.path,
            "/deny",
            '${Platform.environment['USERNAME']}:W'
          ]);
          expect(result.exitCode, equals(0));
        }

        final bool isWritable = await isDirWritable(platformBase);
        expect(isWritable, isFalse);
      });
    });

    group("BaseDirectories.create (explicit include)", () {
      test("creates the required directories", () async {
        final BaseDirectories<TestDir> base = BaseDirectories<TestDir>(
          appName: 'test_app',
          platformBaseDir: platformBase,
          schema: testSchema,
          debugMode: true,
        );
        await base.create(include: <TestDir>{
          TestDir.database,
          TestDir.backupApp,
          TestDir.backupConfig,
          TestDir.log,
        });

        // Check that the directories were created
        final Directory appRoot =
            Directory(p.join(platformBase.path, "test_app", "debug"));
        final Directory databaseDir =
            Directory(p.join(appRoot.path, "database"));
        final Directory backupAppDbDir =
            Directory(p.join(appRoot.path, "backup", "app"));
        final Directory backupConfigDbDir =
            Directory(p.join(appRoot.path, "backup", "config"));
        final Directory logDir = Directory(p.join(appRoot.path, "log"));

        expect(await appRoot.exists(), isTrue);
        expect(await databaseDir.exists(), isTrue);
        expect(await backupAppDbDir.exists(), isTrue);
        expect(await backupConfigDbDir.exists(), isTrue);
        expect(await logDir.exists(), isTrue);
      });

      test("does nothing when include is empty", () async {
        final BaseDirectories<TestDir> base = BaseDirectories<TestDir>(
          appName: 'test_app',
          platformBaseDir: platformBase,
          schema: testSchema,
          debugMode: true,
        );
        await base.create();
        final Directory appRoot =
            Directory(p.join(platformBase.path, "test_app", "debug"));
        expect(await appRoot.exists(), isFalse);
      });
    });
  });
}
