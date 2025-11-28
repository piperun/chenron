import 'package:database/main.dart';
import 'package:database/src/features/user_config/create.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chenron_mockups/chenron_mockups.dart';

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late ConfigDatabase database;

  setUp(() {
    database = ConfigDatabase(
      databaseName: "test_config_db",
      setupOnInit: true,
      debugMode: true,
    );
  });

  tearDown(() async {
    await database.delete(database.userConfigs).go();
    await database.delete(database.backupSettings).go();
    await database.close();
  });

  group('UserConfigExtensions.createUserConfig()', () {
    test('creates user config with default values', () async {
      final userConfig = UserConfig(
        id: '',
        darkMode: false,
        copyOnImport: false,
        defaultArchiveIs: false,
        defaultArchiveOrg: false,
        selectedThemeType: 0,
        timeDisplayFormat: 0,
        itemClickAction: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await database.createUserConfig(userConfig);

      expect(result.userConfigId, isNotEmpty);
      expect(result.userConfigId.length, equals(30));

      // Verify in database
      final config = await (database.select(database.userConfigs)
            ..where((tbl) => tbl.id.equals(result.userConfigId)))
          .getSingleOrNull();

      expect(config, isNotNull);
      expect(config!.darkMode, isFalse);
    });

    test('creates user config with custom values', () async {
      final userConfig = UserConfig(
        id: '',
        darkMode: true,
        archiveOrgS3AccessKey: 'test-access-key',
        archiveOrgS3SecretKey: 'test-secret-key',
        copyOnImport: true,
        defaultArchiveIs: true,
        defaultArchiveOrg: true,
        selectedThemeType: 1,
        timeDisplayFormat: 24,
        itemClickAction: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await database.createUserConfig(userConfig);

      // Verify values persisted correctly
      final config = await (database.select(database.userConfigs)
            ..where((tbl) => tbl.id.equals(result.userConfigId)))
          .getSingleOrNull();

      expect(config, isNotNull);
      expect(config!.darkMode, isTrue);
      expect(config.archiveOrgS3AccessKey, equals('test-access-key'));
      expect(config.archiveOrgS3SecretKey, equals('test-secret-key'));
      expect(config.copyOnImport, isTrue);
    });

    test('creates user config with archive credentials', () async {
      final userConfig = UserConfig(
        id: '',
        darkMode: false,
        archiveOrgS3AccessKey: 'my-access-123',
        archiveOrgS3SecretKey: 'my-secret-456',
        copyOnImport: false,
        defaultArchiveIs: false,
        defaultArchiveOrg: false,
        selectedThemeType: 0,
        timeDisplayFormat: 0,
        itemClickAction: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await database.createUserConfig(userConfig);

      final config = await (database.select(database.userConfigs)
            ..where((tbl) => tbl.id.equals(result.userConfigId)))
          .getSingleOrNull();

      expect(config!.archiveOrgS3AccessKey, equals('my-access-123'));
      expect(config.archiveOrgS3SecretKey, equals('my-secret-456'));
    });
  });

  group('BackupSettingsExtensions.createBackupSettings()', () {
    test('creates backup settings linked to user config', () async {
      // First create a user config
      final userConfig = UserConfig(
        id: '',
        darkMode: false,
        copyOnImport: false,
        defaultArchiveIs: false,
        defaultArchiveOrg: false,
        selectedThemeType: 0,
        timeDisplayFormat: 0,
        itemClickAction: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final configResult = await database.createUserConfig(userConfig);

      // Create backup settings
      final backupSetting = BackupSetting(
        id: '',
        userConfigId: configResult.userConfigId,
        backupFilename: 'backup.db',
        backupPath: '/backups',
        backupInterval: '7',
      );

      final result = await database.createBackupSettings(
        backupSetting: backupSetting,
        userConfigId: configResult.userConfigId,
      );

      expect(result.backupSettingsId, isNotEmpty);
      expect(result.userConfigId, equals(configResult.userConfigId));

      // Verify in database
      final backup = await (database.select(database.backupSettings)
            ..where((tbl) => tbl.id.equals(result.backupSettingsId)))
          .getSingleOrNull();

      expect(backup, isNotNull);
      expect(backup!.backupFilename, equals('backup.db'));
      expect(backup.backupPath, equals('/backups'));
      expect(backup.backupInterval, equals('7'));
    });

    test('creates backup settings with custom interval', () async {
      final userConfig = UserConfig(
        id: '',
        darkMode: false,
        copyOnImport: false,
        defaultArchiveIs: false,
        defaultArchiveOrg: false,
        selectedThemeType: 0,
        timeDisplayFormat: 0,
        itemClickAction: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final configResult = await database.createUserConfig(userConfig);

      final backupSetting = BackupSetting(
        id: '',
        userConfigId: configResult.userConfigId,
        backupFilename: 'daily_backup.db',
        backupPath: '/daily',
        backupInterval: '1',
      );

      final result = await database.createBackupSettings(
        backupSetting: backupSetting,
        userConfigId: configResult.userConfigId,
      );

      final backup = await (database.select(database.backupSettings)
            ..where((tbl) => tbl.id.equals(result.backupSettingsId)))
          .getSingleOrNull();

      expect(backup!.backupInterval, equals('1'));
      expect(backup.backupFilename, equals('daily_backup.db'));
    });

    test('creates backup settings with long paths', () async {
      final userConfig = UserConfig(
        id: '',
        darkMode: false,
        copyOnImport: false,
        defaultArchiveIs: false,
        defaultArchiveOrg: false,
        selectedThemeType: 0,
        timeDisplayFormat: 0,
        itemClickAction: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final configResult = await database.createUserConfig(userConfig);

      final longPath = '/very/long/path/to/backup/directory/structure/here';
      final backupSetting = BackupSetting(
        id: '',
        userConfigId: configResult.userConfigId,
        backupFilename: 'backup.db',
        backupPath: longPath,
        backupInterval: '30',
      );

      final result = await database.createBackupSettings(
        backupSetting: backupSetting,
        userConfigId: configResult.userConfigId,
      );

      final backup = await (database.select(database.backupSettings)
            ..where((tbl) => tbl.id.equals(result.backupSettingsId)))
          .getSingleOrNull();

      expect(backup!.backupPath, equals(longPath));
    });
  });
}
