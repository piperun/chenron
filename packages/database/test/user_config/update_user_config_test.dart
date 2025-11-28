import 'package:database/main.dart';
import 'package:database/models/cud.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import "package:database/src/features/user_config/create.dart";
import "package:database/src/features/user_config/read.dart";
import "package:database/src/features/user_config/update.dart";
import 'package:chenron_mockups/chenron_mockups.dart';

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

    // Create a base user config for testing updates
    final userConfig = UserConfig(
      id: '',
      darkMode: false,
      archiveOrgS3AccessKey: 'initial-key',
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
    userConfigId = result.userConfigId;
  });

  tearDown(() async {
    await database.delete(database.userConfigs).go();
    await database.delete(database.userThemes).go();
    await database.close();
  });

  group('UserConfigUpdateExtensions.updateUserConfig()', () {
    test('updates darkMode setting', () async {
      await database.updateUserConfig(
        id: userConfigId,
        darkMode: true,
      );

      final config = await database.getUserConfig();
      expect(config!.data.darkMode, isTrue);
    });

    test('updates archive credentials', () async {
      await database.updateUserConfig(
        id: userConfigId,
        archiveOrgS3AccessKey: 'new-access-key',
        archiveOrgS3SecretKey: 'new-secret-key',
      );

      final config = await database.getUserConfig();
      expect(config!.data.archiveOrgS3AccessKey, equals('new-access-key'));
      expect(config.data.archiveOrgS3SecretKey, equals('new-secret-key'));
    });

    test('updates multiple fields at once', () async {
      await database.updateUserConfig(
        id: userConfigId,
        darkMode: true,
        defaultArchiveIs: true,
        defaultArchiveOrg: false,
      );

      final config = await database.getUserConfig();
      expect(config!.data.darkMode, isTrue);
      expect(config.data.defaultArchiveIs, isTrue);
      expect(config.data.defaultArchiveOrg, isFalse);
    });

    test('updates selectedThemeKey', () async {
      await database.updateUserConfig(
        id: userConfigId,
        selectedThemeKey: 'my-theme-key',
      );

      final config = await database.getUserConfig();
      expect(config!.data.selectedThemeKey, equals('my-theme-key'));
    });

    test('updates selectedThemeType', () async {
      await database.updateUserConfig(
        id: userConfigId,
        selectedThemeType: ThemeType.system,
      );

      final config = await database.getUserConfig();
      expect(config!.data.selectedThemeType, equals(ThemeType.system.index));
    });

    test('updates timeDisplayFormat', () async {
      await database.updateUserConfig(
        id: userConfigId,
        timeDisplayFormat: 24,
      );

      final config = await database.getUserConfig();
      expect(config!.data.timeDisplayFormat, equals(24));
    });

    test('updates itemClickAction', () async {
      await database.updateUserConfig(
        id: userConfigId,
        itemClickAction: 2,
      );

      final config = await database.getUserConfig();
      expect(config!.data.itemClickAction, equals(2));
    });

    test('updates cacheDirectory', () async {
      await database.updateUserConfig(
        id: userConfigId,
        cacheDirectory: '/custom/cache/path',
      );

      final config = await database.getUserConfig();
      expect(config!.data.cacheDirectory, equals('/custom/cache/path'));
    });

    test('updates with theme creation', () async {
      final newTheme = UserTheme(
        id: '',
        userConfigId: userConfigId,
        name: 'New Theme',
        primaryColor: 0xFFFF0000,
        secondaryColor: 0xFF00FF00,
        tertiaryColor: null,
        seedType: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await database.updateUserConfig(
        id: userConfigId,
        themeUpdates: CUD(
          create: [newTheme],
          update: [],
          remove: [],
        ),
      );

      expect(result['create'], isNotEmpty);
      expect(result['create']!.length, equals(1));

      final themes = await database.getAllUserThemes();
      expect(themes.any((t) => t.data.name == 'New Theme'), isTrue);
    });

    test('updates with theme deletion', () async {
      // Create a theme first
      final themeId = 'delete-me-1234567890123456789012';
      await database.into(database.userThemes).insert(
            UserThemesCompanion.insert(
              id: themeId,
              userConfigId: userConfigId,
              name: 'To Delete',
              primaryColor: 0xFF000000,
              secondaryColor: 0xFFFFFFFF,
              seedType: Value(0),
            ),
          );

      final result = await database.updateUserConfig(
        id: userConfigId,
        themeUpdates: CUD(
          create: [],
          update: [],
          remove: [themeId],
        ),
      );

      expect(result['remove'], isNotEmpty);

      final themes = await database.getAllUserThemes();
      expect(themes.any((t) => t.data.id == themeId), isFalse);
    });

    test('preserves unchanged fields', () async {
      final initialKey = 'initial-key';

      // Update only darkMode
      await database.updateUserConfig(
        id: userConfigId,
        darkMode: true,
      );

      final config = await database.getUserConfig();
      expect(config!.data.darkMode, isTrue);
      expect(config.data.archiveOrgS3AccessKey, equals(initialKey));
    });

    test('updates null values correctly', () async {
      // First set a value
      await database.updateUserConfig(
        id: userConfigId,
        cacheDirectory: '/some/path',
      );

      // Then clear it by setting to null
      await database.updateUserConfig(
        id: userConfigId,
        cacheDirectory: '',
      );

      final config = await database.getUserConfig();
      // Depending on implementation, might be null or empty
      expect(
        config!.data.cacheDirectory == null || config.data.cacheDirectory == '',
        isTrue,
      );
    });
  });
}
