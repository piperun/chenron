import "package:database/main.dart";
import "package:database/src/features/user_config/create.dart";
import "package:database/src/features/backup_settings/read.dart";
import "package:database/src/features/backup_settings/update.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late ConfigDatabase database;
  late String userConfigId;
  late String backupSettingsId;

  setUp(() async {
    database = ConfigDatabase(
      databaseName: "test_config_db",
      setupOnInit: true,
      debugMode: true,
    );

    final backupSettingsTable = database.backupSettings;
    await database.delete(backupSettingsTable).go();
    final userConfigsTable = database.userConfigs;
    await database.delete(userConfigsTable).go();

    final userConfig = UserConfig(
      id: "",
      darkMode: false,
      archiveOrgS3AccessKey: null,
      copyOnImport: false,
      defaultArchiveIs: false,
      defaultArchiveOrg: false,
      selectedThemeType: 0,
      timeDisplayFormat: 0,
      itemClickAction: 0,
        showDescription: true,
        showImages: true,
        showTags: true,
        showCopyLink: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final configResult = await database.createUserConfig(userConfig);
    userConfigId = configResult.userConfigId;

    final backupResult = await database.createBackupSettings(
      backupSetting: BackupSetting(
        id: "",
        userConfigId: userConfigId,
        backupFilename: null,
        backupPath: null,
        backupInterval: null,
        lastBackupTimestamp: null,
      ),
      userConfigId: userConfigId,
    );
    backupSettingsId = backupResult.backupSettingsId;
  });

  tearDown(() async {
    final backupSettingsTable = database.backupSettings;
    await database.delete(backupSettingsTable).go();
    final userConfigsTable = database.userConfigs;
    await database.delete(userConfigsTable).go();
    await database.close();
  });

  group("updateBackupSettings()", () {
    test("updates backup interval", () async {
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupInterval: "0 0 */8 * * *",
      );

      final result =
          await database.getBackupSettings(userConfigId: userConfigId);
      expect(result, isNotNull);
      expect(result!.backupInterval, equals("0 0 */8 * * *"));
    });

    test("clears backup interval with clearInterval flag", () async {
      // First set an interval
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupInterval: "0 0 */4 * * *",
      );

      // Verify it was set
      var result =
          await database.getBackupSettings(userConfigId: userConfigId);
      expect(result!.backupInterval, equals("0 0 */4 * * *"));

      // Clear it
      await database.updateBackupSettings(
        id: backupSettingsId,
        clearInterval: true,
      );

      result = await database.getBackupSettings(userConfigId: userConfigId);
      expect(result!.backupInterval, isNull);
    });

    test("updates backup path", () async {
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupPath: "/custom/backup/dir",
      );

      final result =
          await database.getBackupSettings(userConfigId: userConfigId);
      expect(result, isNotNull);
      expect(result!.backupPath, equals("/custom/backup/dir"));
    });

    test("clears backup path with empty string", () async {
      // First set a path
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupPath: "/some/path",
      );

      var result =
          await database.getBackupSettings(userConfigId: userConfigId);
      expect(result!.backupPath, equals("/some/path"));

      // Clear it with empty string
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupPath: "",
      );

      result = await database.getBackupSettings(userConfigId: userConfigId);
      expect(result!.backupPath, isNull);
    });

    test("updates lastBackupTimestamp", () async {
      final timestamp = DateTime(2025, 7, 20, 14, 30);
      await database.updateBackupSettings(
        id: backupSettingsId,
        lastBackupTimestamp: timestamp,
      );

      final result =
          await database.getBackupSettings(userConfigId: userConfigId);
      expect(result, isNotNull);
      expect(result!.lastBackupTimestamp, equals(timestamp));
    });

    test("updates multiple fields at once", () async {
      final timestamp = DateTime(2025, 8, 1, 9, 0);
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupInterval: "0 0 */12 * * *",
        backupPath: "/my/backups",
        lastBackupTimestamp: timestamp,
      );

      final result =
          await database.getBackupSettings(userConfigId: userConfigId);
      expect(result, isNotNull);
      expect(result!.backupInterval, equals("0 0 */12 * * *"));
      expect(result.backupPath, equals("/my/backups"));
      expect(result.lastBackupTimestamp, equals(timestamp));
    });

    test("preserves unchanged fields", () async {
      // Set initial values
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupInterval: "0 0 */4 * * *",
        backupPath: "/initial/path",
      );

      // Update only the interval
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupInterval: "0 0 0 * * *",
      );

      final result =
          await database.getBackupSettings(userConfigId: userConfigId);
      expect(result, isNotNull);
      expect(result!.backupInterval, equals("0 0 0 * * *"));
      // Path should remain unchanged
      expect(result.backupPath, equals("/initial/path"));
    });

    test("clearInterval takes priority over backupInterval", () async {
      // Set an initial interval
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupInterval: "0 0 */8 * * *",
      );

      // Pass both clearInterval and a new backupInterval
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupInterval: "0 0 */4 * * *",
        clearInterval: true,
      );

      final result =
          await database.getBackupSettings(userConfigId: userConfigId);
      expect(result, isNotNull);
      // clearInterval should win, setting it to null
      expect(result!.backupInterval, isNull);
    });

    test("updates timestamp without affecting other fields", () async {
      // Set initial state
      await database.updateBackupSettings(
        id: backupSettingsId,
        backupInterval: "0 0 */8 * * *",
        backupPath: "/my/path",
      );

      // Update only timestamp
      final timestamp = DateTime(2025, 12, 25, 0, 0);
      await database.updateBackupSettings(
        id: backupSettingsId,
        lastBackupTimestamp: timestamp,
      );

      final result =
          await database.getBackupSettings(userConfigId: userConfigId);
      expect(result, isNotNull);
      expect(result!.backupInterval, equals("0 0 */8 * * *"));
      expect(result.backupPath, equals("/my/path"));
      expect(result.lastBackupTimestamp, equals(timestamp));
    });
  });
}
