import "package:flutter/material.dart";
import "package:vibe/vibe.dart";

class OverviewCards extends StatelessWidget {
  final int totalLinks;
  final int totalDocuments;
  final int totalFolders;
  final int totalTags;

  const OverviewCards({
    super.key,
    required this.totalLinks,
    required this.totalDocuments,
    required this.totalFolders,
    required this.totalTags,
  });

  @override
  Widget build(BuildContext context) {
    // These four stat cards are the same per-entity categorical identity
    // the statistics charts use, so draw their accent icons from the same
    // ChartPalette the charts read. A theme like Nier then recolors the
    // cards in lockstep with its Growth Trend / Activity Timeline series.
    final palette = ChartPalette.of(context);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.link,
            label: "Links",
            count: totalLinks,
            color: palette.links,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.description,
            label: "Documents",
            count: totalDocuments,
            color: palette.documents,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.folder,
            label: "Folders",
            count: totalFolders,
            color: palette.folders,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.label,
            label: "Tags",
            count: totalTags,
            color: palette.tags,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              "$count",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color
                    ?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
