import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:database/database.dart";
import "package:chenron/features/statistics/widgets/chart_card.dart";
import "package:chenron/shared/constants/tag_colors.dart";

class TagDistributionChart extends StatelessWidget {
  final List<TagCount> tagCounts;

  const TagDistributionChart({
    super.key,
    required this.tagCounts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nonEmpty = tagCounts.where((t) => t.itemCount > 0).toList();

    return ChartCard(
      title: "Tag Distribution",
      child: SizedBox(
        height: 200,
        child: nonEmpty.isEmpty
            ? Center(
                child: Text(
                  "No tagged items yet.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.5),
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(_buildChartData(nonEmpty)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _Legend(tags: nonEmpty),
                  ),
                ],
              ),
      ),
    );
  }

  PieChartData _buildChartData(List<TagCount> tags) {
    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: tags.asMap().entries.map((entry) {
        final tag = entry.value;
        final color = tag.tagColor != null
            ? Color(tag.tagColor!)
            : kTagColorPalette[entry.key % kTagColorPalette.length];

        return PieChartSectionData(
          value: tag.itemCount.toDouble(),
          color: color,
          radius: 50,
          title: "${tag.itemCount}",
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
    );
  }
}

class _Legend extends StatelessWidget {
  final List<TagCount> tags;

  const _Legend({required this.tags});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tags.asMap().entries.map((entry) {
        final tag = entry.value;
        final color = tag.tagColor != null
            ? Color(tag.tagColor!)
            : kTagColorPalette[entry.key % kTagColorPalette.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  tag.tagName,
                  style: theme.textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
