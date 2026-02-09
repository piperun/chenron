import "dart:io";

import "package:database/src/core/handlers/database_backup_scheduler.dart";
import "package:database/src/core/handlers/database_file_handler.dart";
import "package:database/src/core/handlers/config_file_handler.dart";
import "package:database/main.dart";
import "package:database/src/features/user_config/create.dart";
import "package:database/src/features/backup_settings/read.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late ConfigDatabase configDb;
  late ConfigDatabaseFileHandler configHandler;
  late String userConfigId;
  late String backupSettingsId;

  setUp(() async {
    configDb = ConfigDatabase(
      databaseName: "test_config_db",
      setupOnInit: true,
      debugMode: true,
    );

    final backupSettingsTable = configDb.backupSettings;
    await configDb.delete(backupSettingsTable).go();
    final userConfigsTable = configDb.userConfigs;
    await configDb.delete(userConfigsTable).go();

    // Create user config and backup settings
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
    final configResult = await configDb.createUserConfig(userConfig);
    userConfigId = configResult.userConfigId;

    final backupResult = await configDb.createBackupSettings(
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

    configHandler = ConfigDatabaseFileHandler();
    // Expose the database through the handler by using internal access
    configHandler = _TestConfigHandler(configDb);
  });

  tearDown(() async {
    final backupSettingsTable = configDb.backupSettings;
    await configDb.delete(backupSettingsTable).go();
    final userConfigsTable = configDb.userConfigs;
    await configDb.delete(userConfigsTable).go();
    await configDb.close();
  });

  group("DatabaseBackupScheduler lifecycle", () {
    test("isRunning returns false before start", () {
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: _FakeAppDatabaseHandler(),
        configHandler: configHandler,
      );

      expect(scheduler.isRunning, isFalse);
      expect(scheduler.currentInterval, isNull);
    });

    test("isRunning returns true after start with valid cron", () async {
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: _FakeAppDatabaseHandler(),
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      expect(scheduler.isRunning, isTrue);
      expect(scheduler.currentInterval, equals("0 0 */8 * * *"));

      await scheduler.stop();
    });

    test("start with null cron expression disables scheduling", () async {
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: _FakeAppDatabaseHandler(),
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: null,
        backupSettingsId: backupSettingsId,
      );

      expect(scheduler.isRunning, isFalse);
      expect(scheduler.currentInterval, isNull);
    });

    test("start with empty cron expression disables scheduling", () async {
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: _FakeAppDatabaseHandler(),
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "",
        backupSettingsId: backupSettingsId,
      );

      expect(scheduler.isRunning, isFalse);
      expect(scheduler.currentInterval, isNull);
    });

    test("stop resets state", () async {
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: _FakeAppDatabaseHandler(),
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "0 0 */4 * * *",
        backupSettingsId: backupSettingsId,
      );
      expect(scheduler.isRunning, isTrue);

      await scheduler.stop();

      expect(scheduler.isRunning, isFalse);
      expect(scheduler.currentInterval, isNull);
    });

    test("restart with new interval replaces previous schedule", () async {
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: _FakeAppDatabaseHandler(),
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "0 0 */4 * * *",
        backupSettingsId: backupSettingsId,
      );
      expect(scheduler.currentInterval, equals("0 0 */4 * * *"));

      await scheduler.start(
        cronExpression: "0 0 0 * * *",
        backupSettingsId: backupSettingsId,
      );
      expect(scheduler.currentInterval, equals("0 0 0 * * *"));
      expect(scheduler.isRunning, isTrue);

      await scheduler.stop();
    });
  });

  group("runBackup()", () {
    test("calls backupDatabase on handler", () async {
      final fakeHandler = _FakeAppDatabaseHandler();
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: fakeHandler,
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      await scheduler.runBackup();

      expect(fakeHandler.backupCalled, isTrue);

      await scheduler.stop();
    });

    test("updates lastBackupTimestamp after successful backup", () async {
      final fakeHandler = _FakeAppDatabaseHandler();
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: fakeHandler,
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      final beforeBackup = DateTime.now();
      await scheduler.runBackup();
      final afterBackup = DateTime.now();

      final settings =
          await configDb.getBackupSettings(userConfigId: userConfigId);
      expect(settings, isNotNull);
      expect(settings!.lastBackupTimestamp, isNotNull);
      expect(
        settings.lastBackupTimestamp!.isAfter(
          beforeBackup.subtract(const Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(
        settings.lastBackupTimestamp!.isBefore(
          afterBackup.add(const Duration(seconds: 1)),
        ),
        isTrue,
      );

      await scheduler.stop();
    });

    test("does not throw when backup fails", () async {
      final fakeHandler = _FakeAppDatabaseHandler(shouldFail: true);
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: fakeHandler,
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      // Should not throw
      await scheduler.runBackup();
      expect(fakeHandler.backupCalled, isTrue);

      await scheduler.stop();
    });
  });
}

/// Minimal fake that tracks backup calls without needing real file system.
class _FakeAppDatabaseHandler extends AppDatabaseHandler {
  bool backupCalled = false;
  final bool shouldFail;

  _FakeAppDatabaseHandler({this.shouldFail = false});

  @override
  Future<File?> backupDatabase() async {
    backupCalled = true;
    if (shouldFail) {
      throw Exception("Simulated backup failure");
    }
    return null;
  }
}

/// Exposes a real ConfigDatabase through the handler interface for testing.
class _TestConfigHandler extends ConfigDatabaseFileHandler {
  final ConfigDatabase _db;

  _TestConfigHandler(this._db);

  @override
  ConfigDatabase get configDatabase => _db;
}
