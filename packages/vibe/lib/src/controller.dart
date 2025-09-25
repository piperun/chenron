import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:vibe/src/types.dart';

/// Reactive controller for theme selection and mode.
class ThemeController {
  /// The preferred theme mode.
  final Signal<ThemeMode> themeModeSignal = Signal<ThemeMode>(ThemeMode.system);

  /// The current theme pair (light/dark).
  final Signal<ThemeVariants> currentThemeSignal = Signal<ThemeVariants>(
    (
      light: ThemeData.fallback(),
      dark: ThemeData.fallback(),
    ),
  );

  /// Applies a [ThemeVariants] pair as current theme.
  void setTheme(ThemeVariants variants) {
    currentThemeSignal.value = variants;
  }

  /// Updates the [ThemeMode].
  void setMode(ThemeMode mode) {
    themeModeSignal.value = mode;
  }
}
