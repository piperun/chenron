import "package:integration_test/integration_test.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/providers/basedir.dart";
import "package:chenron/base_dirs/schema.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    installFakePathProvider();
  });

  group("basedir provider", () {
    test("initializeBaseDirs creates expected layout", () async {
      final base = await initializeBaseDirs();
      expect(base, isNotNull);

      String norm(String s) => s.replaceAll("\\", "/");

      final root = norm(base!.appRoot.path);
      expect(root.endsWith("chenron/debug") || root.endsWith("chenron"), isTrue,
          reason: "root was: ${base.appRoot.path}");

      final db = norm(base.databaseDir.path);
      expect(
          db.endsWith("chenron/debug/database") ||
              db.endsWith("chenron/database"),
          isTrue,
          reason: "db was: ${base.databaseDir.path}");

      final bapp = norm(base.backupAppDir.path);
      expect(
          bapp.endsWith("chenron/debug/backup/app") ||
              bapp.endsWith("chenron/backup/app"),
          isTrue,
          reason: "backup app was: ${base.backupAppDir.path}");

      final bcfg = norm(base.backupConfigDir.path);
      expect(
          bcfg.endsWith("chenron/debug/backup/config") ||
              bcfg.endsWith("chenron/backup/config"),
          isTrue,
          reason: "backup config was: ${base.backupConfigDir.path}");
    });
  });
}

