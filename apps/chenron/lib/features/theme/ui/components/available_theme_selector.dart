import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:app_logger/app_logger.dart";

class AvailableThemeSelector extends StatelessWidget {
  final ConfigController controller;

  const AvailableThemeSelector({
    super.key,
    required this.controller,
  });

  static const EdgeInsets _contentPadding = EdgeInsets.all(16.0);
  static const EdgeInsets _dropdownPadding =
      EdgeInsets.symmetric(vertical: 8.0);

  @override
  Widget build(BuildContext context) {
    loggerGlobal.fine("AvailableThemeSelector", "Build method called.");

    controller.availableThemes.watch(context);
    final selected = controller.selectedThemeChoice.watch(context);
    final isLoading = controller.isLoading.watch(context);
    final error = controller.error.watch(context);
    final sortMode = controller.themeSortMode.watch(context);
    final sorted = controller.sortedThemes;

    if (isLoading && sorted.isEmpty) {
      return const Padding(
        padding: _contentPadding,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      loggerGlobal.warning(
          "AvailableThemeSelector", "Rendering Error state: $error");
      return Padding(
        padding: _contentPadding,
        child: Center(
          child: Text(
            "Error loading themes: $error",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    if (sorted.isEmpty) {
      return const Padding(
        padding: _contentPadding,
        child: Center(
          child: Text(
            "No themes available.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return Padding(
      padding: _dropdownPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sort toggle
          Row(
            children: [
              Text("Sort by", style: theme.textTheme.bodySmall),
              const SizedBox(width: 8),
              SegmentedButton<ThemeSortMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeSortMode.name,
                    label: Text("A-Z"),
                  ),
                  ButtonSegment(
                    value: ThemeSortMode.colorCount,
                    label: Text("Colors"),
                  ),
                ],
                selected: {sortMode},
                onSelectionChanged: (values) {
                  controller.themeSortMode.value = values.first;
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: WidgetStatePropertyAll(
                    theme.textTheme.labelSmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Theme dropdown
          DropdownMenu<ThemeChoice>(
            label: const Text("Select Theme"),
            expandedInsets: EdgeInsets.zero,
            initialSelection: selected,
            dropdownMenuEntries: [
              for (final choice in sorted)
                DropdownMenuEntry<ThemeChoice>(
                  value: choice,
                  label: choice.name,
                  leadingIcon: _ColorSwatches(colors: choice.swatches),
                  trailingIcon: Text(
                    choice.colorCount == 1
                        ? "1 color"
                        : "${choice.colorCount} colors",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
            onSelected: (ThemeChoice? newValue) {
              loggerGlobal.info("AvailableThemeSelector",
                  "DropdownMenu onSelected: ${newValue?.key}");
              controller.updateSelectedTheme(newValue);
            },
          ),
        ],
      ),
    );
  }
}

class _ColorSwatches extends StatelessWidget {
  final List<Color> colors;

  const _ColorSwatches({required this.colors});

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < colors.length && i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: colors[i],
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(
                      alpha: 0.3,
                    ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
