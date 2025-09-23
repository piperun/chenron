import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:basedir/directory.dart';

void main() {
  group("Directory Initialization and Checks", () {
    late Directory testDir;
    late String databaseName;

    setUp(() async {
      testDir = await Directory.systemTemp.createTemp("chenron_dir_test");
      databaseName = "test_db";
    });

    tearDown(() async {
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    group("isDirWritable Tests", () {
      test("returns true for a writable directory", () async {
        final isWritable = await isDirWritable(testDir);
        expect(isWritable, isTrue);
      });

      test("returns false for a non-writable directory", () async {
        // Make the directory read-only (platform-dependent)
        if (!Platform.isWindows) {
          final result = await Process.run("chmod", ["-w", testDir.path]);
          expect(result.exitCode, equals(0));
        } else {
          // On Windows, simulate by removing write permissions using ACL
          final result = await Process.run(
              "icacls", [testDir.path, "/deny", '${Platform.environment['USERNAME']}:W']);
          expect(result.exitCode, equals(0));
        }

        final isWritable = await isDirWritable(testDir);
        expect(isWritable, isFalse);
      });
    });

    group("createChenronDirectories Tests", () {
      test("creates the required directories", () async {
        final baseDir = ChenronDirectories(
          databaseName: File(databaseName),
          baseDir: testDir,
        );
        await baseDir.createDirectories();

        // Check that the directories were created
        final chenronDir = Directory(p.join(testDir.path, "chenron", "debug"));
        final databaseDir = Directory(p.join(chenronDir.path, "database"));
        final backupAppDbDir = Directory(p.join(chenronDir.path, "backup", "app"));
        final backupConfigDbDir = Directory(p.join(chenronDir.path, "backup", "config"));
        final logDir = Directory(p.join(chenronDir.path, "log"));

        expect(await chenronDir.exists(), isTrue);
        expect(await databaseDir.exists(), isTrue);
        expect(await backupAppDbDir.exists(), isTrue);
        expect(await backupConfigDbDir.exists(), isTrue);
        expect(await logDir.exists(), isTrue);
      });

      test("throws an exception when directory is not writable", () async {
        final baseDir = ChenronDirectories(
          databaseName: File(databaseName),
          baseDir: testDir,
        );

        // Make the directory read-only (platform-dependent)
        if (!Platform.isWindows) {
          final result = await Process.run("chmod", ["-w", testDir.path]);
          expect(result.exitCode, equals(0));
        } else {
          // On Windows, simulate by removing write permissions using ACL
          final result = await Process.run(
              "icacls", [testDir.path, "/deny", '${Platform.environment['USERNAME']}:W']);
          expect(result.exitCode, equals(0));
        }

        // Expect the initialization to throw an exception
        expect(
          () async => await baseDir.createDirectories(),
          throwsException,
        );
      });
    });
  });
}
