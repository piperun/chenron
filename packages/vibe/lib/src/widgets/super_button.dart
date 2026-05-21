import 'package:flutter/material.dart';

import 'package:vibe/src/themes/button_tokens.dart';

/// Generic menu-row-tier action button. Renders via the active theme's
/// [ButtonTokens.buildSuper], so the chrome (fill animation, border
/// thickening, pointer) follows the theme. App code calls this; the
/// theme-specific implementation lives inside the theme directory.
///
/// Sibling of [MinorButton] — same call-site API, heavier visual
/// treatment. Pick based on the role: dialog action = minor, primary
/// menu row = super.
class SuperButton extends StatelessWidget {
  /// Build a super (menu-row-tier) action button. The active theme's
  /// [ButtonTokens] decides the visual rendering.
  const SuperButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
    this.selected = false,
  });

  /// Button text.
  final String label;

  /// Tap callback. `null` disables the button.
  final VoidCallback? onPressed;

  /// Optional semantic glyph. Themes that render a state-driven
  /// indicator may show it next to this icon, or in place of it.
  final IconData? icon;

  /// When `true`, the theme is expected to render a destructive
  /// emphasis (typically theme.colorScheme.error background).
  final bool destructive;

  /// When `true`, the theme renders the menu-row in its persistent
  /// active state — pointer visible, fill animation completed,
  /// borders thickened — regardless of hover/focus. This is the
  /// "you are on this page" indicator for navigation rows.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ButtonTokens.of(context).buildSuper(
      label: label,
      onPressed: onPressed,
      icon: icon,
      destructive: destructive,
      selected: selected,
    );
  }
}
