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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
        const SizedBox(height: 24),
        Text(
          "Item Click Action",
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Watch(
          (context) => SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                value: 0,
                label: Text("Open Item"),
                icon: Icon(Icons.open_in_new),
              ),
              ButtonSegment<int>(
                value: 1,
                label: Text("Show Details"),
                icon: Icon(Icons.info_outline),
              ),
            ],
            selected: {controller.itemClickAction.value},
            onSelectionChanged: (Set<int> newSelection) {
              controller.updateItemClickAction(newSelection.first);
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Choose what happens when you click an item in the viewer.",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
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
        const SizedBox(height: 24),
        Text(
          "Card Display",
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          "Choose which elements to show on item cards.",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Watch(
          (context) => Column(
            children: [
              SwitchListTile(
                title: const Text("Show Images"),
                subtitle: const Text("Display thumbnail images on cards"),
                value: controller.showImages.value,
                onChanged: (value) =>
                    controller.updateShowImages(enabled: value),
              ),
              SwitchListTile(
                title: const Text("Show Description"),
                subtitle: const Text("Display description text on cards"),
                value: controller.showDescription.value,
                onChanged: (value) =>
                    controller.updateShowDescription(enabled: value),
              ),
              SwitchListTile(
                title: const Text("Show Tags"),
                subtitle: const Text("Display tags on cards"),
                value: controller.showTags.value,
                onChanged: (value) =>
                    controller.updateShowTags(enabled: value),
              ),
              SwitchListTile(
                title: const Text("Show Copy Link"),
                subtitle: const Text("Display the URL bar on cards"),
                value: controller.showCopyLink.value,
                onChanged: (value) =>
                    controller.updateShowCopyLink(enabled: value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
