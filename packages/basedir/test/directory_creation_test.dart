import 'dart:io';

import 'package:basedir/directory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

// Local test enum keys for schema
enum TestDir { root, nested, deep }

const DirSchema<TestDir> testSchema =
    DirSchema<TestDir>(paths: <TestDir, List<String>>{
  TestDir.root: <String>['root'],
  TestDir.nested: <String>['level1', 'level2'],
  TestDir.deep: <String>['a', 'b', 'c', 'd'],
});

void main() {
  group("Directory Creation Tests", () {
    late Directory platformBase;

    setUp(() async {
      platformBase =
          await Directory.systemTemp.createTemp("basedir_creation_test");
    });

    tearDown(() async {
      if (platformBase.existsSync()) {
        await platformBase.delete(recursive: true);
      }
    });

    test("createAll creates all directories in schema", () async {
      final BaseDirectories<TestDir> base = BaseDirectories<TestDir>(
        appName: 'test_app',
        platformBaseDir: platformBase,
        schema: testSchema,
        debugMode: true,
      );

      await base.createAll();

      final Directory appRoot =
          Directory(p.join(platformBase.path, "test_app", "debug"));

      expect(appRoot.existsSync(), isTrue);
      expect(Directory(p.join(appRoot.path, "root")).existsSync(), isTrue);
      expect(Directory(p.join(appRoot.path, "level1", "level2")).existsSync(),
          isTrue);
      expect(Directory(p.join(appRoot.path, "a", "b", "c", "d")).existsSync(),
          isTrue);
    });

    test("create with specific keys only creates those directories", () async {
      final BaseDirectories<TestDir> base = BaseDirectories<TestDir>(
        appName: 'test_app',
        platformBaseDir: platformBase,
        schema: testSchema,
        debugMode: true,
      );

      await base.create(include: {TestDir.root});

      final Directory appRoot =
          Directory(p.join(platformBase.path, "test_app", "debug"));

      expect(appRoot.existsSync(), isTrue);
      expect(Directory(p.join(appRoot.path, "root")).existsSync(), isTrue);
      expect(Directory(p.join(appRoot.path, "level1", "level2")).existsSync(),
          isFalse);
      expect(Directory(p.join(appRoot.path, "a", "b", "c", "d")).existsSync(),
          isFalse);
    });

    test("create with empty include does nothing", () async {
      final BaseDirectories<TestDir> base = BaseDirectories<TestDir>(
        appName: 'test_app',
        platformBaseDir: platformBase,
        schema: testSchema,
        debugMode: true,
      );

      await base.create(include: {});

      // App root might not exist if no subdirs are created,
      // but BaseDirectories constructor doesn't create anything.
      // Let's verify nothing exists.
      final Directory appRoot =
          Directory(p.join(platformBase.path, "test_app", "debug"));
      expect(appRoot.existsSync(), isFalse);
    });

    test("accessing directories via operator []", () {
      final BaseDirectories<TestDir> base = BaseDirectories<TestDir>(
        appName: 'test_app',
        platformBaseDir: platformBase,
        schema: testSchema,
        debugMode: true,
      );

      final rootDir = base[TestDir.root];
      expect(rootDir.path, endsWith(p.join('test_app', 'debug', 'root')));
    });
  });
}
