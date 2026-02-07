import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:intl/intl.dart";
import "package:chenron/features/dashboard/widgets/chart_card.dart";
import "package:chenron/features/dashboard/widgets/time_range_selector.dart";

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

  static const _entityColors = {
    "link": Colors.blue,
    "document": Colors.purple,
    "folder": Colors.orange,
    "tag": Colors.teal,
  };

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
            : BarChart(_buildChartData(theme)),
      ),
    );
  }

  BarChartData _buildChartData(ThemeData theme) {
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

        for (final entityType in _entityColors.keys) {
          final count = (dayData[entityType] ?? 0).toDouble();
          if (count > 0) {
            rodStacks.add(BarChartRodStackItem(
              cumulative,
              cumulative + count,
              _entityColors[entityType]!,
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
              width: sortedDays.length > 14 ? 8 : 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }
}
