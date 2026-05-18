import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/state/display_settings.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/utils/time_formatter.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class DisplaySettingsPanel extends StatelessWidget {
  const DisplaySettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = locator.get<SettingsCoordinator>().display;
    final DisplaySettings snapshot = notifier.current.watch(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Time Format", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        RadioGroup<int>(
          groupValue: snapshot.timeDisplayFormat,
          onChanged: (value) {
            if (value != null) {
              notifier.update((s) => s.copyWith(timeDisplayFormat: value));
            }
          },
          child: Column(
            children: [
              RadioListTile<int>(
                title: const Text("Relative (e.g., \"2h ago\", \"5d ago\")"),
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
                title: const Text("Absolute (e.g., \"2025-01-01 14:30\")"),
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
        const SizedBox(height: 24),
        Text("Item Click Action", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<int>(
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
          selected: {snapshot.itemClickAction},
          onSelectionChanged: (Set<int> newSelection) {
            notifier
                .update((s) => s.copyWith(itemClickAction: newSelection.first));
          },
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
        Text("Card Display", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          "Choose which elements to show on item cards.",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Column(
          children: [
            SwitchListTile(
              title: const Text("Show Images"),
              subtitle: const Text("Display thumbnail images on cards"),
              value: snapshot.showImages,
              onChanged: (value) =>
                  notifier.update((s) => s.copyWith(showImages: value)),
            ),
            SwitchListTile(
              title: const Text("Show Description"),
              subtitle: const Text("Display description text on cards"),
              value: snapshot.showDescription,
              onChanged: (value) =>
                  notifier.update((s) => s.copyWith(showDescription: value)),
            ),
            SwitchListTile(
              title: const Text("Show Tags"),
              subtitle: const Text("Display tags on cards"),
              value: snapshot.showTags,
              onChanged: (value) =>
                  notifier.update((s) => s.copyWith(showTags: value)),
            ),
            SwitchListTile(
              title: const Text("Show Copy Button"),
              subtitle: const Text("Display the copy button on cards"),
              value: snapshot.showCopyLink,
              onChanged: (value) =>
                  notifier.update((s) => s.copyWith(showCopyLink: value)),
            ),
          ],
        ),
      ],
    );
  }
}
