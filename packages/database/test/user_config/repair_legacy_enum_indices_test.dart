import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:database/src/core/initial_data/config_database.dart";
import "package:flutter_test/flutter_test.dart";

/// Regression test for the v5 migration bug that left `-1` in
/// `user_configs.{selected_theme_type, time_display_format,
/// item_click_action}` (and `user_themes.seed_type`) when a v3-era
/// row's int default of `0` was naively decremented during the
/// lookup-table → intEnum migration. Reading any of those columns
/// then crashed with `RangeError: -1` in `EnumIndexConverter.fromSql`.
///
/// The fix is two-pronged:
///   - the v5 migration now clamps with `MAX(0, column - 1)` so
///     future upgrades from v4 can't reproduce it;
///   - `_repairLegacyEnumIndices` runs on every startup so databases
///     that already shipped through the buggy migration get healed.
///
/// This file exercises only the startup repair — the migration-side
/// fix is covered structurally by `schema_verification_test.dart`.
void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late ConfigDatabase database;

  setUp(() {
    database = ConfigDatabase(
      databaseName: "test_repair_enum_db",
      setupOnInit: false,
      debugMode: true,
    );
  });

  tearDown(() async {
    await database.delete(database.userConfigs).go();
    await database.delete(database.userThemes).go();
    await database.close();
  });

  group("setupUserConfig() repairs legacy -1 enum indices", () {
    test(
        "user_configs row with -1 in time_display_format and item_click_action "
        "is repaired to 0 before any read", () async {
      // Plant a row in the broken post-buggy-v5 state.
      await database.customStatement(
        "INSERT INTO user_configs (id, selected_theme_type, "
        "time_display_format, item_click_action) "
        "VALUES ('broken', 0, -1, -1)",
      );

      // setupUserConfig() should fix it up. If the repair is missing,
      // the subsequent .getSingleOrNull() inside _setupUserConfigEntry
      // throws RangeError before it can return.
      await database.setupUserConfig();

      final row = await database.customSelect(
        "SELECT selected_theme_type, time_display_format, item_click_action "
        "FROM user_configs WHERE id = 'broken'",
      ).getSingle();

      expect(row.read<int>("selected_theme_type"), equals(0));
      expect(row.read<int>("time_display_format"), equals(0));
      expect(row.read<int>("item_click_action"), equals(0));
    });

    test("user_themes row with -1 in seed_type is repaired to 0", () async {
      // user_themes references user_configs via FK; plant both.
      await database.customStatement(
        "INSERT INTO user_configs (id, selected_theme_type, "
        "time_display_format, item_click_action) "
        "VALUES ('cfg', 0, 0, 0)",
      );
      await database.customStatement(
        "INSERT INTO user_themes (id, user_config_id, name, primary_color, "
        "secondary_color, seed_type) "
        "VALUES ('broken_theme', 'cfg', 'X', 0, 0, -1)",
      );

      await database.setupUserConfig();

      final row = await database.customSelect(
        "SELECT seed_type FROM user_themes WHERE id = 'broken_theme'",
      ).getSingle();
      expect(row.read<int>("seed_type"), equals(0));
    });

    test("healthy rows are untouched (repair is idempotent)", () async {
      await database.customStatement(
        "INSERT INTO user_configs (id, selected_theme_type, "
        "time_display_format, item_click_action) "
        "VALUES ('healthy', 1, 1, 1)",
      );

      await database.setupUserConfig();
      await database.setupUserConfig(); // run again — must stay at 1

      final row = await database.customSelect(
        "SELECT selected_theme_type, time_display_format, item_click_action "
        "FROM user_configs WHERE id = 'healthy'",
      ).getSingle();

      expect(row.read<int>("selected_theme_type"), equals(1));
      expect(row.read<int>("time_display_format"), equals(1));
      expect(row.read<int>("item_click_action"), equals(1));
    });
  });
}
