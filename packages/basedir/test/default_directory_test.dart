import 'dart:io';

import 'package:basedir/directory.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Default Application Directory Tests", () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');

    // Temporary directory to use as mock result
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp("basedir_default_test");

      // Mock the path_provider channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        if (methodCall.method == 'getApplicationSupportDirectory') {
          return tempDir.path;
        }
        return null;
      });
    });

    tearDown(() async {
      // Remove mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);

      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test("getDefaultApplicationDirectory returns valid directory in debug mode",
        () async {
      final Directory dir =
          await getDefaultApplicationDirectory(debugMode: true);
      expect(dir.path, equals(tempDir.path));
    });

    test(
        "getDefaultApplicationDirectory returns valid directory in release mode",
        () async {
      final Directory dir =
          await getDefaultApplicationDirectory(debugMode: false);
      expect(dir.path, equals(tempDir.path));
    });
  });
}
