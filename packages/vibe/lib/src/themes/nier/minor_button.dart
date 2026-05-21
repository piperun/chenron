import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:vibe/src/themes/shape_tokens.dart';

/// The "minor" YorHa dialog-style choice button: a flat plate in idle
/// state, transitioning to a darker plate with a sharp offset shadow
/// on hover / focus / press / selected. A small filled square (or
/// optional semantic [icon]) sits to the left of the label and
/// recolors with the foreground; the in-game selection arrow fades
/// in to the left of the whole button when active.
///
/// Pair name with [NierSuperButton] (future) — the heavier menu-list
/// row treatment with fade-in fill, and animated border.
/// "Minor" here means "inline action confirmation", not "less important".
///
/// Wraps a Material [FilledButton] internally, so ripple, focus
/// traversal, accessibility, and disabled state all behave exactly as
/// a standard Material button — only the visual chrome is overridden.
class NierMinorButton extends StatefulWidget {
  /// Build a Nier dialog-style choice button.
  ///
  /// When [icon] is `null` the leading slot is filled by the
  /// state-coloured YorHa indicator square. Pass an [IconData] to
  /// replace the square with a semantic glyph (Save, Add, Restart)
  /// while keeping the same hover / focus / shadow behaviour.
  const NierMinorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
  });

  /// Button text. Drawn after the leading indicator / icon.
  final String label;

  /// Tap callback. `null` disables the button (still mounted, still
  /// occupies layout, but doesn't react to input and skips the
  /// hover / focus visuals).
  final VoidCallback? onPressed;

  /// Optional semantic glyph rendered in the leading slot. When `null`
  /// the YorHa filled-square indicator is used instead.
  final IconData? icon;

  /// When `true`, the active plate uses the theme's error color so
  /// destructive confirmations (Delete, Clear) read as red rather than
  /// neutral brown. Idle plate stays neutral either way.
  final bool destructive;

  @override
  State<NierMinorButton> createState() => _NierMinorButtonState();
}

class _NierMinorButtonState extends State<NierMinorButton> {
  bool _hovered = false;
  bool _focused = false;

  bool get _interactive => widget.onPressed != null;
  bool get _active => _interactive && (_hovered || _focused);

  void _handleHoverChange({required bool hovered}) {
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
  }

  void _handleFocusChange(bool focused) {
    if (_focused == focused) return;
    setState(() => _focused = focused);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    // Indicator color (the square / icon INSIDE the button) tracks
    // the button's resolved foreground — idle = onSurface (dark on
    // light plate), active = onPrimary (cream on dark plate). Matches
    // the button's text color so the indicator and label stay in
    // sync. Destructive: onError when active, onSurface when idle.
    final Color indicatorColor =
        _active ? scheme.onPrimary : scheme.onSurface;
    final Color destructiveIndicatorColor =
        _active ? scheme.onError : scheme.onSurface;
    final Color resolvedIndicator =
        widget.destructive ? destructiveIndicatorColor : indicatorColor;

    // Pointer color (the YorHa arrow OUTSIDE the button) uses the
    // active plate's *background* — primary (dark brown / cream
    // depending on light/dark) or error for destructive. The pointer
    // visually shares identity with the dark plate it points to,
    // matching the in-game art where the arrow is the same hue as
    // the selected button.
    final Color pointerColor =
        widget.destructive ? scheme.error : scheme.primary;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _handleFocusChange,
      child: MouseRegion(
        onEnter: (_) => _handleHoverChange(hovered: true),
        onExit: (_) => _handleHoverChange(hovered: false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Pointer slot — always reserved so the button doesn't
            // jump width when hover state changes. The SVG itself
            // fades in only when active, matching the in-game
            // selection arrow that appears next to the highlighted
            // dialog option.
            SizedBox(
              width: _NierPointer.width,
              height: _NierPointer.height,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 80),
                opacity: _active ? 1.0 : 0.0,
                // Pointer uses the active plate's bg color (primary /
                // error) — same hue as the dark button it points to,
                // matching the in-game art.
                child: _NierPointer(color: pointerColor),
              ),
            ),
            const SizedBox(width: 14),
            // Shadow sits at the box's exact position with zero offset
            // — i.e. equal size and location as the idle (grey) button.
            // It becomes visible when the active button translates
            // up-left, leaving the south-east strip of the shadow
            // uncovered. Same size in both states, same shadow
            // footprint as the grey button.
            //
            // borderRadius follows ShapeTokens.buttonCorner so the
            // shadow matches the underlying FilledButton's shape in
            // any theme (Nier = 0, Material = rounded).
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ShapeTokens.of(context).buttonCorner,
                ),
                boxShadow: _active
                    ? <BoxShadow>[
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.25),
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 80),
                // Fractional offset relative to the child's size.
                // ~3 % up and ~10 % left of the idle footprint reads
                // as a clear raise without dislocating the label too
                // far. Scales proportionally to button size so wide
                // rail buttons and compact dialog buttons both feel
                // right.
                offset: _active
                    ? const Offset(-0.025, -0.10)
                    : Offset.zero,
                child: FilledButton(
                  onPressed: widget.onPressed,
                  style: widget.destructive
                      ? FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError,
                        )
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (widget.icon != null)
                        Icon(widget.icon, size: 18, color: resolvedIndicator)
                      else
                        _IndicatorSquare(color: resolvedIndicator),
                      const SizedBox(width: 10),
                      Text(widget.label),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small filled square next to the label that recolors with the
/// button's foreground — dark on the idle (lighter) plate, cream on
/// the active (dark) plate. 16 px is roughly the visual weight of the
/// label's cap-height at default `FilledButton` font size, matching
/// the in-game proportions where the indicator reads as a typographic
/// peer of the label rather than an oversized chip.
class _IndicatorSquare extends StatelessWidget {
  const _IndicatorSquare({required this.color});

  final Color color;

  static const double _size = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: ColoredBox(color: color),
    );
  }
}

/// The YorHa selection-arrow pointer that sits to the left of the
/// currently-highlighted dialog option. SVG ported verbatim from
/// MIT-licensed `automato_theme`'s `automatoSvgStrPointer`
/// (https://github.com/Vluurie/automato_theme), embedded inline so no
/// asset wiring is required. Recoloured via [ColorFilter] so the
/// hardcoded `#48463d` fill inside the SVG follows the active theme's
/// foreground tone.
class _NierPointer extends StatelessWidget {
  const _NierPointer({required this.color});

  /// Reserved layout width for the pointer slot. Matches
  /// `ThemeDimensions.pointerSvgWidth` (32) from `automato_theme`.
  static const double width = 32;

  /// Layout height derived from the SVG's native aspect ratio
  /// (367.705 × 234.894 ≈ 1.565 : 1). Pre-computed rather than letting
  /// `BoxFit.contain` figure it out so callers can lay the slot out
  /// against a known constant.
  static const double height = 20;

  final Color color;

  static const String _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="367.705" height="234.894" viewBox="0 0 367.705 234.894">
  <path fill="black" d="M0,117.447l90.7,90.7,272.151-90.7L90.7,26.747Zm105.983,0a17.3,17.3,0,1,1-17.3-17.3A17.3,17.3,0,0,1,105.983,117.447Z"/>
  <rect fill="black" x="340.658" y="207.848" width="27.046" height="27.046" transform="translate(132.81 575.553) rotate(-90)"/>
  <rect fill="black" x="340.658" width="27.046" height="27.046" transform="translate(340.658 367.705) rotate(-90)"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      fit: BoxFit.contain,
    );
  }
}
