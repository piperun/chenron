import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:database/features.dart";
import "package:vibe/vibe.dart";
import "package:chenron/features/statistics/widgets/chart_card.dart";

class FolderCompositionChart extends StatelessWidget {
  final List<FolderItemCount> folderCounts;
  final Map<String, Color>? typeColors;

  const FolderCompositionChart({
    super.key,
    required this.folderCounts,
    this.typeColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = ChartPalette.of(context);
    final folders = _aggregateFolders();

    return ChartCard(
      title: "Items per Folder",
      child: SizedBox(
        height: 200,
        child: folders.isEmpty
            ? Center(
                child: Text(
                  "No folders with items yet.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : BarChart(_buildChartData(theme, palette, folders)),
      ),
    );
  }

  /// Aggregate folderCounts into per-folder totals with type breakdown.
  /// Returns top 10 folders by total count.
  List<_FolderData> _aggregateFolders() {
    final map = <String, Map<String, int>>{};
    for (final entry in folderCounts) {
      map.putIfAbsent(entry.folderTitle, () => {});
      if (entry.itemType != null) {
        map[entry.folderTitle]![entry.itemType!] = entry.itemCount;
      }
    }

    final list = map.entries.map((e) {
      final total =
          e.value.values.fold<int>(0, (sum, count) => sum + count);
      return _FolderData(title: e.key, typeCounts: e.value, total: total);
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return list.take(10).toList();
  }

  BarChartData _buildChartData(
    ThemeData theme,
    ChartPalette palette,
    List<_FolderData> folders,
  ) {
    final colors = typeColors ?? {
      "link": palette.links,
      "document": palette.documents,
      "folder": palette.folders,
    };

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
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
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= folders.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _truncate(folders[index].title, 8),
                  style: theme.textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
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
      // Tooltip styled to match GrowthTrendChart / ActivityTimelineChart.
      // Without an explicit BarTouchData here fl_chart shows its default
      // slate-blue tooltip — visually inconsistent with the rest of the
      // page and themed for no theme in particular.
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipColor: (_) {
            final hsl = HSLColor.fromColor(theme.colorScheme.primary);
            return hsl.withSaturation(0.40).withLightness(0.20).toColor();
          },
          tooltipBorderRadius: BorderRadius.circular(8),
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final outline = palette.tooltipShadows;
            const labels = <String, String>{
              "link": "Links",
              "document": "Documents",
              "folder": "Folders",
            };
            final folder = folders[groupIndex];
            final spans = <TextSpan>[];
            for (final type in colors.keys) {
              final count = folder.typeCounts[type] ?? 0;
              if (count == 0) continue;
              spans.add(TextSpan(
                text: "${labels[type]}: $count\n",
                style: TextStyle(
                  color: colors[type],
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  shadows: outline,
                ),
              ));
            }
            return BarTooltipItem(
              "${folder.title}\n",
              TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                shadows: outline,
              ),
              children: spans,
            );
          },
        ),
      ),
      barGroups: folders.asMap().entries.map((entry) {
        final folder = entry.value;
        final rodStacks = <BarChartRodStackItem>[];
        double cumulative = 0;

        for (final type in colors.keys) {
          final count = (folder.typeCounts[type] ?? 0).toDouble();
          if (count > 0) {
            rodStacks.add(BarChartRodStackItem(
              cumulative,
              cumulative + count,
              colors[type]!,
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
              // Same transparent-rod trick as ActivityTimelineChart —
              // prevents fl_chart's default Colors.cyan from peeking
              // through during animation. FolderCompositionChart never
              // swaps data so this is defensive, but keeps the two
              // charts symmetric.
              color: Colors.transparent,
              width: 20,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return "${text.substring(0, maxLength)}...";
  }
}

class _FolderData {
  final String title;
  final Map<String, int> typeCounts;
  final int total;

  const _FolderData({
    required this.title,
    required this.typeCounts,
    required this.total,
  });
}
