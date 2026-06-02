import "package:chenron/features/theme/state/theme_utils.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

/// Characterization tests for [distinctSwatches] / [countDistinctHues].
///
/// These exercise the private `_isSameHue` grouping rules through the
/// public API:
///   - colors with saturation < 0.1 are treated as one "neutral" group;
///   - a colored vs neutral pair is always distinct;
///   - hue difference within a 30 degree window groups two colors;
///   - the window wraps around the 360 degree wheel (350 diff groups,
///     because 350 >= 360 - 30).
///
/// Colors are built via [HSLColor.fromAHSL] so the hue under test is
/// explicit. The 8-bit quantization of `.toColor()` shifts hues by at
/// most ~0.3 degrees here (verified empirically), well inside every
/// margin these cases rely on.
Color _hsl(double hue, {double saturation = 0.8, double lightness = 0.5}) =>
    HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();

void main() {
  group("countDistinctHues / distinctSwatches", () {
    test("identical hue collapses to a single swatch", () {
      final c = _hsl(200);
      expect(countDistinctHues(c, c, c), 1);
      expect(distinctSwatches(c, c, c), <Color>[c]);
    });

    test("single repeated color yields one swatch", () {
      // Same Color instance passed three times — the all-identical path.
      const c = Color(0xFF2196F3);
      expect(countDistinctHues(c, c, c), 1);
    });

    test("three well-separated hues stay distinct", () {
      final p = _hsl(0); // red-ish
      final s = _hsl(120); // green-ish
      final t = _hsl(240); // blue-ish
      expect(countDistinctHues(p, s, t), 3);
      expect(distinctSwatches(p, s, t), <Color>[p, s, t]);
    });

    test("hues within the 30 degree window group together", () {
      // 200 vs 215 differ by 15 (<= 30) -> same group.
      final p = _hsl(200);
      final s = _hsl(215);
      final t = _hsl(208);
      expect(countDistinctHues(p, s, t), 1);
    });

    test("wrap-around: 5 and 355 group, distinct third stays", () {
      // |5 - 355| = 350 >= (360 - 30) -> grouped as same hue.
      final p = _hsl(5);
      final s = _hsl(355);
      final t = _hsl(180);
      // primary kept; secondary grouped with primary (dropped);
      // tertiary is a fresh hue -> added.
      expect(distinctSwatches(p, s, t), <Color>[p, t]);
      expect(countDistinctHues(p, s, t), 2);
    });

    test("two near-neutral grays collapse into one neutral group", () {
      // Pure grays have saturation 0 (< 0.1) -> both neutral -> grouped.
      const g1 = Color(0xFF808080);
      const g2 = Color(0xFF909090);
      const g3 = Color(0xFF707070);
      expect(countDistinctHues(g1, g2, g3), 1);
    });

    test("low-saturation (just under 0.1) still counts as neutral", () {
      // saturation 0.05 < 0.1 threshold for all three.
      final n1 = _hsl(200, saturation: 0.05);
      final n2 = _hsl(40, saturation: 0.05);
      final n3 = _hsl(300, saturation: 0.05);
      // Despite very different hues, all are neutral -> one group.
      expect(countDistinctHues(n1, n2, n3), 1);
    });

    test("neutral primary plus a colored pair counts as two", () {
      // primary neutral (sat < 0.1); secondary/tertiary share one hue.
      const neutral = Color(0xFF808080);
      final colored = _hsl(200);
      // neutral vs colored -> distinct (added);
      // colored vs colored -> same -> tertiary dropped.
      expect(distinctSwatches(neutral, colored, colored),
          <Color>[neutral, colored]);
      expect(countDistinctHues(neutral, colored, colored), 2);
    });

    test("distinct primary/secondary, tertiary equal to secondary", () {
      // primary != secondary -> secondary added; tertiary shares
      // secondary's hue so the (result.length >= 2 && sameHue(s,t))
      // guard drops it even though it differs from primary.
      final p = _hsl(0);
      final s = _hsl(120);
      final t = _hsl(120);
      expect(distinctSwatches(p, s, t), <Color>[p, s]);
      expect(countDistinctHues(p, s, t), 2);
    });

    test("tertiary distinct from both primary and secondary is added", () {
      final p = _hsl(0);
      final s = _hsl(120);
      final t = _hsl(240);
      expect(distinctSwatches(p, s, t).length, 3);
    });

    test("primary == tertiary but secondary distinct keeps two", () {
      // primary kept; secondary distinct -> added; tertiary equals
      // primary's hue -> sameHue(p,t) true -> dropped.
      final p = _hsl(30);
      final s = _hsl(210);
      final t = _hsl(30);
      expect(distinctSwatches(p, s, t), <Color>[p, s]);
      expect(countDistinctHues(p, s, t), 2);
    });
  });
}
