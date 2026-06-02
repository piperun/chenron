import "package:chenron/features/theme/state/theme_cache.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:vibe/vibe.dart";

/// Round-trip tests for [ThemeCache] against a mocked SharedPreferences
/// store. Covers the three reconstruction branches in [loadCachedTheme]
/// (custom seed, "nier" built-in, FlexScheme system theme) plus the
/// failure paths (missing keys, stale/invalid FlexScheme name).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  group("custom theme round-trip", () {
    test("cacheCustomTheme then loadCachedTheme rebuilds the seed scheme",
        () async {
      final prefs = await prefsWith(<String, Object>{});

      const primary = 0xFFEF5350;
      const secondary = 0xFF42A5F5;
      const tertiary = 0xFFFFCA28;
      const seedType = 3;

      await ThemeCache.cacheCustomTheme(
        prefs,
        key: "my-custom",
        primaryColor: primary,
        secondaryColor: secondary,
        tertiaryColor: tertiary,
        seedType: seedType,
      );

      final loaded = ThemeCache.loadCachedTheme(prefs);
      expect(loaded, isNotNull);

      // The cache must rebuild exactly what generateSeedTheme produces
      // for the same stored seed data.
      final expected = generateSeedTheme(
        primaryColor: primary,
        secondaryColor: secondary,
        tertiaryColor: tertiary,
        seedType: seedType,
      );
      expect(loaded!.light.colorScheme, expected.light.colorScheme);
      expect(loaded.dark.colorScheme, expected.dark.colorScheme);
    });

    test("custom theme with null tertiary round-trips", () async {
      final prefs = await prefsWith(<String, Object>{});

      const primary = 0xFFEF5350;
      const secondary = 0xFF42A5F5;
      const seedType = 2;

      await ThemeCache.cacheCustomTheme(
        prefs,
        key: "no-tertiary",
        primaryColor: primary,
        secondaryColor: secondary,
        tertiaryColor: null,
        seedType: seedType,
      );

      final loaded = ThemeCache.loadCachedTheme(prefs);
      expect(loaded, isNotNull);

      final expected = generateSeedTheme(
        primaryColor: primary,
        secondaryColor: secondary,
        tertiaryColor: null,
        seedType: seedType,
      );
      expect(loaded!.light.colorScheme, expected.light.colorScheme);
    });

    test("custom theme missing seed colors returns null", () async {
      // type=0 (custom) but no primary/secondary/seedType stored — the
      // guard inside loadCachedTheme bails out to null.
      final prefs = await prefsWith(<String, Object>{
        "theme_key": "broken-custom",
        "theme_type": 0,
      });

      expect(ThemeCache.loadCachedTheme(prefs), isNull);
    });
  });

  group("system theme round-trip", () {
    test("cacheSystemTheme then loadCachedTheme rebuilds the FlexScheme",
        () async {
      final prefs = await prefsWith(<String, Object>{});

      await ThemeCache.cacheSystemTheme(prefs, key: "materialBaseline");

      final loaded = ThemeCache.loadCachedTheme(prefs);
      expect(loaded, isNotNull);

      final expectedLight =
          FlexThemeData.light(scheme: FlexScheme.materialBaseline);
      final expectedDark =
          FlexThemeData.dark(scheme: FlexScheme.materialBaseline);
      expect(loaded!.light.colorScheme, expectedLight.colorScheme);
      expect(loaded.dark.colorScheme, expectedDark.colorScheme);
    });

    test("caching a system theme clears any prior custom seed keys",
        () async {
      // Start with a custom theme cached, then overwrite with a system
      // theme — the custom-only keys must be removed so loadCachedTheme
      // takes the system branch (not the type==0 custom branch).
      final prefs = await prefsWith(<String, Object>{});

      await ThemeCache.cacheCustomTheme(
        prefs,
        key: "old-custom",
        primaryColor: 0xFFEF5350,
        secondaryColor: 0xFF42A5F5,
        tertiaryColor: 0xFFFFCA28,
        seedType: 3,
      );
      await ThemeCache.cacheSystemTheme(prefs, key: "materialBaseline");

      // theme_type now 1, and the custom seed keys are gone.
      expect(prefs.getInt("theme_type"), 1);
      expect(prefs.getInt("theme_primary"), isNull);
      expect(prefs.getInt("theme_secondary"), isNull);
      expect(prefs.getInt("theme_tertiary"), isNull);
      expect(prefs.getInt("theme_seed_type"), isNull);

      final loaded = ThemeCache.loadCachedTheme(prefs);
      expect(loaded, isNotNull);
      expect(
        loaded!.light.colorScheme,
        FlexThemeData.light(scheme: FlexScheme.materialBaseline).colorScheme,
      );
    });
  });

  group("nier built-in special case", () {
    test('"nier" system key rebuilds the NierTheme variants', () async {
      final prefs = await prefsWith(<String, Object>{});

      await ThemeCache.cacheSystemTheme(prefs, key: "nier");

      final loaded = ThemeCache.loadCachedTheme(prefs);
      expect(loaded, isNotNull);

      final nier = NierTheme().build();
      expect(loaded!.light.colorScheme, nier.light.colorScheme);
      expect(loaded.dark.colorScheme, nier.dark.colorScheme);
    });
  });

  group("failure paths", () {
    test("no cache at all returns null", () async {
      final prefs = await prefsWith(<String, Object>{});
      expect(ThemeCache.loadCachedTheme(prefs), isNull);
    });

    test("missing theme_type returns null even if key present", () async {
      final prefs = await prefsWith(<String, Object>{
        "theme_key": "materialBaseline",
      });
      expect(ThemeCache.loadCachedTheme(prefs), isNull);
    });

    test("stale/invalid FlexScheme name hits the catch path and returns null",
        () async {
      // type=1 (system) with a key that is not a FlexScheme enum name.
      // FlexScheme.values.byName throws -> caught -> null.
      final prefs = await prefsWith(<String, Object>{
        "theme_key": "schemeThatWasRenamedOrRemoved",
        "theme_type": 1,
      });
      expect(ThemeCache.loadCachedTheme(prefs), isNull);
    });

    test("clearCache wipes every theme key", () async {
      final prefs = await prefsWith(<String, Object>{});
      await ThemeCache.cacheCustomTheme(
        prefs,
        key: "x",
        primaryColor: 0xFFEF5350,
        secondaryColor: 0xFF42A5F5,
        tertiaryColor: 0xFFFFCA28,
        seedType: 3,
      );

      await ThemeCache.clearCache(prefs);

      expect(ThemeCache.loadCachedTheme(prefs), isNull);
      expect(prefs.getString("theme_key"), isNull);
      expect(prefs.getInt("theme_type"), isNull);
    });
  });
}
