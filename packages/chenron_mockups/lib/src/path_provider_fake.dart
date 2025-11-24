// ignore_for_file: depend_on_referenced_packages, invalid_use_of_visible_for_testing_member
import "dart:io";

import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";
import "package:flutter_test/flutter_test.dart";

class TestPathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory base;
  TestPathProvider({String? basePath})
      : base = Directory(basePath ??
            Directory.systemTemp.createTempSync("chenron_test_base").path) {
    if (!base.existsSync()) {
      base.createSync(recursive: true);
    }
  }
  @override
  Future<String?> getApplicationDocumentsPath() async => base.path;
  @override
  Future<String?> getApplicationSupportPath() async => base.path;
  @override
  Future<String?> getTemporaryPath() async => base.path;
}

void installFakePathProvider({String? basePath}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = TestPathProvider(basePath: basePath);
}
