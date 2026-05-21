import "dart:async";

import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

import "package:chenron/features/theme/state/theme_manager.dart";
import "package:chenron/locator.dart";

/// Switch tile bound to [ThemeManager.themeModeSignal]. Reads the
/// current brightness and writes through [ThemeManager.setDarkMode].
class DarkModeSwitch extends StatelessWidget {
  const DarkModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeManager manager = locator.get<ThemeManager>();

    return Watch((BuildContext context) {
      final ThemeMode? mode = manager.themeModeSignal.value;
      final bool isDark = mode == ThemeMode.dark;
      return SwitchListTile(
        title: const Text("Dark mode"),
        value: isDark,
        onChanged: (bool newValue) {
          unawaited(manager.setDarkMode(isDark: newValue));
        },
      );
    });
  }
}
