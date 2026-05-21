import 'package:flutter/material.dart';

/// The "minor" YorHa dialog-style choice button: a flat plate in idle
/// state, transitioning to a darker plate with a sharp offset shadow
/// on hover / focus / press / selected. A small filled square (or
/// optional semantic [icon]) sits to the left of the label and
/// recolors with the foreground, mirroring the in-game Yes / No
/// dialog pattern.
///
/// Pair name with [NierSuperButton] (future) — the heavier menu-list
/// row treatment with pointer arrow, fade-in fill, and animated border.
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

    // Indicator color tracks the button's resolved foreground. Idle
    // foreground sits on the lighter idle background (onSurface in the
    // Nier theme); active foreground sits on the dark primary plate
    // (onPrimary). The button's WidgetStateProperty for foregroundColor
    // does the same swap for the text, so the square + label stay in
    // sync visually.
    final Color indicatorColor =
        _active ? scheme.onPrimary : scheme.onSurface;
    // Destructive variant pushes the active plate to the theme's error
    // color and inverts the indicator to onError to match the text.
    final Color destructiveIndicatorColor =
        _active ? scheme.onError : scheme.onSurface;
    final Color resolvedIndicator =
        widget.destructive ? destructiveIndicatorColor : indicatorColor;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _handleFocusChange,
      child: MouseRegion(
        onEnter: (_) => _handleHoverChange(hovered: true),
        onExit: (_) => _handleHoverChange(hovered: false),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: _active
                ? <BoxShadow>[
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.25),
                      offset: const Offset(3, 3),
                    ),
                  ]
                : const <BoxShadow>[],
          ),
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
