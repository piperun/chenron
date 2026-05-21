import 'package:flutter/material.dart';

/// Per-theme page-frame decoration.
///
/// Attach via `ThemeData.extensions: [FrameTokens.nier]` to wrap every
/// page with a theme-specific frame (e.g. Nier's dotted top/bottom
/// bands matching the in-game HUD edges). Themes that don't attach a
/// `FrameTokens` get a passthrough wrapper.
///
/// Same pattern as the other token extensions: the *app* asks the
/// theme to wrap its child, the *theme* decides how. The wrap function
/// is invoked from `MaterialApp.builder` so every page gets the
/// treatment without per-page code.
@immutable
class FrameTokens extends ThemeExtension<FrameTokens> {
  /// Build a frame-tokens set.
  ///
  /// [wrap] receives the active page widget and returns a wrapped
  /// widget — typically wrapping with decorative top/bottom bands or
  /// background patterns. Null means "no wrap" (default themes).
  const FrameTokens({this.wrap});

  /// Optional function that wraps the active page widget. The page
  /// child is the [MaterialApp.builder]'s `child` argument — the
  /// active route's rendered tree.
  final Widget Function(Widget child)? wrap;

  /// Material default — no decorative frame.
  static const FrameTokens material = FrameTokens();

  /// Read the active token set, or fall back to `material` if the
  /// current theme hasn't attached one.
  static FrameTokens of(BuildContext context) =>
      Theme.of(context).extension<FrameTokens>() ?? FrameTokens.material;

  /// Apply [wrap] to [child] if the active theme provides one,
  /// otherwise pass [child] through unchanged. Convenience helper for
  /// `MaterialApp.builder` so it doesn't have to null-check on its own.
  static Widget wrapIfNeeded(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();
    final Widget Function(Widget)? fn = FrameTokens.of(context).wrap;
    return fn == null ? child : fn(child);
  }

  @override
  FrameTokens copyWith({Widget Function(Widget child)? wrap}) =>
      FrameTokens(wrap: wrap ?? this.wrap);

  @override
  FrameTokens lerp(ThemeExtension<FrameTokens>? other, double t) {
    // Frame wrap functions aren't numerically interpolatable — switch
    // at midpoint, same as the bool fields on TypographyTokens.
    if (other is! FrameTokens) return this;
    return t < 0.5 ? this : other;
  }
}
