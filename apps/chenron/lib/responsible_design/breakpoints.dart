import "package:flutter/widgets.dart";

/// Material 3 window size classes — the breakpoints Flutter's adaptive
/// Material components are designed around.
///
/// Derive the class from the width you care about:
/// - the **whole window** via `context.windowSizeClass`, for app-shell
///   decisions (e.g. navigation rail vs. bottom bar);
/// - the **available width** via `WindowSizeClass.fromWidth(constraints.maxWidth)`
///   inside a `LayoutBuilder`, for a component, so it adapts to the space it
///   is actually given rather than to the whole window.
enum WindowSizeClass {
  /// Under 600 px — phones in portrait.
  compact,

  /// 600–840 px — phones in landscape, small tablets.
  medium,

  /// 840–1200 px — tablets, small desktop windows.
  expanded,

  /// 1200–1600 px — desktop.
  large,

  /// 1600 px and up — large / ultrawide desktop.
  extraLarge;

  /// Lower-bound widths (logical pixels) for each Material 3 size class.
  static const double mediumMinWidth = 600;
  static const double expandedMinWidth = 840;
  static const double largeMinWidth = 1200;
  static const double extraLargeMinWidth = 1600;

  /// The size class for [width] in logical pixels.
  static WindowSizeClass fromWidth(double width) {
    if (width >= extraLargeMinWidth) return WindowSizeClass.extraLarge;
    if (width >= largeMinWidth) return WindowSizeClass.large;
    if (width >= expandedMinWidth) return WindowSizeClass.expanded;
    if (width >= mediumMinWidth) return WindowSizeClass.medium;
    return WindowSizeClass.compact;
  }

  /// Whether this class is [other] or wider.
  bool isAtLeast(WindowSizeClass other) => index >= other.index;
}

extension WindowSizeContext on BuildContext {
  /// The [WindowSizeClass] for the whole window.
  ///
  /// Use for app-shell layout decisions. For a component, prefer
  /// `WindowSizeClass.fromWidth(constraints.maxWidth)` inside a
  /// `LayoutBuilder` so it adapts to its own available width.
  WindowSizeClass get windowSizeClass =>
      WindowSizeClass.fromWidth(MediaQuery.sizeOf(this).width);
}

/// Picks the value for [sizeClass], falling back to the nearest smaller class
/// that was supplied. Only [compact] is required, so callers specify just the
/// classes where the value actually changes.
T responsiveValue<T>(
  WindowSizeClass sizeClass, {
  required T compact,
  T? medium,
  T? expanded,
  T? large,
  T? extraLarge,
}) {
  switch (sizeClass) {
    case WindowSizeClass.extraLarge:
      return extraLarge ?? large ?? expanded ?? medium ?? compact;
    case WindowSizeClass.large:
      return large ?? expanded ?? medium ?? compact;
    case WindowSizeClass.expanded:
      return expanded ?? medium ?? compact;
    case WindowSizeClass.medium:
      return medium ?? compact;
    case WindowSizeClass.compact:
      return compact;
  }
}
