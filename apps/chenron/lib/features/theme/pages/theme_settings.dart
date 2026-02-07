import "package:flutter/material.dart";
import "package:chenron/features/settings/controller/config_controller.dart"; // Import controller
import "package:chenron/features/theme/ui/components/available_theme_selector.dart";

class ThemeSettings extends StatelessWidget {
  final ConfigController controller;

  const ThemeSettings({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AvailableThemeSelector(
          controller: controller,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

