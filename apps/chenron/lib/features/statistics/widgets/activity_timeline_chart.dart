import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:database/features.dart";
import "package:intl/intl.dart";
import "package:chenron/features/statistics/widgets/chart_card.dart";
import "package:chenron/features/statistics/widgets/time_range_selector.dart";

class ActivityTimelineChart extends StatelessWidget {
  final List<DailyActivityCount> dailyCounts;
  final TimeRange timeRange;
  final ValueChanged<TimeRange> onTimeRangeChanged;

  const ActivityTimelineChart({
    super.key,
    required this.dailyCounts,
    required this.timeRange,
    required this.onTimeRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChartCard(
      title: "Activity Timeline",
      trailing: TimeRangeSelector(
        selected: timeRange,
        onChanged: onTimeRangeChanged,
      ),
      child: SizedBox(
        height: 200,
        child: dailyCounts.isEmpty
            ? Center(
                child: Text(
                  "No activity recorded yet.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.5),
                  ),
                ),
              )
            // ClipRect contains a swap-animation artifact: when time
            // range changes, BarChartData.maxY and each bar's `toY`
            // tween at different rates, so for a few frames a bar's
            // value temporarily exceeds the chart's current maxY. fl_chart
            // doesn't clip its own paint (BarChartData's constructor
            // doesn't forward AxisChartData.clipData), so those frames
            // would draw the bar outside the SizedBox — visibly bleeding
            // up into the Growth Trend chart above. ClipRect at the
            // widget layer forces that overshoot to stay inside the
            // chart card.
            : ClipRect(
                child: BarChart(
                  _buildChartData(theme),
                  // Default is 150 ms / Curves.linear, which "snaps"
                  // sharply when switching time ranges that have very
                  // different maxY. easeOutCubic decelerates the
                  // settle and keeps the new heights from looking
                  // twitchy now that they are clipped to the chart.
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                ),
              ),
      ),
    );
  }

  BarChartData _buildChartData(ThemeData theme) {
    // Mirrors FolderCompositionChart's mapping so the two charts on the
    // same page share a coherent palette. ColorScheme only gives three
    // semantic accents (primary/secondary/tertiary), so "tag" falls back
    // to primaryContainer — a paired accent that still reads as themed
    // rather than dropping back to vivid Material defaults.
    final entityColors = <String, Color>{
      "link": theme.colorScheme.primary,
      "document": theme.colorScheme.tertiary,
      "folder": theme.colorScheme.secondary,
      "tag": theme.colorScheme.primaryContainer,
    };
    // Group by date
    final grouped = <DateTime, Map<String, int>>{};
    for (final entry in dailyCounts) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      grouped.putIfAbsent(day, () => {});
      grouped[day]![entry.entityType] = entry.count;
    }

    final sortedDays = grouped.keys.toList()..sort();
    final dateFormat = DateFormat.MMMd();

    return BarChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: theme.dividerColor,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= sortedDays.length) {
                return const SizedBox.shrink();
              }
              if (sortedDays.length > 7 && index % 2 != 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  dateFormat.format(sortedDays[index]),
                  style: theme.textTheme.labelSmall,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: theme.textTheme.labelSmall,
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: sortedDays.asMap().entries.map((entry) {
        final dayData = grouped[entry.value]!;
        final rodStacks = <BarChartRodStackItem>[];
        double cumulative = 0;

        for (final entityType in entityColors.keys) {
          final count = (dayData[entityType] ?? 0).toDouble();
          if (count > 0) {
            rodStacks.add(BarChartRodStackItem(
              cumulative,
              cumulative + count,
              entityColors[entityType]!,
            ));
            cumulative += count;
          }
        }

        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: cumulative,
              rodStackItems: rodStacks,
              // fl_chart's default rod color is Colors.cyan. The stacks
              // normally cover the full rod, but during swap animation
              // the rod's `toY` and the stack items' `toY` values
              // interpolate at slightly different rates — for a few
              // frames a sliver of the underlying rod is exposed and
              // flashes cyan. Force the rod itself to transparent so any
              // animation gap is invisible.
              color: Colors.transparent,
              width: sortedDays.length > 14 ? 8 : 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }
}
