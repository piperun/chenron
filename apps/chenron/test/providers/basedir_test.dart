import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:chenron/providers/basedir.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

  group('basedir provider (with fake path_provider)', () {
    setUp(() async {
      final tmp = Directory.systemTemp.createTempSync('chenron_test').path;
      PathProviderPlatform.instance = _FakePathProvider(
        docs: tmp,
        support: tmp,
        temp: tmp,
      );
    });

    test('initializeChenronDirs uses app.sqlite and expected layout', () async {
      final dirs = await initializeChenronDirs();
      expect(dirs, isNotNull);
      final norm = (String s) => s.replaceAll('\\', '/');

      expect(p.basename(dirs!.databaseName.path), 'app.sqlite');
      expect(norm(dirs.databaseDir.path).endsWith('chenron/debug/database') || norm(dirs.databaseDir.path).endsWith('chenron/database'), isTrue);
      expect(norm(dirs.backupAppDbDir.path).endsWith('chenron/debug/backup/app') || norm(dirs.backupAppDbDir.path).endsWith('chenron/backup/app'), isTrue);
      expect(norm(dirs.backupConfigDbDir.path).endsWith('chenron/debug/backup/config') || norm(dirs.backupConfigDbDir.path).endsWith('chenron/backup/config'), isTrue);
    });
  });
}
