import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:vibe/vibe.dart";

void main() {
  group("VibeTheme.fromSeed", () {
    test("produces valid light and dark ThemeData", () {
      final VibeTheme theme = VibeTheme.fromSeed(
        id: "ocean",
        name: "Ocean",
        primary: const Color(0xFF0066CC),
      );

      expect(theme.id, "ocean");
      expect(theme.name, "Ocean");

      final ThemeVariants variants = theme.build();
      expect(variants.light, isA<ThemeData>());
      expect(variants.dark, isA<ThemeData>());
      expect(variants.light.brightness, Brightness.light);
      expect(variants.dark.brightness, Brightness.dark);
    });

    test("accepts secondary and tertiary seed colors", () {
      final VibeTheme theme = VibeTheme.fromSeed(
        id: "tri",
        name: "Tri-color",
        primary: const Color(0xFF0066CC),
        secondary: const Color(0xFF00CC66),
        tertiary: const Color(0xFFCC6600),
        useSecondary: true,
        useTertiary: true,
      );

      final ThemeVariants variants = theme.build();
      expect(variants.light, isA<ThemeData>());
      expect(variants.dark, isA<ThemeData>());
    });
  });

  group("VibeTheme.fromPalette", () {
    test("produces valid light and dark ThemeData", () {
      const VibePalette lightPalette = VibePalette(
        canvas: Color(0xFFFFFFFF),
        surface: Color(0xFFF5F5F5),
        content: Color(0xFF212121),
        accent: Color(0xFF1976D2),
        outline: Color(0xFFBDBDBD),
        error: Color(0xFFD32F2F),
      );
      const VibePalette darkPalette = VibePalette(
        canvas: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
        content: Color(0xFFE0E0E0),
        accent: Color(0xFF90CAF9),
        outline: Color(0xFF616161),
        error: Color(0xFFEF9A9A),
      );

      final VibeTheme theme = VibeTheme.fromPalette(
        id: "material",
        name: "Material",
        light: lightPalette,
        dark: darkPalette,
      );

      expect(theme.id, "material");
      expect(theme.name, "Material");

      final ThemeVariants variants = theme.build();
      expect(variants.light, isA<ThemeData>());
      expect(variants.dark, isA<ThemeData>());
    });

    test("applies canvas and surface overrides", () {
      const VibePalette lightPalette = VibePalette(
        canvas: Color(0xFFFAFAFA),
        surface: Color(0xFFEEEEEE),
        content: Color(0xFF333333),
        accent: Color(0xFF1976D2),
        outline: Color(0xFFBDBDBD),
        error: Color(0xFFD32F2F),
      );
      const VibePalette darkPalette = VibePalette(
        canvas: Color(0xFF1A1A1A),
        surface: Color(0xFF2C2C2C),
        content: Color(0xFFCCCCCC),
        accent: Color(0xFF64B5F6),
        outline: Color(0xFF555555),
        error: Color(0xFFEF5350),
      );

      final VibeTheme theme = VibeTheme.fromPalette(
        id: "test",
        name: "Test",
        light: lightPalette,
        dark: darkPalette,
      );

      final ThemeVariants variants = theme.build();

      // Verify copyWith overrides are applied
      expect(
        variants.light.scaffoldBackgroundColor,
        const Color(0xFFFAFAFA),
      );
      expect(
        variants.light.cardTheme.color,
        const Color(0xFFEEEEEE),
      );
      expect(
        variants.light.colorScheme.onSurface,
        const Color(0xFF333333),
      );
      expect(
        variants.dark.scaffoldBackgroundColor,
        const Color(0xFF1A1A1A),
      );
      expect(
        variants.dark.cardTheme.color,
        const Color(0xFF2C2C2C),
      );
    });
  });
}
