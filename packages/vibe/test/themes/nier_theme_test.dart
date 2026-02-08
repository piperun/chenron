import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:vibe/vibe.dart";

void main() {
  group("NierTheme", () {
    late NierTheme theme;
    late ThemeVariants variants;

    setUp(() {
      theme = NierTheme();
      variants = theme.build();
    });

    test("has correct id and name", () {
      expect(theme.id, "nier");
      expect(theme.name, "Nier: Automata");
    });

    test("builds valid light and dark ThemeData", () {
      expect(variants.light, isA<ThemeData>());
      expect(variants.dark, isA<ThemeData>());
    });

    // -- Light mode: primary = interactive brown, backgrounds = beige --

    test("light primary is interactive brown", () {
      expect(
        variants.light.colorScheme.primary,
        NierColors.yorha.textBrownGrey,
      );
    });

    test("light surface is canvasBeige", () {
      expect(
        variants.light.colorScheme.surface,
        NierColors.yorha.canvasBeige,
      );
    });

    test("light scaffold background is canvasBeige", () {
      expect(
        variants.light.scaffoldBackgroundColor,
        NierColors.yorha.canvasBeige,
      );
    });

    test("light cardColor is surfaceOffWhite", () {
      expect(variants.light.cardColor, NierColors.yorha.surfaceOffWhite);
      expect(variants.light.cardTheme.color, NierColors.yorha.surfaceOffWhite);
    });

    // -- Dark mode: primary = interactive beige, backgrounds = brown --

    test("dark primary is interactive beige", () {
      expect(
        variants.dark.colorScheme.primary,
        NierColors.yorha.canvasBeige,
      );
    });

    test("dark surface is textBrownGrey", () {
      expect(
        variants.dark.colorScheme.surface,
        NierColors.yorha.textBrownGrey,
      );
    });

    test("dark scaffold background is textBrownGrey", () {
      expect(
        variants.dark.scaffoldBackgroundColor,
        NierColors.yorha.textBrownGrey,
      );
    });

    test("dark cardColor is textBrownDarker", () {
      expect(variants.dark.cardColor, NierColors.yorha.textBrownDarker);
      expect(variants.dark.cardTheme.color, NierColors.yorha.textBrownDarker);
    });

    test("dark dialog background is textBrownDarker", () {
      expect(
        variants.dark.dialogTheme.backgroundColor,
        NierColors.yorha.textBrownDarker,
      );
    });

    test("can register in VibeRegistry", () {
      final registry = VibeRegistry();
      registry.register(theme);

      expect(registry.get("nier"), same(theme));
      expect(registry.contains("nier"), isTrue);
    });
  });
}
