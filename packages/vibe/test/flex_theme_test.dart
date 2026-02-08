import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:vibe/vibe.dart";

class _TestFlexTheme extends FlexVibeTheme {
  @override
  String get id => "test_flex";

  @override
  String get name => "Test Flex";

  @override
  FlexSchemeColor get lightColors => const FlexSchemeColor(
        primary: Color(0xFF1976D2),
        secondary: Color(0xFF388E3C),
        tertiary: Color(0xFFF57C00),
      );

  @override
  FlexSchemeColor get darkColors => const FlexSchemeColor(
        primary: Color(0xFF90CAF9),
        secondary: Color(0xFFA5D6A7),
        tertiary: Color(0xFFFFCC80),
      );
}

void main() {
  group("FlexVibeTheme", () {
    late _TestFlexTheme theme;

    setUp(() {
      theme = _TestFlexTheme();
    });

    test("exposes id and name", () {
      expect(theme.id, "test_flex");
      expect(theme.name, "Test Flex");
    });

    test("builds valid light and dark ThemeData", () {
      final ThemeVariants variants = theme.build();

      expect(variants.light, isA<ThemeData>());
      expect(variants.dark, isA<ThemeData>());
      expect(variants.light.brightness, Brightness.light);
      expect(variants.dark.brightness, Brightness.dark);
    });

    test("uses Material 3", () {
      final ThemeVariants variants = theme.build();

      expect(variants.light.useMaterial3, isTrue);
      expect(variants.dark.useMaterial3, isTrue);
    });

    test("subThemes defaults to empty FlexSubThemesData", () {
      expect(theme.subThemes, isA<FlexSubThemesData>());
    });
  });
}
