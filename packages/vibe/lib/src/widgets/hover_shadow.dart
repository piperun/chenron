import 'package:flutter/material.dart';

import 'package:vibe/src/themes/shape_tokens.dart';

/// Wraps [child] in a hard-edged offset shadow that appears only while
/// the child (or any descendant) is hovered by the pointer or has
/// keyboard focus.
///
/// This is the dialog-style YorHa button treatment from the in-game UI:
/// idle buttons sit flat with no shadow, and the currently-selected
/// button rises out of the surface with a sharp south-east offset
/// shadow — visually "stacking" the dark plate on top of its neighbors.
///
/// Pair with a `WidgetStateProperty`-driven button background that also
/// swaps colors on hover / focus to complete the stacked-plate look.
///
/// For an always-on shadow (cards, static plates), use [OffsetShadow]
/// instead.
class HoverShadow extends StatefulWidget {
  /// Build a state-aware hard-shadow wrapper around [child].
  const HoverShadow({
    super.key,
    required this.child,
    this.offset = const Offset(3, 3),
    this.color,
    this.blurRadius = 0,
    this.borderRadius,
  });

  /// The widget that drives the shadow. Usually an interactive Material
  /// widget (FilledButton, ElevatedButton, OutlinedButton).
  final Widget child;

  /// Direction the shadow is cast when active. Default `(3, 3)` —
  /// diagonal south-east, matching the in-game YorHa selection highlight.
  final Offset offset;

  /// Shadow color. `null` resolves to `Theme.of(context).colorScheme
  /// .shadow` at 25% alpha.
  final Color? color;

  /// Blur applied to the shadow. Default `0` for the hard YorHa edge.
  final double blurRadius;

  /// Corners of the shadow rectangle. `null` resolves to the active
  /// theme's `ShapeTokens.buttonCorner`.
  final BorderRadius? borderRadius;

  @override
  State<HoverShadow> createState() => _HoverShadowState();
}

class _HoverShadowState extends State<HoverShadow> {
  bool _hovered = false;
  bool _focused = false;

  bool get _active => _hovered || _focused;

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
    final BorderRadius radius = widget.borderRadius ??
        BorderRadius.circular(ShapeTokens.of(context).buttonCorner);
    final Color shadowColor =
        widget.color ?? Theme.of(context).colorScheme.shadow.withValues(alpha: 0.25);

    // Focus wraps MouseRegion so descendant focus events propagate up
    // through `hasFocus` (which is true for this node OR any descendant
    // with primary focus). `canRequestFocus: false` + `skipTraversal:
    // true` keeps this node out of the keyboard traversal order — we
    // only observe the descendant button's focus, not steal it.
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _handleFocusChange,
      child: MouseRegion(
        onEnter: (_) => _handleHoverChange(hovered: true),
        onExit: (_) => _handleHoverChange(hovered: false),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: _active
                ? <BoxShadow>[
                    BoxShadow(
                      color: shadowColor,
                      offset: widget.offset,
                      blurRadius: widget.blurRadius,
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
