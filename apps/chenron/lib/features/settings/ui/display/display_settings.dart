import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/shared/utils/time_formatter.dart";

class DisplaySettings extends StatelessWidget {
  final ConfigController controller;

  const DisplaySettings({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Display Settings",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Time Format",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Watch(
              (context) => RadioGroup<int>(
                groupValue: controller.timeDisplayFormat.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.updateTimeDisplayFormat(value);
                  }
                },
                child: Column(
                  children: [
                    RadioListTile<int>(
                      title:
                          const Text("Relative (e.g., \"2h ago\", \"5d ago\")"),
                      subtitle: Text(
                        "Example: ${TimeFormatter.formatRelative(DateTime.now().subtract(const Duration(hours: 2)))}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                      value: 0,
                    ),
                    RadioListTile<int>(
                      title:
                          const Text("Absolute (e.g., \"2025-01-01 14:30\")"),
                      subtitle: Text(
                        "Example: ${TimeFormatter.formatAbsolute(DateTime.now())}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                      value: 1,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You can hover over or click the info icon on any item to see the full timestamp.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
