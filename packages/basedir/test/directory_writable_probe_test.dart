import "dart:io";

import "package:basedir/directory.dart";
import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("isDirWritable probe file handling", () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp("basedir_probe_test_");
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        try {
          await tempDir.delete(recursive: true);
        } catch (e) {
          debugPrint("Failed to cleanup temp dir: $e");
        }
      }
    });

    test("returns true for a writable directory", () async {
      expect(await isDirWritable(tempDir), isTrue);
    });

    test("leaves no probe file behind after a successful check", () async {
      await isDirWritable(tempDir);

      final List<FileSystemEntity> residue = tempDir.listSync();
      expect(residue, isEmpty,
          reason:
              "isDirWritable must delete its probe file; found leftovers: "
              "${residue.map((FileSystemEntity e) => e.path).toList()}");
    });

    test("concurrent probes all succeed and leave nothing behind", () async {
      // Many probes launched together land within the same millisecond. A
      // timestamp-only probe filename makes them collide on one shared path, so
      // one probe deletes the file another is still using -> spurious failures
      // and/or leftover files. A unique suffix per call keeps them independent.
      const int concurrency = 64;
      final List<bool> results = await Future.wait<bool>(
        List<Future<bool>>.generate(
            concurrency, (int _) => isDirWritable(tempDir)),
      );

      expect(results.every((bool r) => r), isTrue,
          reason: "every concurrent probe of a writable dir must return true");

      final List<FileSystemEntity> residue = tempDir.listSync();
      expect(residue, isEmpty,
          reason: "concurrent probes must not leave probe files behind: "
              "${residue.map((FileSystemEntity e) => e.path).toList()}");
    });
  });
}
