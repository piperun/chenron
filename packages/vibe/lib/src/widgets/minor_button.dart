import 'package:flutter/material.dart';

import 'package:vibe/src/themes/button_tokens.dart';

/// Generic dialog-tier action button. Renders via the active theme's
/// [ButtonTokens.buildMinor], so the chrome (plate, indicator, shadow,
/// pointer) follows the theme. App code calls this; theme-specific
/// implementations live inside the theme directory.
///
/// Pair with future `SuperButton` for the menu-row tier (heavier
/// visual treatment).
class MinorButton extends StatelessWidget {
  /// Build a minor (dialog-tier) action button. The active theme's
  /// [ButtonTokens] decides the visual rendering.
  const MinorButton({
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

  /// Optional semantic glyph rendered in the leading slot. Themes that
  /// render a state-driven indicator may show it next to this icon, or
  /// in place of it — that's a theme-level decision.
  final IconData? icon;

  /// When `true`, the theme is expected to render a destructive
  /// emphasis (typically theme.colorScheme.error background).
  final bool destructive;

  /// When `true`, the theme renders the button in its active visual
  /// state regardless of hover/focus. Useful for toggle-style or
  /// radio-group selection on inline action buttons.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ButtonTokens.of(context).buildMinor(
      label: label,
      onPressed: onPressed,
      icon: icon,
      destructive: destructive,
      selected: selected,
    );
  }
}
