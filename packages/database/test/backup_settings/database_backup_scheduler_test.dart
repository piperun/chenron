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

  group("backup deduplication", () {
    test("keeps first backup file", () async {
      final content = [1, 2, 3, 4, 5];
      final fakeHandler = _FakeAppDatabaseHandler(fileContent: content);
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: fakeHandler,
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      await scheduler.runBackup();

      // Timestamp should be updated (backup was kept)
      final settings =
          await configDb.getBackupSettings(userConfigId: userConfigId);
      expect(settings!.lastBackupTimestamp, isNotNull);

      await scheduler.stop();
    });

    test("deletes duplicate when database unchanged", () async {
      final content = [1, 2, 3, 4, 5];
      final fakeHandler = _FakeAppDatabaseHandler(fileContent: content);
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: fakeHandler,
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      // First backup — kept
      await scheduler.runBackup();
      final firstTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      // Small delay so timestamp would differ if updated
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Second backup — same content, should be deleted
      await scheduler.runBackup();
      final secondTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      // Timestamp should NOT have been updated (backup was skipped)
      expect(secondTimestamp, equals(firstTimestamp));

      await scheduler.stop();
    });

    test("keeps backup when database has changed", () async {
      final fakeHandler = _FakeAppDatabaseHandler(fileContent: [1, 2, 3]);
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: fakeHandler,
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      // First backup
      await scheduler.runBackup();
      final firstTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Change the content
      fakeHandler.fileContent = [4, 5, 6];

      // Second backup — different content, should be kept
      await scheduler.runBackup();
      final secondTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      expect(secondTimestamp, isNot(equals(firstTimestamp)));

      await scheduler.stop();
    });

    test("dedup resets after stop and start", () async {
      final content = [1, 2, 3, 4, 5];
      final fakeHandler = _FakeAppDatabaseHandler(fileContent: content);
      final scheduler = DatabaseBackupScheduler(
        databaseHandler: fakeHandler,
        configHandler: configHandler,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      await scheduler.runBackup();
      final firstTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      // Stop and restart — checksum should be cleared
      await scheduler.stop();
      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Same content, but after restart — should be kept (no cached checksum)
      await scheduler.runBackup();
      final secondTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      expect(secondTimestamp, isNot(equals(firstTimestamp)));

      await scheduler.stop();
    });
  });
}

/// Minimal fake that tracks backup calls without needing real file system.
class _FakeAppDatabaseHandler extends AppDatabaseHandler {
  bool backupCalled = false;
  final bool shouldFail;

  /// When non-null, [backupDatabase] writes these bytes to a temp file
  /// and returns it instead of null.
  List<int>? fileContent;

  _FakeAppDatabaseHandler({this.shouldFail = false, this.fileContent});

  @override
  Future<File?> backupDatabase() async {
    backupCalled = true;
    if (shouldFail) {
      throw Exception("Simulated backup failure");
    }
    if (fileContent != null) {
      final tempDir = await Directory.systemTemp.createTemp("backup_test_");
      final file = File("${tempDir.path}/backup.sqlite");
      await file.writeAsBytes(fileContent!);
      return file;
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
