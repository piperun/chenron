import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:vibe/src/themes/nier/palette.dart';
import 'package:vibe/src/themes/nier/pointer.dart';

/// The "super" YorHa menu-row choice button: a heavier treatment
/// than [NierMinorButton] for primary navigation / settings rows.
/// Pointer arrow on the left, animated fade-in fill from left-to-right
/// on hover, and animated top + bottom border thickening.
///
/// Adapted from MIT-licensed `automato_theme`'s `AutomatoButton`
/// (https://github.com/Vluurie/automato_theme), simplified to drop
/// the Riverpod / hooks dependencies and the long-tail customization
/// flags. Visuals are driven by the Nier palette directly so the
/// look stays anchored to YorHa colors regardless of theme blending.
class NierSuperButton extends StatefulWidget {
  /// Build a Nier menu-row choice button.
  const NierSuperButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
    this.selected = false,
  });

  /// Button text.
  final String label;

  /// Tap callback. `null` disables the button (no hover animation,
  /// pointer stays hidden).
  final VoidCallback? onPressed;

  /// Optional semantic glyph rendered to the left of the label, inside
  /// the plate. When `null` no leading widget is shown (the YorHa
  /// pointer outside the plate still appears on active).
  final IconData? icon;

  /// When `true`, the active fill uses the Nier `hudRed` accent so
  /// destructive menu actions read with red emphasis.
  final bool destructive;

  /// When `true`, the row is rendered in its persistent active state
  /// (pointer visible, fill animation completed, borders thickened)
  /// regardless of hover/focus. This is the "you are on this page"
  /// indicator for navigation rows.
  final bool selected;

  @override
  State<NierSuperButton> createState() => _NierSuperButtonState();
}

class _NierSuperButtonState extends State<NierSuperButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curved;
  bool _hovered = false;
  bool _focused = false;

  /// Gap between the pointer slot and the plate.
  static const double _pointerGap = 14;

  /// Minimum plate width even on very narrow parents — protects
  /// against the row collapsing into something illegible.
  static const double _minPlateWidth = 120;

  /// Plate width used when the parent provides unbounded width
  /// (rare — only outside Rows / fixed-width containers).
  static const double _defaultPlateWidth = 240;

  /// Plate height — matches the in-game menu-row proportions; tall
  /// enough for the border thickening to read as decorative.
  static const double _plateHeight = 40;

  bool get _interactive => widget.onPressed != null;
  bool get _active =>
      widget.selected || (_interactive && (_hovered || _focused));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      // Start at 1.0 when the row mounts already-selected so the
      // active visual is in place on first paint, not animating in.
      value: widget.selected ? 1.0 : 0.0,
    );
    _curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(NierSuperButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the selected flag flips externally (e.g. the user picks a
    // different settings tab), sync the animation without waiting for
    // a hover/focus event.
    if (widget.selected != oldWidget.selected) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (_active) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleHoverChange({required bool hovered}) {
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
    _syncAnimation();
  }

  void _handleFocusChange(bool focused) {
    if (_focused == focused) return;
    setState(() => _focused = focused);
    _syncAnimation();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    // YorHa palette values pinned here rather than via colorScheme so
    // the menu-row look stays consistent across light/dark variants
    // (the in-game animation reads as the same regardless of bg).
    final Color idleColor = dark
        ? NierColors.yorha.canvasBeige
        : NierColors.yorha.textBrownGrey;
    final Color activeFgColor = dark
        ? NierColors.yorha.textBrownGrey
        : NierColors.yorha.canvasBeige;
    // Solid YorHa grey for the idle plate (matches the in-game UI
    // where unselected menu rows render as a flat beige tile, not a
    // washed-out tint of the page bg).
    final Color baseFillColor = NierColors.yorha.dominantBeige;
    final Color animatedFillColor = widget.destructive
        ? NierColors.yorha.hudRed
        : (dark
            ? NierColors.yorha.canvasBeige
            : NierColors.yorha.textBrownGrey);

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _handleFocusChange,
      child: MouseRegion(
        onEnter: (_) => _handleHoverChange(hovered: true),
        onExit: (_) => _handleHoverChange(hovered: false),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Plate fills the parent if bounded (so menu rows in a
            // 280 px rail span the rail width minus pointer chrome),
            // and falls back to the in-game default when unbounded.
            final double plateWidth = constraints.hasBoundedWidth
                ? (constraints.maxWidth -
                        NierPointer.width -
                        _pointerGap)
                    .clamp(_minPlateWidth, double.infinity)
                : _defaultPlateWidth;
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Pointer slot — always reserved so the row doesn't
                // jump width when the hover state changes.
                SizedBox(
                  width: NierPointer.width,
                  height: NierPointer.height,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 80),
                    opacity: _active ? 1.0 : 0.0,
                    child: NierPointer(color: animatedFillColor),
                  ),
                ),
                const SizedBox(width: _pointerGap),
                // Plate — animated fill from left-to-right + thickening
                // top/bottom borders + label/icon recoloring.
                AnimatedBuilder(
                  animation: _curved,
                  builder: (BuildContext context, Widget? child) {
                    final double progress = _curved.value;
                    final Color fgColor = Color.lerp(
                      idleColor,
                      activeFgColor,
                      progress,
                    )!;
                    // Borders only appear once the row is hovered or
                    // selected — width grows 0 → 3 and the color alpha
                    // fades 0 → 1 with the same curve, so at idle
                    // they are truly invisible. (BorderSide width 0
                    // alone would still paint a 1 px hairline; pinning
                    // alpha to progress kills that.) Color tracks the
                    // active foreground (cream on light theme, dark
                    // brown on dark theme) so the stripes contrast
                    // against the dark active plate when visible.
                    final double borderWidth = lerpDouble(0, 2.5, progress)!;
                    final Color borderColor =
                        activeFgColor.withValues(alpha: progress);
                    return SizedBox(
                      width: plateWidth,
                      height: _plateHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: baseFillColor),
                        child: Stack(
                          children: <Widget>[
                            // Fill: clipped Align with widthFactor tied
                            // to the animation. Sweeps left → right as
                            // we hover, retracts right → left on
                            // unhover.
                            ClipRect(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(color: animatedFillColor),
                              ),
                            ),
                            // Top + bottom borders only (no left/right)
                            // — the YorHa menu-row signature stripe.
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  // 2 px gap between the cream stripe
                                  // and the plate edge — matches
                                  // automato_theme's scaled margin
                                  // (3 * scale at ~0.67 plate scale).
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: borderColor,
                                        width: borderWidth,
                                      ),
                                      bottom: BorderSide(
                                        color: borderColor,
                                        width: borderWidth,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Tap surface + label.
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.onPressed,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        if (widget.icon != null) ...<Widget>[
                                          Icon(
                                            widget.icon,
                                            size: 18,
                                            color: fgColor,
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                        Flexible(
                                          child: Text(
                                            widget.label,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: fgColor,
                                              fontSize: 18,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
