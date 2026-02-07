import "package:flutter/material.dart";
import "package:database/main.dart";
import "package:chenron/features/dashboard/widgets/chart_card.dart";
import "package:chenron/shared/utils/time_formatter.dart";

class RecentActivityList extends StatelessWidget {
  final List<ActivityEvent> events;

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
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.5),
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
  final ActivityEvent event;

  const _ActivityTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _getIconAndColor(event.eventType);

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
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: event.entityId != null
          ? Text(
              "${event.entityType} ${_shortId(event.entityId!)}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color
                    ?.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: Text(
        TimeFormatter.formatRelative(event.occurredAt),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.textTheme.labelSmall?.color?.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  (IconData, Color) _getIconAndColor(String eventType) {
    if (eventType.contains("created")) return (Icons.add_circle_outline, Colors.green);
    if (eventType.contains("deleted")) return (Icons.remove_circle_outline, Colors.red);
    if (eventType.contains("viewed")) return (Icons.visibility_outlined, Colors.blue);
    if (eventType.contains("edited")) return (Icons.edit_outlined, Colors.orange);
    if (eventType.contains("archived")) return (Icons.archive_outlined, Colors.grey);
    return (Icons.circle_outlined, Colors.grey);
  }

  String _formatEventType(String eventType) {
    // "link_created" -> "Link created"
    return eventType.replaceAll("_", " ").replaceFirstMapped(
          RegExp(r"^[a-z]"),
          (match) => match.group(0)!.toUpperCase(),
        );
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return "${id.substring(0, 8)}...";
  }
}
