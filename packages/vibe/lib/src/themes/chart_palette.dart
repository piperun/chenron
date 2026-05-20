import 'package:flutter/material.dart';

/// Per-entity-type color palette for the statistics charts.
///
/// Attach to a theme via `ThemeData.extensions: [ChartPalette.nier]`
/// (or any custom palette) to give that theme its own coordinated
/// chart colors. Themes that don't attach a `ChartPalette` get the
/// default `ChartPalette.material` palette via the fallback inside
/// `ChartPalette.of(context)`.
///
/// Why ThemeExtension instead of just reading ColorScheme tokens:
/// Material 3 only has three semantic accent slots
/// (primary/secondary/tertiary) and they're not designed for "stable
/// per-series chart identity." A bespoke palette lets a theme like
/// Nier pull from its richer in-game color set without being
/// constrained by the M3 token system.
@immutable
class ChartPalette extends ThemeExtension<ChartPalette> {
  /// Build a palette by providing one color per entity type. Optional
  /// [tooltipShadows] control the text outline used inside chart
  /// tooltips — pass `null` to render text without any shadow (used by
  /// themes like Nier where flat typography matches the in-game look).
  const ChartPalette({
    required this.links,
    required this.documents,
    required this.folders,
    required this.tags,
    this.tooltipShadows = _defaultOutlineShadows,
  });

  /// Color used for "link" data series across the statistics charts.
  final Color links;

  /// Color used for "document" data series.
  final Color documents;

  /// Color used for "folder" data series.
  final Color folders;

  /// Color used for "tag" data series.
  final Color tags;

  /// Shadows applied to tooltip text (both header and per-series
  /// rows). `null` disables the outline entirely — useful for themes
  /// that want flat, in-palette typography. Default is a 4-direction
  /// 1px black outline so vivid series colors stay legible against
  /// the dark tooltip background.
  final List<Shadow>? tooltipShadows;

  /// 4-direction 1-pixel outline shadow. Full-pixel offsets so the
  /// outline ring stays crisp at any DPR (sub-pixel offsets render as
  /// fuzzy because of rounding).
  static const List<Shadow> _defaultOutlineShadows = <Shadow>[
    Shadow(color: Colors.black, offset: Offset(-1, -1)),
    Shadow(color: Colors.black, offset: Offset(1, -1)),
    Shadow(color: Colors.black, offset: Offset(1, 1)),
    Shadow(color: Colors.black, offset: Offset(-1, 1)),
  ];

  /// Vivid Material palette — what chenron used before themes opted
  /// in. Keeps the existing Growth Trend / Activity Timeline look
  /// for any theme that doesn't attach its own ChartPalette.
  static const ChartPalette material = ChartPalette(
    links: Colors.blue,
    documents: Colors.purple,
    folders: Colors.orange,
    tags: Colors.teal,
  );

  /// Nier: Automata YorHa-derived palette. Hex values come from the
  /// in-game color database — not the existing `NierColors.yorha`
  /// fields, which are role-named (hudRed, hudTeal) and not always a
  /// 1:1 match for the actual palette entries.
  ///
  /// Picked so that:
  /// - all four hues are distinguishable (warm-rust, warm-salmon,
  ///   warm-beige, cool-teal)
  /// - all four have luminance ≥ 0.42 so they stay readable on dark
  ///   tooltip backgrounds (the previous textBrownDarker mapping for
  ///   "documents" was dark-on-dark and unreadable)
  /// - the choices match how the game actually distributes color:
  ///   Yellow Dark Pastel is 24.5% of in-game UI pixels (dominant
  ///   beige), Amber Deep / Teal Deep are the iconic warning + accent
  ///   colors.
  static const ChartPalette nier = ChartPalette(
    links: Color(0xFFAE553F),     // Amber Deep — iconic rust accent
    documents: Color(0xFFE0AA8A), // Amber Bright Pastel — dusty salmon
    folders: Color(0xFFE3D8BB),   // Orange Light Pastel — cream-yellow
    tags: Color(0xFF32968C),      // Teal Deep — iconic teal accent
    // Nier's in-game typography is flat — no shadows or outlines.
    // The default outline ring makes the tooltip text look "thick"
    // and fights with the muted palette, so opt out.
    tooltipShadows: null,
  );

  /// Read the active palette, or fall back to `material` if the
  /// current theme hasn't attached one.
  static ChartPalette of(BuildContext context) =>
      Theme.of(context).extension<ChartPalette>() ?? ChartPalette.material;

  @override
  ChartPalette copyWith({
    Color? links,
    Color? documents,
    Color? folders,
    Color? tags,
    Object? tooltipShadows = _copyWithSentinel,
  }) =>
      ChartPalette(
        links: links ?? this.links,
        documents: documents ?? this.documents,
        folders: folders ?? this.folders,
        tags: tags ?? this.tags,
        tooltipShadows: identical(tooltipShadows, _copyWithSentinel)
            ? this.tooltipShadows
            : tooltipShadows as List<Shadow>?,
      );

  /// Sentinel so callers can pass `null` through `copyWith` to clear
  /// the outline shadows (omitting the param keeps the existing value).
  static const Object _copyWithSentinel = Object();

  @override
  ChartPalette lerp(ThemeExtension<ChartPalette>? other, double t) {
    if (other is! ChartPalette) return this;
    return ChartPalette(
      links: Color.lerp(links, other.links, t)!,
      documents: Color.lerp(documents, other.documents, t)!,
      folders: Color.lerp(folders, other.folders, t)!,
      tags: Color.lerp(tags, other.tags, t)!,
      // Shadows aren't numerically lerpable — switch at the midpoint.
      tooltipShadows: t < 0.5 ? tooltipShadows : other.tooltipShadows,
    );
  }
}
