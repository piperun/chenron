import "package:chenron/features/theme/ui/components/available_theme_selector.dart";
import "package:chenron/features/theme/ui/components/dark_mode_switch.dart";
import "package:chenron/features/theme/ui/components/theme_options_section.dart";
import "package:flutter/material.dart";

class ThemeSettingsPanel extends StatelessWidget {
  const ThemeSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AvailableThemeSelector(),
        SizedBox(height: 8),
        DarkModeSwitch(),
        SizedBox(height: 16),
        ThemeOptionsSection(),
      ],
    );
  }
}
