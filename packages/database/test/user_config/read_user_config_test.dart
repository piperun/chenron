import "package:database/main.dart";
import "package:database/src/features/user_config/create.dart";
import "package:database/src/features/user_config/read.dart";
import "package:flutter_test/flutter_test.dart";

import "package:drift/drift.dart" hide isNotNull, isNull;
import "package:chenron_mockups/chenron_mockups.dart";

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
    final userConfigs = database.userConfigs;
    await database.delete(userConfigs).go();
    final userThemes = database.userThemes;
    await database.delete(userThemes).go();
    await database.close();
  });

  group("UserConfigReadExtensions.getUserConfig()", () {
    test("retrieves existing user config", () async {
      // Create a config first
      final userConfig = UserConfig(
        id: "",
        darkMode: true,
        archiveOrgS3AccessKey: "test-key",
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
      await database.createUserConfig(userConfig);

      // Retrieve it
      final result = await database.getUserConfig();

      expect(result, isNotNull);
      expect(result!.data.darkMode, isTrue);
      expect(result.data.archiveOrgS3AccessKey, equals("test-key"));
    });

    test("returns null when no config exists", () async {
      final result = await database.getUserConfig();

      expect(result, isNull);
    });

    test("returns first config when multiple exist", () async {
      // Create two configs
      final config1 = UserConfig(
        id: "",
        darkMode: true,
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
      final config2 = UserConfig(
        id: "",
        darkMode: false,
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
      await database.createUserConfig(config1);
      await database.createUserConfig(config2);

      final result = await database.getUserConfig();

      expect(result, isNotNull);
      // Should return the first one
      expect(result!.data.darkMode, isTrue);
    });
  });

  group("UserConfigReadExtensions.watchUserConfig()", () {
    test("emits config when it exists", () async {
      final userConfig = UserConfig(
        id: "",
        darkMode: true,
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
      await database.createUserConfig(userConfig);

      final stream = database.watchUserConfig();

      await expectLater(
        stream,
        emits(predicate<dynamic>((result) {
          return result != null && result.data.darkMode == true;
        })),
      );
    });

    test("emits null when no config exists", () async {
      final stream = database.watchUserConfig();

      await expectLater(stream, emits(null));
    });

    test("emits updates when config is created", () async {
      final stream = database.watchUserConfig();

      // Initially null
      await expectLater(stream, emits(null));

      // Create config
      final userConfig = UserConfig(
        id: "",
        darkMode: false,
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
      await database.createUserConfig(userConfig);

      // Should emit the new config
      await expectLater(
        stream,
        emits(predicate<dynamic>((result) {
          return result != null && result.data.darkMode == false;
        })),
      );
    });
  });

  group("UserConfigReadExtensions.getUserTheme()", () {
    test("retrieves existing user theme", () async {
      // Create a user config first
      final userConfig = UserConfig(
        id: "",
        darkMode: false,
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
      // Create a theme manually
      final themeId = "test-theme-id-1234567890123456";
      final userThemes = database.userThemes;
      await database.into(userThemes).insert(
            UserThemesCompanion.insert(
              id: themeId,
              userConfigId: configResult.userConfigId,
              name: "Blue Theme",
              primaryColor: 0xFF0000FF,
              secondaryColor: 0xFF00FFFF,
              seedType: const Value(0),
            ),
          );

      final result = await database.getUserTheme(themeKey: themeId);

      expect(result, isNotNull);
      expect(result!.data.name, equals("Blue Theme"));
      expect(result.data.primaryColor, equals(0xFF0000FF));
    });

    test("returns null for non-existent theme", () async {
      final result = await database.getUserTheme(themeKey: "non-existent");

      expect(result, isNull);
    });
  });

  group("UserConfigReadExtensions.watchUserTheme()", () {
    test("emits theme when it exists", () async {
      final userConfig = UserConfig(
        id: "",
        darkMode: false,
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

      final themeId = "watch-theme-12345678901234567890";
      final userThemes = database.userThemes;
      await database.into(userThemes).insert(
            UserThemesCompanion.insert(
              id: themeId,
              userConfigId: configResult.userConfigId,
              name: "Watch Theme",
              primaryColor: 0xFF123456,
              secondaryColor: 0xFF654321,
              seedType: const Value(0),
            ),
          );

      final stream = database.watchUserTheme(themeId: themeId);

      await expectLater(
        stream,
        emits(predicate<dynamic>((result) {
          return result != null && result.data.name == "Watch Theme";
        })),
      );
    });

    test("emits null for non-existent theme", () async {
      final stream = database.watchUserTheme(themeId: "non-existent");

      await expectLater(stream, emits(null));
    });
  });

  group("UserConfigReadExtensions.watchAllUserThemes()", () {
    test("emits all themes", () async {
      final userConfig = UserConfig(
        id: "",
        darkMode: false,
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

      final userThemes = database.userThemes;
      await database.into(userThemes).insert(
            UserThemesCompanion.insert(
              id: "theme-a-123456789012345678901234",
              userConfigId: configResult.userConfigId,
              name: "Theme A",
              primaryColor: 0xFFAAAAAA,
              secondaryColor: 0xFFBBBBBB,
              seedType: const Value(0),
            ),
          );

      final stream = database.watchAllUserThemes();

      await expectLater(
        stream,
        emits(predicate<List>((results) {
          return results.length == 1 && results.first.data.name == "Theme A";
        })),
      );
    });

    test("emits empty list when no themes exist", () async {
      final stream = database.watchAllUserThemes();

      await expectLater(
        stream,
        emits(predicate<List>((results) => results.isEmpty)),
      );
    });
  });

  group("UserConfigReadExtensions.searchUserThemes()", () {
    test("finds themes matching query", () async {
      final userConfig = UserConfig(
        id: "",
        darkMode: false,
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

      final userThemes = database.userThemes;
      await database.into(userThemes).insert(
            UserThemesCompanion.insert(
              id: "theme-dark-12345678901234567890123",
              userConfigId: configResult.userConfigId,
              name: "Dark Blue",
              primaryColor: 0xFF000080,
              secondaryColor: 0xFF000040,
              seedType: const Value(0),
            ),
          );

      await database.into(userThemes).insert(
            UserThemesCompanion.insert(
              id: "theme-light-1234567890123456789012",
              userConfigId: configResult.userConfigId,
              name: "Light Blue",
              primaryColor: 0xFFADD8E6,
              secondaryColor: 0xFF87CEEB,
              seedType: const Value(0),
            ),
          );

      final results = await database.searchUserThemes(query: "Blue");

      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.any((r) => r.data.name.contains("Blue")), isTrue);
    });

    test("returns empty list when no matches", () async {
      final results = await database.searchUserThemes(query: "nonexistent");

      expect(results, isEmpty);
    });
  });
}
