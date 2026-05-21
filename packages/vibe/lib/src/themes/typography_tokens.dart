import 'package:flutter/material.dart';

/// Per-theme typography tokens for "chrome" text — section headers,
/// rail labels, tab labels, and other UI signposts (not body content).
///
/// Attach via `ThemeData.extensions: [TypographyTokens.nier]` to
/// switch chrome typography to the in-game YorHa style (tracked
/// caps). Themes that don't attach a `TypographyTokens` fall back to
/// `TypographyTokens.material` (Material 3 defaults) via
/// `TypographyTokens.of`.
///
/// Same pattern as `ChartPalette` and `ShapeTokens`: the *widget*
/// asks the theme for the value, the *theme* decides what to return.
///
/// Only applies to widgets that opt in by consulting the tokens —
/// body text, content titles, dialog content, etc. stay untouched
/// because forcing them through this pipeline would also caps-up
/// content the user wrote (e.g. bookmark titles), which is wrong.
@immutable
class TypographyTokens extends ThemeExtension<TypographyTokens> {
  /// Build a token set.
  const TypographyTokens({
    required this.headerLetterSpacing,
    required this.headerUppercase,
  });

  /// Letter-spacing applied to chrome header text. Material 3
  /// defaults to 0 (or per-style values from textTheme); Nier
  /// uses ~2.0 to match the in-game "SETTINGS / ITEMS / MAP"
  /// tracking.
  final double headerLetterSpacing;

  /// Whether chrome header text should be displayed in upper case.
  /// True for Nier (all signpost text is caps in-game); false for
  /// Material themes (default sentence-case).
  final bool headerUppercase;

  /// Material 3 default — what chenron used before themes opted in.
  /// Keeps any theme that doesn't attach a TypographyTokens looking
  /// exactly like it always has.
  static const TypographyTokens material = TypographyTokens(
    headerLetterSpacing: 0,
    headerUppercase: false,
  );

  /// Nier-faithful chrome typography — all-caps + ~2px tracking on
  /// header text, matching the YorHa UI's signpost style.
  static const TypographyTokens nier = TypographyTokens(
    headerLetterSpacing: 2,
    headerUppercase: true,
  );

  /// Read the active token set, or fall back to `material` if the
  /// current theme hasn't attached one.
  static TypographyTokens of(BuildContext context) =>
      Theme.of(context).extension<TypographyTokens>() ??
      TypographyTokens.material;

  /// Apply [headerUppercase] to [text].
  String formatHeader(String text) =>
      headerUppercase ? text.toUpperCase() : text;

  @override
  TypographyTokens copyWith({
    double? headerLetterSpacing,
    bool? headerUppercase,
  }) =>
      TypographyTokens(
        headerLetterSpacing:
            headerLetterSpacing ?? this.headerLetterSpacing,
        headerUppercase: headerUppercase ?? this.headerUppercase,
      );

  @override
  TypographyTokens lerp(ThemeExtension<TypographyTokens>? other, double t) {
    if (other is! TypographyTokens) return this;
    return TypographyTokens(
      headerLetterSpacing:
          headerLetterSpacing + (other.headerLetterSpacing - headerLetterSpacing) * t,
      // Boolean has no meaningful in-between; switch at midpoint.
      headerUppercase: t < 0.5 ? headerUppercase : other.headerUppercase,
    );
  }
}
