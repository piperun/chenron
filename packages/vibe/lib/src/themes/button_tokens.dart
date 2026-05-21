import 'package:flutter/material.dart';

/// Per-theme button rendering hooks.
///
/// Lets each theme own the visual chrome of common button tiers
/// without forcing consumers to know which theme is active. App code
/// uses the generic [MinorButton] widget (and future siblings); this
/// extension dispatches to the active theme's builder so swapping
/// themes never requires touching app-level call sites.
///
/// Same shape as [FrameTokens] — the canonical precedent for
/// builder-function-via-ThemeExtension in this package.
///
/// Themes that don't opt in fall back to [ButtonTokens.material]
/// which renders a standard Material [FilledButton] (with .icon
/// variant when [icon] is supplied) — sensible Material default with
/// no Nier flavour leaking in.
/// Signature for the "minor" (dialog-tier) button renderer that
/// themes attach to [ButtonTokens.buildMinor].
typedef MinorButtonBuilder = Widget Function({
  required String label,
  required VoidCallback? onPressed,
  IconData? icon,
  bool destructive,
});

/// [ThemeExtension] that lets themes own how generic button widgets
/// render. See the file-level doc above for the full pattern.
@immutable
class ButtonTokens extends ThemeExtension<ButtonTokens> {
  /// Build a button-tokens set.
  ///
  /// [buildMinor] receives the props for a minor (dialog-tier) button
  /// and must return the rendered widget. The Nier theme returns its
  /// `NierMinorButton`; the [material] default returns a plain
  /// [FilledButton.icon].
  const ButtonTokens({required this.buildMinor});

  /// Renderer for the "minor" button tier — dialog-style action
  /// buttons (Yes / No, Save, Delete, Cancel, ...). Pair with future
  /// `buildSuper` for the menu-row tier.
  final MinorButtonBuilder buildMinor;

  /// Material-default tokens — used when a theme hasn't attached its
  /// own [ButtonTokens]. Renders [FilledButton.icon] (or [FilledButton]
  /// when [icon] is null), with the theme's error color for
  /// `destructive: true`.
  static const ButtonTokens material = ButtonTokens(buildMinor: _materialMinor);

  /// Read the active token set, or fall back to [material] if the
  /// current theme hasn't attached one.
  static ButtonTokens of(BuildContext context) =>
      Theme.of(context).extension<ButtonTokens>() ?? ButtonTokens.material;

  @override
  ButtonTokens copyWith({MinorButtonBuilder? buildMinor}) =>
      ButtonTokens(buildMinor: buildMinor ?? this.buildMinor);

  @override
  ButtonTokens lerp(ThemeExtension<ButtonTokens>? other, double t) {
    // Builder functions aren't numerically interpolatable — switch at
    // midpoint, same approach as FrameTokens.
    if (other is! ButtonTokens) return this;
    return t < 0.5 ? this : other;
  }
}

Widget _materialMinor({
  required String label,
  required VoidCallback? onPressed,
  IconData? icon,
  bool destructive = false,
}) {
  return Builder(
    builder: (BuildContext context) {
      final ColorScheme scheme = Theme.of(context).colorScheme;
      final ButtonStyle? style = destructive
          ? FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            )
          : null;
      if (icon != null) {
        return FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: style,
        );
      }
      return FilledButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    },
  );
}
