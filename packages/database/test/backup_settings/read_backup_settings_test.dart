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
    final result = await database.createUserConfig(userConfig);
    userConfigId = result.userConfigId;
  });

  tearDown(() async {
    final backupSettingsTable = database.backupSettings;
    await database.delete(backupSettingsTable).go();
    final userConfigsTable = database.userConfigs;
    await database.delete(userConfigsTable).go();
    await database.close();
  });

  group("getBackupSettings()", () {
    test("returns null when no backup settings exist", () async {
      final result =
          await database.getBackupSettings(userConfigId: userConfigId);
      expect(result, isNull);
    });

    test("returns backup settings for existing user config", () async {
      final backupSetting = BackupSetting(
        id: "",
        userConfigId: userConfigId,
        backupFilename: null,
        backupPath: null,
        backupInterval: null,
        lastBackupTimestamp: null,
      );
      await database.createBackupSettings(
        backupSetting: backupSetting,
        userConfigId: userConfigId,
      );

      final result =
          await database.getBackupSettings(userConfigId: userConfigId);

      expect(result, isNotNull);
      expect(result!.userConfigId, equals(userConfigId));
    });

    test("returns backup settings with interval", () async {
      final backupSetting = BackupSetting(
        id: "",
        userConfigId: userConfigId,
        backupFilename: null,
        backupPath: null,
        backupInterval: "0 0 */8 * * *",
        lastBackupTimestamp: null,
      );
      await database.createBackupSettings(
        backupSetting: backupSetting,
        userConfigId: userConfigId,
      );

      final result =
          await database.getBackupSettings(userConfigId: userConfigId);

      expect(result, isNotNull);
      expect(result!.backupInterval, equals("0 0 */8 * * *"));
    });

    test("returns backup settings with path and timestamp", () async {
      final backupSetting = BackupSetting(
        id: "",
        userConfigId: userConfigId,
        backupFilename: "backup.sqlite",
        backupPath: "/custom/backup/path",
        backupInterval: "0 0 0 * * *",
        lastBackupTimestamp: null,
      );
      final created = await database.createBackupSettings(
        backupSetting: backupSetting,
        userConfigId: userConfigId,
      );

      // createBackupSettings doesn't insert lastBackupTimestamp,
      // so set it via update
      final timestamp = DateTime(2025, 6, 15, 10, 30);
      await database.updateBackupSettings(
        id: created.backupSettingsId,
        lastBackupTimestamp: timestamp,
      );

      final result =
          await database.getBackupSettings(userConfigId: userConfigId);

      expect(result, isNotNull);
      expect(result!.backupPath, equals("/custom/backup/path"));
      expect(result.backupFilename, equals("backup.sqlite"));
      expect(result.backupInterval, equals("0 0 0 * * *"));
      expect(result.lastBackupTimestamp, equals(timestamp));
    });

    test("returns null for non-existent user config id", () async {
      final result =
          await database.getBackupSettings(userConfigId: "non_existent_id");
      expect(result, isNull);
    });

    test("returns correct settings when multiple user configs exist",
        () async {
      // Create a second user config
      final userConfig2 = UserConfig(
        id: "",
        darkMode: true,
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
      final result2 = await database.createUserConfig(userConfig2);
      final userConfigId2 = result2.userConfigId;

      // Create backup settings for first user config
      await database.createBackupSettings(
        backupSetting: BackupSetting(
          id: "",
          userConfigId: userConfigId,
          backupFilename: null,
          backupPath: null,
          backupInterval: "0 0 */4 * * *",
          lastBackupTimestamp: null,
        ),
        userConfigId: userConfigId,
      );

      // Create backup settings for second user config
      await database.createBackupSettings(
        backupSetting: BackupSetting(
          id: "",
          userConfigId: userConfigId2,
          backupFilename: null,
          backupPath: null,
          backupInterval: "0 0 */12 * * *",
          lastBackupTimestamp: null,
        ),
        userConfigId: userConfigId2,
      );

      final settings1 =
          await database.getBackupSettings(userConfigId: userConfigId);
      final settings2 =
          await database.getBackupSettings(userConfigId: userConfigId2);

      expect(settings1, isNotNull);
      expect(settings1!.backupInterval, equals("0 0 */4 * * *"));

      expect(settings2, isNotNull);
      expect(settings2!.backupInterval, equals("0 0 */12 * * *"));
    });

  });
}
