import 'package:flutter/material.dart';

import 'package:vibe/src/themes/shape_tokens.dart';

/// Wraps [child] in a [DecoratedBox] that casts a single hard-edged
/// offset shadow behind it.
///
/// This is the composition wrapper escape hatch for Nier's signature
/// "raised plate" look. Material's `elevation` always produces a
/// blurred shadow (`Canvas.drawShadow` is hardcoded to blur);
/// `BoxShadow` on a [DecoratedBox] / [BoxDecoration] doesn't have
/// that limitation — set [blurRadius] to 0 and you get a perfectly
/// sharp shadow.
///
/// Used by wrapping a Material widget at the call site:
///
/// ```dart
/// OffsetShadow(
///   child: FilledButton(onPressed: ..., child: Text('Add New')),
/// )
/// ```
///
/// Defaults are sensible Nier-style values (3px down-right, 0 blur,
/// theme `shadow` color at 25% alpha). Override per-instance for
/// special cases.
class OffsetShadow extends StatelessWidget {
  /// Build a hard-shadow wrapper around [child].
  const OffsetShadow({
    super.key,
    required this.child,
    this.offset = const Offset(3, 3),
    this.color,
    this.blurRadius = 0,
    this.borderRadius,
  });

  /// The widget to receive the shadow. Usually a Material button,
  /// card, or any other interactive element where you want the
  /// in-game "raised plate" effect.
  final Widget child;

  /// Direction the shadow is cast. Default is `(3, 3)` — diagonal
  /// south-east, matching the in-game YorHa HUD button highlight.
  final Offset offset;

  /// Shadow color. `null` resolves to `Theme.of(context).colorScheme
  /// .shadow` at 25% alpha — a themed default that adapts to light /
  /// dark variants without per-call configuration.
  final Color? color;

  /// Blur applied to the shadow. Default `0` gives a hard pixel-sharp
  /// edge (the Nier in-game style). Bump this for a soft-edged
  /// shadow if you want Material-like elevation feel.
  final double blurRadius;

  /// Corners of the shadow rectangle. `null` resolves to the active
  /// theme's `ShapeTokens.buttonCorner` so the shadow follows the
  /// same shape language as the wrapped widget without callers
  /// having to specify it.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = borderRadius ??
        BorderRadius.circular(ShapeTokens.of(context).buttonCorner);
    final Color shadowColor =
        color ?? Theme.of(context).colorScheme.shadow.withValues(alpha: 0.25);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadowColor,
            offset: offset,
            blurRadius: blurRadius,
          ),
        ],
      ),
      child: child,
    );
  }
}
