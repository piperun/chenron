import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:vibe/vibe.dart";

void main() {
  group("VibePalette", () {
    test("constructs with only required colors", () {
      const VibePalette palette = VibePalette(
        canvas: Color(0xFFFFFFFF),
        surface: Color(0xFFF5F5F5),
        content: Color(0xFF212121),
        accent: Color(0xFF1976D2),
        outline: Color(0xFFBDBDBD),
        error: Color(0xFFD32F2F),
      );

      expect(palette.canvas, const Color(0xFFFFFFFF));
      expect(palette.surface, const Color(0xFFF5F5F5));
      expect(palette.content, const Color(0xFF212121));
      expect(palette.accent, const Color(0xFF1976D2));
      expect(palette.outline, const Color(0xFFBDBDBD));
      expect(palette.error, const Color(0xFFD32F2F));
    });

    test("optional fields default to null", () {
      const VibePalette palette = VibePalette(
        canvas: Color(0xFFFFFFFF),
        surface: Color(0xFFF5F5F5),
        content: Color(0xFF212121),
        accent: Color(0xFF1976D2),
        outline: Color(0xFFBDBDBD),
        error: Color(0xFFD32F2F),
      );

      expect(palette.contentDim, isNull);
      expect(palette.onAccent, isNull);
      expect(palette.accentAlt, isNull);
      expect(palette.surfaceVariant, isNull);
    });

    test("constructs with all 10 colors", () {
      const VibePalette palette = VibePalette(
        canvas: Color(0xFFFFFFFF),
        surface: Color(0xFFF5F5F5),
        content: Color(0xFF212121),
        accent: Color(0xFF1976D2),
        outline: Color(0xFFBDBDBD),
        error: Color(0xFFD32F2F),
        contentDim: Color(0xFF757575),
        onAccent: Color(0xFFFFFFFF),
        accentAlt: Color(0xFF388E3C),
        surfaceVariant: Color(0xFFEEEEEE),
      );

      expect(palette.contentDim, const Color(0xFF757575));
      expect(palette.onAccent, const Color(0xFFFFFFFF));
      expect(palette.accentAlt, const Color(0xFF388E3C));
      expect(palette.surfaceVariant, const Color(0xFFEEEEEE));
    });
  });
}
