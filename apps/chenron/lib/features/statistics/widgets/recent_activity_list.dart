import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:database/database.dart";
import "package:chenron/features/statistics/widgets/chart_card.dart";
import "package:chenron/shared/utils/time_formatter.dart";

class RecentActivityList extends StatelessWidget {
  final List<EnrichedActivityEvent> events;

  const RecentActivityList({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChartCard(
      title: "Recent Activity",
      child: events.isEmpty
          ? SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  "No activity recorded yet.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final event = events[index];
                return _ActivityTile(event: event);
              },
            ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final EnrichedActivityEvent event;

  const _ActivityTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (icon, color) = _getIconAndColor(event.eventType, colorScheme);

    final displayName = event.entityName ?? event.entityId;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, size: 16, color: color),
      ),
      title: Text(
        _formatEventType(event.eventType),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: displayName != null
          ? Text(
              "${event.entityType}: $displayName",
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            TimeFormatter.formatRelative(event.occurredAt),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (event.entityId != null)
            IconButton(
              icon: Icon(
                Icons.copy,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: "Copy ID",
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.only(left: 4),
              constraints: const BoxConstraints(),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: event.entityId!));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Copied ${event.entityType} ID"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  (IconData, Color) _getIconAndColor(
      String eventType, ColorScheme colorScheme) {
    if (eventType.contains("created")) return (Icons.add_circle_outline, colorScheme.primary);
    if (eventType.contains("deleted")) return (Icons.remove_circle_outline, colorScheme.error);
    if (eventType.contains("viewed")) return (Icons.visibility_outlined, colorScheme.tertiary);
    if (eventType.contains("edited")) return (Icons.edit_outlined, colorScheme.secondary);
    if (eventType.contains("archived")) return (Icons.archive_outlined, colorScheme.outline);
    return (Icons.circle_outlined, colorScheme.outline);
  }

  String _formatEventType(String eventType) {
    // "link_created" -> "Link created"
    return eventType.replaceAll("_", " ").replaceFirstMapped(
          RegExp(r"^[a-z]"),
          (match) => match.group(0)!.toUpperCase(),
        );
  }
}
