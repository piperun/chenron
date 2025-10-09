import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/locator.dart";
import "package:chenron/features/theme/state/theme_manager.dart";

/// A toggle button that switches between light and dark theme modes.
///
/// Connects to [ThemeManager] via the locator to read and update theme mode.
class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = locator.get<ThemeManager>();

    return Watch((context) {
      final currentMode = themeManager.themeModeSignal.value;
      final isDark = currentMode == ThemeMode.dark;

      return IconButton(
        tooltip: isDark ? "Switch to light mode" : "Switch to dark mode",
        icon: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        ),
        onPressed: () {
          themeManager.setDarkMode(isDark: !isDark);
        },
      );
    });
  }
}
