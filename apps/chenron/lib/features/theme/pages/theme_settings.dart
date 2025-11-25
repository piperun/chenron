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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Theme Settings",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            AvailableThemeSelector(
              controller: controller,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

