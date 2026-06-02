import "package:app_logger/app_logger.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/state/theme_choice.dart";
import "package:chenron/locator.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:vibe/vibe.dart";

class AvailableThemeSelector extends SignalWidget {
  const AvailableThemeSelector({super.key});

  static const EdgeInsets _contentPadding = EdgeInsets.all(16.0);
  static const EdgeInsets _dropdownPadding =
      EdgeInsets.symmetric(vertical: 8.0);

  @override
  Widget build(BuildContext context) {
    loggerGlobal.fine("AvailableThemeSelector", "Build method called.");
    final notifier = locator.get<SettingsCoordinator>().theme;

    // Read the signals this widget renders against; SignalWidget tracks
    // `.value` reads in build and rebuilds when any of them change.
    notifier.availableThemes.value;
    final selected = notifier.selectedChoice.value;
    final sortMode = notifier.sortMode.value;
    final sorted = notifier.sortedThemes.value;

    if (sorted.isEmpty) {
      return const Padding(
        padding: _contentPadding,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Padding(
      padding: _dropdownPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  notifier.setSortMode(values.first);
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
          DropdownMenu<ThemeChoice>(
            label: const Text("Select Theme"),
            expandedInsets: EdgeInsets.zero,
            initialSelection: selected,
            menuHeight: 300,
            enableFilter: true,
            textStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
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
              notifier.select(newValue);
            },
          ),
          if (selected != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _ThemePreview(
                variants: notifier.getPreviewVariants(selected),
              ),
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

/// Compact color-role preview for a theme's light and dark variants.
class _ThemePreview extends StatelessWidget {
  final ThemeVariants? variants;

  const _ThemePreview({required this.variants});

  @override
  Widget build(BuildContext context) {
    if (variants == null) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SchemeGrid(label: "Light", scheme: variants!.light.colorScheme),
        const SizedBox(height: 8),
        _SchemeGrid(label: "Dark", scheme: variants!.dark.colorScheme),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: _SchemeGrid._rowLabelWidth),
          child: Row(
            children: [
              for (final label in [
                "Primary",
                "Secondary",
                "Tertiary",
                "Error",
              ])
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SchemeGrid extends StatelessWidget {
  final String label;
  final ColorScheme scheme;

  const _SchemeGrid({required this.label, required this.scheme});

  static const double _gap = 2;
  static const double _rowLabelWidth = 64;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 2),
        _LabeledRow(label: "Base", style: labelStyle, cells: [
          _SchemeCell(color: scheme.primary),
          _SchemeCell(color: scheme.secondary),
          _SchemeCell(color: scheme.tertiary),
          _SchemeCell(color: scheme.error),
        ]),
        const SizedBox(height: _gap),
        _LabeledRow(label: "Container", style: labelStyle, cells: [
          _SchemeCell(color: scheme.primaryContainer),
          _SchemeCell(color: scheme.secondaryContainer),
          _SchemeCell(color: scheme.tertiaryContainer),
          _SchemeCell(color: scheme.errorContainer),
        ]),
        const SizedBox(height: _gap),
        _LabeledRow(label: "Surface", style: labelStyle, cells: [
          _SchemeCell(color: scheme.surface),
          _SchemeCell(color: scheme.surfaceContainerHighest),
          _SchemeCell(color: scheme.outline),
          _SchemeCell(color: scheme.outlineVariant),
        ]),
      ],
    );
  }
}

class _LabeledRow extends StatelessWidget {
  final String label;
  final TextStyle? style;
  final List<Widget> cells;

  const _LabeledRow({
    required this.label,
    required this.style,
    required this.cells,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: _SchemeGrid._rowLabelWidth,
          child: Text(label, style: style),
        ),
        ...cells,
      ],
    );
  }
}

class _SchemeCell extends StatelessWidget {
  final Color color;

  const _SchemeCell({required this.color});

  static const double _cellHeight = 24;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: _cellHeight,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
