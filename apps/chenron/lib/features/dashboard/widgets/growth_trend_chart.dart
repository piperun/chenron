import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:database/main.dart";
import "package:intl/intl.dart";
import "package:chenron/features/dashboard/widgets/chart_card.dart";
import "package:chenron/features/dashboard/widgets/time_range_selector.dart";

class GrowthTrendChart extends StatefulWidget {
  final List<Statistic> history;
  final TimeRange timeRange;
  final ValueChanged<TimeRange> onTimeRangeChanged;

  const GrowthTrendChart({
    super.key,
    required this.history,
    required this.timeRange,
    required this.onTimeRangeChanged,
  });

  @override
  State<GrowthTrendChart> createState() => _GrowthTrendChartState();
}

class _GrowthTrendChartState extends State<GrowthTrendChart> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChartCard(
      title: "Growth Trend",
      trailing: TimeRangeSelector(
        selected: widget.timeRange,
        onChanged: widget.onTimeRangeChanged,
      ),
      child: SizedBox(
        height: 250,
        child: widget.history.isEmpty
            ? Center(
                child: Text(
                  "No data yet. Statistics snapshots will appear as you use the app.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.5),
                  ),
                ),
              )
            : LineChart(_buildChartData(theme)),
      ),
    );
  }

  LineChartData _buildChartData(ThemeData theme) {
    final sorted = List<Statistic>.from(widget.history)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final dateFormat = DateFormat.MMMd();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _calculateInterval(sorted),
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
            interval: _xInterval(sorted),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= sorted.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  dateFormat.format(sorted[index].recordedAt),
                  style: theme.textTheme.labelSmall,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
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
      lineBarsData: [
        _buildLine(sorted, (s) => s.totalLinks.toDouble(), Colors.blue),
        _buildLine(sorted, (s) => s.totalDocuments.toDouble(), Colors.purple),
        _buildLine(sorted, (s) => s.totalFolders.toDouble(), Colors.orange),
        _buildLine(sorted, (s) => s.totalTags.toDouble(), Colors.teal),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final labels = ["Links", "Documents", "Folders", "Tags"];
              return LineTooltipItem(
                "${labels[spot.barIndex]}: ${spot.y.toInt()}",
                TextStyle(
                  color: spot.bar.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  LineChartBarData _buildLine(
    List<Statistic> sorted,
    double Function(Statistic) getValue,
    Color color,
  ) {
    return LineChartBarData(
      spots: sorted
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), getValue(e.value)))
          .toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.1),
      ),
    );
  }

  double _calculateInterval(List<Statistic> sorted) {
    if (sorted.isEmpty) return 1;
    double maxVal = 0;
    for (final s in sorted) {
      final vals = [
        s.totalLinks,
        s.totalDocuments,
        s.totalFolders,
        s.totalTags
      ];
      for (final v in vals) {
        if (v > maxVal) maxVal = v.toDouble();
      }
    }
    if (maxVal <= 10) return 1;
    return (maxVal / 5).ceilToDouble();
  }

  double _xInterval(List<Statistic> sorted) {
    if (sorted.length <= 7) return 1;
    return (sorted.length / 6).ceilToDouble();
  }
}
