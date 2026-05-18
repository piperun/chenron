import "package:chenron/features/theme/ui/components/available_theme_selector.dart";
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
      ],
    );
  }
}
