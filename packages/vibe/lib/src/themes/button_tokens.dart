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
///
/// `selected: true` asks the theme to render the button in its
/// active visual state regardless of hover/focus — useful for
/// toggle-style or radio-group inline buttons (rare on minor tier).
typedef MinorButtonBuilder = Widget Function({
  required String label,
  required VoidCallback? onPressed,
  IconData? icon,
  bool destructive,
  bool selected,
});

/// Signature for the "super" (menu-row-tier) button renderer that
/// themes attach to [ButtonTokens.buildSuper]. Same shape as
/// [MinorButtonBuilder] so callers can swap tiers without changing
/// the call site, but the theme's `buildSuper` is expected to render
/// a heavier treatment (animated fills, decorative borders, etc.)
/// matching menu rows rather than inline action confirmations.
///
/// `selected: true` is load-bearing here — menu rows have persistent
/// selection state ("you are on the Settings → Display page"), and
/// the theme should render the active animation full-on regardless
/// of hover.
typedef SuperButtonBuilder = Widget Function({
  required String label,
  required VoidCallback? onPressed,
  IconData? icon,
  bool destructive,
  bool selected,
});

/// [ThemeExtension] that lets themes own how generic button widgets
/// render. See the file-level doc above for the full pattern.
@immutable
class ButtonTokens extends ThemeExtension<ButtonTokens> {
  /// Build a button-tokens set.
  ///
  /// [buildMinor] handles dialog-tier buttons (Yes / No / Save /
  /// Delete). [buildSuper] handles menu-row-tier buttons (settings
  /// sidebar items, primary navigation). Themes that want a uniform
  /// look can supply the same builder for both. The default
  /// [material] uses [FilledButton.icon] for minor and adds a heavier
  /// outline on super.
  const ButtonTokens({
    required this.buildMinor,
    required this.buildSuper,
  });

  /// Renderer for the "minor" button tier — dialog-style action
  /// buttons (Yes / No, Save, Delete, Cancel, ...).
  final MinorButtonBuilder buildMinor;

  /// Renderer for the "super" button tier — heavier menu-row treatment
  /// for primary navigation / settings list items.
  final SuperButtonBuilder buildSuper;

  /// Material-default tokens — used when a theme hasn't attached its
  /// own [ButtonTokens]. Minor tier renders [FilledButton.icon] (or
  /// [FilledButton] when [icon] is null) with destructive / selected
  /// emphasis. Super tier renders a Material 3-style NavigationDrawer
  /// list row (transparent idle, [ColorScheme.secondaryContainer]
  /// selected highlight) — using FilledButton here would paint every
  /// menu row as a full-saturation primary plate, which reads as
  /// visually heavy and doesn't match Material 3's nav-row idiom.
  static const ButtonTokens material = ButtonTokens(
    buildMinor: _materialMinor,
    buildSuper: _materialSuper,
  );

  /// Read the active token set, or fall back to [material] if the
  /// current theme hasn't attached one.
  static ButtonTokens of(BuildContext context) =>
      Theme.of(context).extension<ButtonTokens>() ?? ButtonTokens.material;

  @override
  ButtonTokens copyWith({
    MinorButtonBuilder? buildMinor,
    SuperButtonBuilder? buildSuper,
  }) =>
      ButtonTokens(
        buildMinor: buildMinor ?? this.buildMinor,
        buildSuper: buildSuper ?? this.buildSuper,
      );

  @override
  ButtonTokens lerp(ThemeExtension<ButtonTokens>? other, double t) {
    // Builder functions aren't numerically interpolatable — switch at
    // midpoint, same approach as FrameTokens.
    if (other is! ButtonTokens) return this;
    return t < 0.5 ? this : other;
  }
}

/// Material-3 NavigationDrawer-style row used as the default
/// [SuperButtonBuilder]. Transparent idle, [ColorScheme.secondaryContainer]
/// when [selected], subtle hover overlay via [InkWell]. Rounded 12 px
/// corners (between a flat list tile and a full pill) so it reads as
/// a list row rather than a CTA button.
Widget _materialSuper({
  required String label,
  required VoidCallback? onPressed,
  IconData? icon,
  bool destructive = false,
  bool selected = false,
}) {
  return Builder(
    builder: (BuildContext context) {
      final ColorScheme scheme = Theme.of(context).colorScheme;
      final Color bg = destructive
          ? (selected ? scheme.errorContainer : Colors.transparent)
          : (selected ? scheme.secondaryContainer : Colors.transparent);
      final Color fg = destructive
          ? (selected ? scheme.onErrorContainer : scheme.onSurface)
          : (selected ? scheme.onSecondaryContainer : scheme.onSurface);
      final BorderRadius radius = BorderRadius.circular(12);
      return Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 20, color: fg),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: fg,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _materialMinor({
  required String label,
  required VoidCallback? onPressed,
  IconData? icon,
  bool destructive = false,
  bool selected = false,
}) {
  return Builder(
    builder: (BuildContext context) {
      final ColorScheme scheme = Theme.of(context).colorScheme;
      // Material has no built-in "selected" emphasis for action
      // buttons; the closest is to flip a selected button to a
      // tonal-button-style background. Plain bg for unselected.
      final ButtonStyle? style = destructive
          ? FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            )
          : (selected
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                )
              : null);
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
