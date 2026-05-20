import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Per-theme corner-radius tokens for the major widget categories.
///
/// Attach to a theme via `ThemeData.extensions: [ShapeTokens.nier]`
/// (or any custom token set) to override the default rounded-corner
/// look. Themes that don't attach a `ShapeTokens` fall back to
/// `ShapeTokens.material` (Material 3 defaults) via `ShapeTokens.of`.
///
/// Same pattern as `ChartPalette`: the *widget* asks the theme for
/// the value, the *theme* decides what to return. No parallel
/// widget hierarchies, no theme-specific widget classes.
@immutable
class ShapeTokens extends ThemeExtension<ShapeTokens> {
  /// Build a token set by providing one corner radius per category.
  const ShapeTokens({
    required this.cardCorner,
    required this.buttonCorner,
    required this.inputCorner,
    required this.dialogCorner,
  });

  /// Corner radius for cards and card-like panels.
  final double cardCorner;

  /// Corner radius for buttons (filled, outlined, text).
  final double buttonCorner;

  /// Corner radius for text fields, dropdowns, and other inputs.
  final double inputCorner;

  /// Corner radius for dialogs, modal sheets, and other surfaces
  /// that float above the page.
  final double dialogCorner;

  /// Material 3 default rounded shapes — what chenron used before
  /// themes opted in. Keeps the existing look for any theme that
  /// doesn't attach its own ShapeTokens.
  static const ShapeTokens material = ShapeTokens(
    cardCorner: 12,
    buttonCorner: 8,
    inputCorner: 4,
    dialogCorner: 28,
  );

  /// Nier-faithful flat shapes — all corners square, matching the
  /// in-game YorHa UI which uses hard rectangular panels everywhere.
  static const ShapeTokens nier = ShapeTokens(
    cardCorner: 0,
    buttonCorner: 0,
    inputCorner: 0,
    dialogCorner: 0,
  );

  /// Read the active token set, or fall back to `material` if the
  /// current theme hasn't attached one.
  static ShapeTokens of(BuildContext context) =>
      Theme.of(context).extension<ShapeTokens>() ?? ShapeTokens.material;

  @override
  ShapeTokens copyWith({
    double? cardCorner,
    double? buttonCorner,
    double? inputCorner,
    double? dialogCorner,
  }) =>
      ShapeTokens(
        cardCorner: cardCorner ?? this.cardCorner,
        buttonCorner: buttonCorner ?? this.buttonCorner,
        inputCorner: inputCorner ?? this.inputCorner,
        dialogCorner: dialogCorner ?? this.dialogCorner,
      );

  @override
  ShapeTokens lerp(ThemeExtension<ShapeTokens>? other, double t) {
    if (other is! ShapeTokens) return this;
    return ShapeTokens(
      cardCorner: lerpDouble(cardCorner, other.cardCorner, t)!,
      buttonCorner: lerpDouble(buttonCorner, other.buttonCorner, t)!,
      inputCorner: lerpDouble(inputCorner, other.inputCorner, t)!,
      dialogCorner: lerpDouble(dialogCorner, other.dialogCorner, t)!,
    );
  }
}
