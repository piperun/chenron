import 'package:flutter/material.dart';

/// Semantic color palette for vibe themes.
///
/// **Tier 2 (compact):** provide the 6 required colors.
/// **Tier 3 (full):** additionally provide any of the 4 optional colors
/// to override FlexColorScheme derivation.
///
/// ```dart
/// // Tier 2 — compact (6 required)
/// VibePalette(
///   canvas: Color(0xFFFFFFFF),
///   surface: Color(0xFFF5F5F5),
///   content: Color(0xFF212121),
///   accent: Color(0xFF1976D2),
///   outline: Color(0xFFBDBDBD),
///   error: Color(0xFFD32F2F),
/// );
///
/// // Tier 3 — full (6 required + 4 optional)
/// VibePalette(
///   canvas: Color(0xFFFFFFFF),
///   surface: Color(0xFFF5F5F5),
///   content: Color(0xFF212121),
///   accent: Color(0xFF1976D2),
///   outline: Color(0xFFBDBDBD),
///   error: Color(0xFFD32F2F),
///   contentDim: Color(0xFF757575),
///   onAccent: Color(0xFFFFFFFF),
///   accentAlt: Color(0xFF388E3C),
///   surfaceVariant: Color(0xFFEEEEEE),
/// );
/// ```
class VibePalette {
  /// Creates a [VibePalette].
  ///
  /// The six required colors define the minimum semantic palette.
  /// Optional colors override derived values when provided.
  const VibePalette({
    required this.canvas,
    required this.surface,
    required this.content,
    required this.accent,
    required this.outline,
    required this.error,
    this.contentDim,
    this.onAccent,
    this.accentAlt,
    this.surfaceVariant,
  });

  // -- Required (Tier 2) --

  /// Background fill for the entire scaffold / page.
  final Color canvas;

  /// Elevated surface color (cards, dialogs, sheets).
  final Color surface;

  /// Primary text and icon color on canvas and surface.
  final Color content;

  /// Interactive brand color (buttons, links, FAB).
  final Color accent;

  /// Border, divider, and subtle accent color.
  final Color outline;

  /// Destructive / error state color.
  final Color error;

  // -- Optional (Tier 3) --

  /// Dimmed text/icon color for captions, hints, placeholders.
  /// Derived from [content] by FlexColorScheme when null.
  final Color? contentDim;

  /// Color for text/icons placed on [accent] backgrounds.
  /// Derived from [accent] by FlexColorScheme when null.
  final Color? onAccent;

  /// Alternative accent for secondary interactive elements (chips, FABs).
  /// Derived from [accent] by FlexColorScheme when null.
  final Color? accentAlt;

  /// Variant surface for containers, selected states, etc.
  /// Derived from [surface] by FlexColorScheme when null.
  final Color? surfaceVariant;
}
