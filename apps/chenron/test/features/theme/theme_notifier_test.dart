import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:vibe/vibe.dart";

/// Characterization tests for [generateSeedTheme]'s seedType -> key-color
/// flag mapping.
///
/// The documented contract is:
///   0 = no key-color seeding   (useSecondary=false, useTertiary=false)
///   1 = primary only           (useSecondary=false, useTertiary=false)
///   2 = primary + secondary     (useSecondary=true,  useTertiary=false)
///   3 = primary + secondary + tertiary (useSecondary=true, useTertiary=true)
///
/// We pin this two ways: each seedType must reproduce the ColorScheme of
/// a direct [buildSeededVariants] call with the expected flags, and the
/// observable consequences (0 == 1, 2 differs from 0/1, 3 differs from 2)
/// must hold when the seed colors are distinct hues.
void main() {
  // Three strongly separated hues so the seeding algorithm produces
  // observably different palettes as each key color is switched on.
  int argbForHue(double hue) =>
      HSLColor.fromAHSL(1.0, hue, 0.9, 0.5).toColor().toARGB32();
  final int primary = argbForHue(0);
  final int secondary = argbForHue(120);
  final int tertiary = argbForHue(240);

  ThemeVariants gen(int seedType) => generateSeedTheme(
        primaryColor: primary,
        secondaryColor: secondary,
        tertiaryColor: tertiary,
        seedType: seedType,
      );

  ThemeVariants expected({required bool useSecondary, required bool useTertiary}) =>
      buildSeededVariants(
        primary: Color(primary),
        secondary: Color(secondary),
        tertiary: Color(tertiary),
        useSecondary: useSecondary,
        useTertiary: useTertiary,
      );

  void expectSameScheme(ThemeVariants a, ThemeVariants b) {
    expect(a.light.colorScheme, b.light.colorScheme);
    expect(a.dark.colorScheme, b.dark.colorScheme);
  }

  group("generateSeedTheme seedType mapping", () {
    test("seedType 0 maps to neither secondary nor tertiary key color", () {
      expectSameScheme(
        gen(0),
        expected(useSecondary: false, useTertiary: false),
      );
    });

    test("seedType 1 maps to neither secondary nor tertiary key color", () {
      expectSameScheme(
        gen(1),
        expected(useSecondary: false, useTertiary: false),
      );
    });

    test("seedType 2 enables secondary but not tertiary key color", () {
      expectSameScheme(
        gen(2),
        expected(useSecondary: true, useTertiary: false),
      );
    });

    test("seedType 3 enables both secondary and tertiary key colors", () {
      expectSameScheme(
        gen(3),
        expected(useSecondary: true, useTertiary: true),
      );
    });
  });

  group("generateSeedTheme observable boundaries", () {
    test("seedType 0 and 1 produce identical color schemes", () {
      expectSameScheme(gen(0), gen(1));
    });

    test("seedType 2 differs from 0/1 (secondary now seeds the palette)", () {
      expect(gen(2).light.colorScheme == gen(0).light.colorScheme, isFalse);
      expect(gen(2).light.colorScheme == gen(1).light.colorScheme, isFalse);
    });

    test("seedType 3 differs from 2 (tertiary now seeds the palette)", () {
      expect(gen(3).light.colorScheme == gen(2).light.colorScheme, isFalse);
    });

    test("seedType above 3 stays clamped to the all-on flag combination", () {
      // useSec = seedType >= 2, useTer = seedType >= 3 — any value >= 3
      // is equivalent to seedType 3.
      expectSameScheme(
        gen(4),
        expected(useSecondary: true, useTertiary: true),
      );
    });

    test("null tertiary with seedType 3 still builds (tertiary defaults)", () {
      // buildSeededVariants substitutes secondary (then primary) for a
      // null tertiary, so the call must not throw and produces a scheme.
      final v = generateSeedTheme(
        primaryColor: primary,
        secondaryColor: secondary,
        tertiaryColor: null,
        seedType: 3,
      );
      expect(v.light.colorScheme, isA<ColorScheme>());
      expect(v.dark.colorScheme, isA<ColorScheme>());
    });
  });
}
