import "package:database/main.dart";
import "package:flutter_test/flutter_test.dart";

import "package:database/src/features/user_config/create.dart";
import "package:database/src/features/user_config/read.dart";
import "package:database/src/features/user_theme/create.dart";
import "package:database/src/features/user_theme/remove.dart";
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

    final userConfig = UserConfig(
      id: "",
      darkMode: false,
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
    final result = await database.createUserConfig(userConfig);
    userConfigId = result.userConfigId;
  });

  tearDown(() async {
    final userConfigs = database.userConfigs;
    await database.delete(userConfigs).go();
    final userThemes = database.userThemes;
    await database.delete(userThemes).go();
    await database.close();
  });

  group("removeUserTheme()", () {
    test("removes a single theme by ID", () async {
      final created = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [
          UserTheme(
            id: "",
            userConfigId: userConfigId,
            name: "To Delete",
            primaryColor: 0xFFFF0000,
            secondaryColor: 0xFF00FF00,
            seedType: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );
      final themeId = created.first.userThemeId;

      await database.removeUserTheme(id: themeId);

      final remaining = await database.getAllUserThemes();
      expect(remaining, isEmpty);
    });

    test("does not affect other themes", () async {
      final created = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [
          UserTheme(
            id: "",
            userConfigId: userConfigId,
            name: "Keep",
            primaryColor: 0xFF111111,
            secondaryColor: 0xFF222222,
            seedType: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          UserTheme(
            id: "",
            userConfigId: userConfigId,
            name: "Delete",
            primaryColor: 0xFF333333,
            secondaryColor: 0xFF444444,
            seedType: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );

      await database.removeUserTheme(id: created[1].userThemeId);

      final remaining = await database.getAllUserThemes();
      expect(remaining.length, equals(1));
      expect(remaining.first.data.name, equals("Keep"));
    });

    test("does not throw for non-existent ID", () async {
      await expectLater(
        database.removeUserTheme(id: "non_existent_theme_id"),
        completes,
      );

      final remaining = await database.getAllUserThemes();
      expect(remaining, isEmpty);
    });
  });

  group("removeUserThemes()", () {
    test("removes multiple themes by IDs", () async {
      final created = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [
          UserTheme(
            id: "",
            userConfigId: userConfigId,
            name: "Theme A",
            primaryColor: 0xFF111111,
            secondaryColor: 0xFF222222,
            seedType: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          UserTheme(
            id: "",
            userConfigId: userConfigId,
            name: "Theme B",
            primaryColor: 0xFF333333,
            secondaryColor: 0xFF444444,
            seedType: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          UserTheme(
            id: "",
            userConfigId: userConfigId,
            name: "Theme C",
            primaryColor: 0xFF555555,
            secondaryColor: 0xFF666666,
            seedType: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );

      await database.removeUserThemes(
        ids: [created[0].userThemeId, created[2].userThemeId],
      );

      final remaining = await database.getAllUserThemes();
      expect(remaining.length, equals(1));
      expect(remaining.first.data.name, equals("Theme B"));
    });

    test("handles empty ID list gracefully", () async {
      await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [
          UserTheme(
            id: "",
            userConfigId: userConfigId,
            name: "Untouched",
            primaryColor: 0xFFAAAAAA,
            secondaryColor: 0xFFBBBBBB,
            seedType: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );

      await database.removeUserThemes(ids: []);

      final remaining = await database.getAllUserThemes();
      expect(remaining.length, equals(1));
    });

    test("handles mix of existing and non-existent IDs", () async {
      final created = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [
          UserTheme(
            id: "",
            userConfigId: userConfigId,
            name: "Exists",
            primaryColor: 0xFFCCCCCC,
            secondaryColor: 0xFFDDDDDD,
            seedType: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );

      await database.removeUserThemes(
        ids: [created.first.userThemeId, "non_existent_id"],
      );

      final remaining = await database.getAllUserThemes();
      expect(remaining, isEmpty);
    });

    test("removes all themes when all IDs provided", () async {
      final created = await database.createUserTheme(
        userConfigId: userConfigId,
        themes: [
          UserTheme(
            id: "",
            userConfigId: userConfigId,
            name: "Theme 1",
            primaryColor: 0xFF111111,
            secondaryColor: 0xFF222222,
            seedType: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          UserTheme(
            id: "",
            userConfigId: userConfigId,
            name: "Theme 2",
            primaryColor: 0xFF333333,
            secondaryColor: 0xFF444444,
            seedType: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
      );

      await database.removeUserThemes(
        ids: created.map((r) => r.userThemeId).toList(),
      );

      final remaining = await database.getAllUserThemes();
      expect(remaining, isEmpty);
    });
  });
}
