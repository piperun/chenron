import "dart:io";

import "package:database/database.dart";
import "package:database/src/features/backup_settings/read.dart";
import "package:database/src/features/user_config/create.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late ConfigDatabase configDb;
  late ConfigDatabaseLifecycle configLifecycle;
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

    final userConfig = UserConfig(
      id: "",
      darkMode: false,
      archiveOrgS3AccessKey: null,
      copyOnImport: false,
      defaultArchiveIs: false,
      defaultArchiveOrg: false,
      selectedThemeType: ThemeType.custom,
      timeDisplayFormat: TimeDisplayFormat.relative,
      itemClickAction: ItemClickAction.openItem,
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

    configLifecycle = _TestConfigLifecycle(configDb);
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
        fileService: _FakeAppFileService(),
        configLifecycle: configLifecycle,
      );

      expect(scheduler.isRunning, isFalse);
      expect(scheduler.currentInterval, isNull);
    });

    test("isRunning returns true after start with valid cron", () async {
      final scheduler = DatabaseBackupScheduler(
        fileService: _FakeAppFileService(),
        configLifecycle: configLifecycle,
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
        fileService: _FakeAppFileService(),
        configLifecycle: configLifecycle,
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
        fileService: _FakeAppFileService(),
        configLifecycle: configLifecycle,
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
        fileService: _FakeAppFileService(),
        configLifecycle: configLifecycle,
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
        fileService: _FakeAppFileService(),
        configLifecycle: configLifecycle,
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
    test("calls backupDatabase on file service", () async {
      final fake = _FakeAppFileService();
      final scheduler = DatabaseBackupScheduler(
        fileService: fake,
        configLifecycle: configLifecycle,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      await scheduler.runBackup();

      expect(fake.backupCalled, isTrue);

      await scheduler.stop();
    });

    test("updates lastBackupTimestamp after successful backup", () async {
      final fake = _FakeAppFileService();
      final scheduler = DatabaseBackupScheduler(
        fileService: fake,
        configLifecycle: configLifecycle,
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
      final fake = _FakeAppFileService(shouldFail: true);
      final scheduler = DatabaseBackupScheduler(
        fileService: fake,
        configLifecycle: configLifecycle,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      // Should not throw — scheduler catches and logs.
      await scheduler.runBackup();
      expect(fake.backupCalled, isTrue);

      await scheduler.stop();
    });
  });

  group("backup deduplication", () {
    test("keeps first backup file", () async {
      final content = [1, 2, 3, 4, 5];
      final fake = _FakeAppFileService(fileContent: content);
      final scheduler = DatabaseBackupScheduler(
        fileService: fake,
        configLifecycle: configLifecycle,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      await scheduler.runBackup();

      final settings =
          await configDb.getBackupSettings(userConfigId: userConfigId);
      expect(settings!.lastBackupTimestamp, isNotNull);

      await scheduler.stop();
    });

    test("deletes duplicate when database unchanged", () async {
      final content = [1, 2, 3, 4, 5];
      final fake = _FakeAppFileService(fileContent: content);
      final scheduler = DatabaseBackupScheduler(
        fileService: fake,
        configLifecycle: configLifecycle,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      await scheduler.runBackup();
      final firstTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      await Future<void>.delayed(const Duration(milliseconds: 50));

      await scheduler.runBackup();
      final secondTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      expect(secondTimestamp, equals(firstTimestamp));

      await scheduler.stop();
    });

    test("keeps backup when database has changed", () async {
      final fake = _FakeAppFileService(fileContent: [1, 2, 3]);
      final scheduler = DatabaseBackupScheduler(
        fileService: fake,
        configLifecycle: configLifecycle,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      await scheduler.runBackup();
      final firstTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      await Future<void>.delayed(const Duration(milliseconds: 50));

      fake.fileContent = [4, 5, 6];

      await scheduler.runBackup();
      final secondTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      expect(secondTimestamp, isNot(equals(firstTimestamp)));

      await scheduler.stop();
    });

    test("dedup resets after stop and start", () async {
      final content = [1, 2, 3, 4, 5];
      final fake = _FakeAppFileService(fileContent: content);
      final scheduler = DatabaseBackupScheduler(
        fileService: fake,
        configLifecycle: configLifecycle,
      );

      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      await scheduler.runBackup();
      final firstTimestamp = (await configDb.getBackupSettings(
              userConfigId: userConfigId))!
          .lastBackupTimestamp;

      await scheduler.stop();
      await scheduler.start(
        cronExpression: "0 0 */8 * * *",
        backupSettingsId: backupSettingsId,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

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
class _FakeAppFileService extends AppFileService {
  bool backupCalled = false;
  final bool shouldFail;

  /// Bytes the fake writes to a temp file when [backupDatabase] is called.
  /// Defaults to an empty list so tests that don't care about content still
  /// receive a real File (matching the non-null contract).
  List<int> fileContent;

  _FakeAppFileService({
    this.shouldFail = false,
    List<int>? fileContent,
  })  : fileContent = fileContent ?? const <int>[],
        super(lifecycle: AppDatabaseLifecycle());

  @override
  Future<File> backupDatabase() async {
    backupCalled = true;
    if (shouldFail) {
      throw Exception("Simulated backup failure");
    }
    final tempDir = await Directory.systemTemp.createTemp("backup_test_");
    final file = File("${tempDir.path}/backup.sqlite");
    await file.writeAsBytes(fileContent);
    return file;
  }
}

/// Exposes a real ConfigDatabase through the lifecycle interface for testing.
class _TestConfigLifecycle extends ConfigDatabaseLifecycle {
  final ConfigDatabase _db;

  _TestConfigLifecycle(this._db);

  @override
  ConfigDatabase get configDatabase => _db;

  @override
  ConfigDatabase get database => _db;
}
