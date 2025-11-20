import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:chenron/providers/basedir.dart";
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";
import "package:chenron/base_dirs/schema.dart";

class _FakePathProvider extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  final String docs;
  final String support;
  final String temp;
  _FakePathProvider({required this.docs, required this.support, required this.temp});
  @override
  Future<String?> getApplicationDocumentsPath() async => docs;
  @override
  Future<String?> getApplicationSupportPath() async => support;
  @override
  Future<String?> getTemporaryPath() async => temp;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("basedir provider (with fake path_provider)", () {
    setUp(() async {
      final tmp = Directory.systemTemp.createTempSync("chenron_test").path;
      PathProviderPlatform.instance = _FakePathProvider(
        docs: tmp,
        support: tmp,
        temp: tmp,
      );
    });

    test("initializeBaseDirs creates expected layout", () async {
      final base = await initializeBaseDirs();
      expect(base, isNotNull);
      String norm(String s) => s.replaceAll("\\", "/");

      expect(norm(base!.databaseDir.path).endsWith("chenron/debug/database") || norm(base.databaseDir.path).endsWith("chenron/database"), isTrue);
      expect(norm(base.backupAppDir.path).endsWith("chenron/debug/backup/app") || norm(base.backupAppDir.path).endsWith("chenron/backup/app"), isTrue);
      expect(norm(base.backupConfigDir.path).endsWith("chenron/debug/backup/config") || norm(base.backupConfigDir.path).endsWith("chenron/backup/config"), isTrue);
    });
  });
}
