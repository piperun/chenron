import 'package:flutter_test/flutter_test.dart';
import 'package:database/database.dart';
import 'package:database/extensions/user_config/create.dart';
import 'package:database/extensions/user_config/read.dart';
import 'package:database/extensions/user_theme/create.dart';
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

    // Create a base user config for testing theme creation
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

  group('UserThemeCreateExtension.createUserTheme()', () {
    test('creates single user theme', () async {
      final theme = UserTheme(
        id: '',
        userConfigId: userConfigId,
        name: 'Ocean Blue',
        primaryColor: 0xFF0077BE,
        secondaryColor: 0xFF00A8E8,
        seedType: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final results = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [theme],
      );

      expect(results.length, equals(1));
      expect(results.first.userThemeId, isNotEmpty);
      expect(results.first.userConfigId, equals(userConfigId));

      // Verify in database
      final themes = await database.getAllUserThemes();
      expect(themes.length, equals(1));
      expect(themes.first.data.name, equals('Ocean Blue'));
      expect(themes.first.data.primaryColor, equals(0xFF0077BE));
    });

    test('creates multiple user themes', () async {
      final themes = [
        UserTheme(
          id: '',
          userConfigId: userConfigId,
          name: 'Theme 1',
          primaryColor: 0xFFFF0000,
          secondaryColor: 0xFFFF5555,
          seedType: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        UserTheme(
          id: '',
          userConfigId: userConfigId,
          name: 'Theme 2',
          primaryColor: 0xFF00FF00,
          secondaryColor: 0xFF55FF55,
          seedType: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        UserTheme(
          id: '',
          userConfigId: userConfigId,
          name: 'Theme 3',
          primaryColor: 0xFF0000FF,
          secondaryColor: 0xFF5555FF,
          seedType: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final results = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: themes,
      );

      expect(results.length, equals(3));
      expect(results.every((r) => r.userConfigId == userConfigId), isTrue);

      // Verify all themes in database
      final allThemes = await database.getAllUserThemes();
      expect(allThemes.length, equals(3));

      final themeNames = allThemes.map((t) => t.data.name).toSet();
      expect(themeNames, equals({'Theme 1', 'Theme 2', 'Theme 3'}));
    });

    test('creates theme with all optional fields', () async {
      final theme = UserTheme(
        id: '',
        userConfigId: userConfigId,
        name: 'Complete Theme',
        primaryColor: 0xFF123456,
        secondaryColor: 0xFF654321,
        tertiaryColor: 0xFFABCDEF,
        seedType: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final results = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [theme],
      );

      expect(results.length, equals(1));

      final savedTheme = await database.getUserTheme(
        themeKey: results.first.userThemeId,
      );

      expect(savedTheme, isNotNull);
      expect(savedTheme!.data.tertiaryColor, equals(0xFFABCDEF));
      expect(savedTheme.data.seedType, equals(1));
    });

    test('creates theme without optional fields', () async {
      final theme = UserTheme(
        id: '',
        userConfigId: userConfigId,
        name: 'Minimal Theme',
        primaryColor: 0xFF000000,
        secondaryColor: 0xFFFFFFFF,
        seedType: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final results = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [theme],
      );

      expect(results.length, equals(1));

      final savedTheme = await database.getUserTheme(
        themeKey: results.first.userThemeId,
      );

      expect(savedTheme, isNotNull);
      expect(savedTheme!.data.name, equals('Minimal Theme'));
    });

    test('handles empty theme list', () async {
      final results = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [],
      );

      expect(results, isEmpty);

      final allThemes = await database.getAllUserThemes();
      expect(allThemes, isEmpty);
    });

    test('creates themes with unique IDs', () async {
      final themes = [
        UserTheme(
          id: '',
          userConfigId: userConfigId,
          name: 'Theme A',
          primaryColor: 0xFF111111,
          secondaryColor: 0xFF222222,
          seedType: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        UserTheme(
          id: '',
          userConfigId: userConfigId,
          name: 'Theme B',
          primaryColor: 0xFF333333,
          secondaryColor: 0xFF444444,
          seedType: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final results = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: themes,
      );

      expect(results.length, equals(2));
      expect(results[0].userThemeId, isNot(equals(results[1].userThemeId)));

      // Verify unique IDs are 30 characters (CUID2)
      expect(results[0].userThemeId.length, equals(30));
      expect(results[1].userThemeId.length, equals(30));
    });

    test('links themes to correct user config', () async {
      final theme = UserTheme(
        id: '',
        userConfigId: userConfigId,
        name: 'Linked Theme',
        primaryColor: 0xFFAAAAAA,
        secondaryColor: 0xFFBBBBBB,
        seedType: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final results = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [theme],
      );

      // Verify the theme is linked to the correct config
      final savedTheme = await (database.select(database.userThemes)
            ..where((tbl) => tbl.id.equals(results.first.userThemeId)))
          .getSingleOrNull();

      expect(savedTheme, isNotNull);
      expect(savedTheme!.userConfigId, equals(userConfigId));
    });

    test('creates themes with special characters in names', () async {
      final theme = UserTheme(
        id: '',
        userConfigId: userConfigId,
        name: 'Theme: "Special" & <Cool>',
        primaryColor: 0xFF123ABC,
        secondaryColor: 0xFFDEF456,
        seedType: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final results = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [theme],
      );

      final savedTheme = await database.getUserTheme(
        themeKey: results.first.userThemeId,
      );

      expect(savedTheme!.data.name, equals('Theme: "Special" & <Cool>'));
    });

    test('creates themes with hex color variations', () async {
      final themes = [
        UserTheme(
          id: '',
          userConfigId: userConfigId,
          name: 'Short Hex',
          primaryColor: 0xFFFFFFFF,
          secondaryColor: 0xFF000000,
          seedType: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        UserTheme(
          id: '',
          userConfigId: userConfigId,
          name: 'Long Hex',
          primaryColor: 0xFFFFFFFF,
          secondaryColor: 0xFF000000,
          seedType: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        UserTheme(
          id: '',
          userConfigId: userConfigId,
          name: 'With Alpha',
          primaryColor: 0x00FFFFFF,
          secondaryColor: 0xFF000000,
          seedType: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final results = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: themes,
      );

      expect(results.length, equals(3));

      final allThemes = await database.getAllUserThemes();
      expect(allThemes.length, equals(3));
    });
  });
}
