import 'dart:io';

import 'package:basedir/directory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_provider/platform_provider.dart';

void main() {
  group("Directory Permissions Tests", () {
    late Directory platformBase;

    setUp(() async {
      platformBase = await Directory.systemTemp.createTemp("basedir_perm_test");
    });

    tearDown(() async {
      if (platformBase.existsSync()) {
        // Try to restore permissions before deleting if needed,
        // but usually recursive delete handles it or OS cleans up temp.
        // On Windows, we might need to reset if we denied delete permission.
        if (OperatingSystem.current.name == 'Windows') {
          await Process.run(
              "icacls", <String>[platformBase.path, "/reset", "/T"]);
        }
        try {
          await platformBase.delete(recursive: true);
        } catch (e) {
          debugPrint("Failed to cleanup temp dir: $e");
        }
      }
    });

    test("isDirWritable returns true for normal temp directory", () async {
      final bool isWritable = await isDirWritable(platformBase);
      expect(isWritable, isTrue);
    });

    test("isDirWritable returns false for read-only directory", () async {
      // Make the directory read-only (platform-dependent)
      if (OperatingSystem.current.name != 'Windows') {
        final ProcessResult result =
            await Process.run("chmod", <String>["-w", platformBase.path]);
        expect(result.exitCode, equals(0), reason: "chmod failed");
      } else {
        // On Windows, deny write permission
        final ProcessResult result = await Process.run("icacls", <String>[
          platformBase.path,
          "/deny",
          '${Platform.environment['USERNAME']}:W'
        ]);
        expect(result.exitCode, equals(0), reason: "icacls failed");
      }

      final bool isWritable = await isDirWritable(platformBase);
      expect(isWritable, isFalse);
    });
  });
}
