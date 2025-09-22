import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chenron/providers/basedir.dart';

import 'package:chenron/test_support/path_provider_fake.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    installFakePathProvider();
  });

  group('basedir provider', () {
    test('initializeChenronDirs uses app.sqlite and correct layout', () async {
      final dirs = await initializeChenronDirs();
      expect(dirs, isNotNull);

      // app DB name
      expect(dirs!.databaseName.path.split(RegExp(r'[\\\/]')).last, 'app.sqlite');

      String norm(String s) => s.replaceAll('\\', '/');

      final root = norm(dirs.chenronDir.path);
      expect(root.endsWith('chenron/debug') || root.endsWith('chenron'), isTrue,
          reason: 'root was: ${dirs.chenronDir.path}');

      final db = norm(dirs.databaseDir.path);
      expect(db.endsWith('chenron/debug/database') || db.endsWith('chenron/database'), isTrue,
          reason: 'db was: ${dirs.databaseDir.path}');

      final bapp = norm(dirs.backupAppDbDir.path);
      expect(bapp.endsWith('chenron/debug/backup/app') || bapp.endsWith('chenron/backup/app'), isTrue,
          reason: 'backup app was: ${dirs.backupAppDbDir.path}');

      final bcfg = norm(dirs.backupConfigDbDir.path);
      expect(bcfg.endsWith('chenron/debug/backup/config') || bcfg.endsWith('chenron/backup/config'), isTrue,
          reason: 'backup config was: ${dirs.backupConfigDbDir.path}');
    });
  });
}
