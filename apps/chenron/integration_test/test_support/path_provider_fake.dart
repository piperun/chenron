import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class TestPathProvider extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  final String base;
  TestPathProvider({String? basePath}) : base = basePath ?? Directory.systemTemp.path;
  @override
  Future<String?> getApplicationDocumentsPath() async => base;
  @override
  Future<String?> getApplicationSupportPath() async => base;
  @override
  Future<String?> getTemporaryPath() async => base;
}

void installFakePathProvider({String? basePath}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = TestPathProvider(basePath: basePath);
}