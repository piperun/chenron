import "package:database/database.dart";
import "package:database/main.dart";
import "package:drift/drift.dart";

extension ActivityTracking on AppDatabase {
  /// Records a single activity event
  Future<void> recordActivity({
    required String eventType,
    required String entityType,
    String? entityId,
  }) async {
    await into(activityEvents).insert(
      ActivityEventsCompanion.insert(
        id: generateId(),
        eventType: eventType,
        entityType: entityType,
        entityId: entityId != null ? Value(entityId) : const Value.absent(),
      ),
    );
  }

  /// Gets activity events with optional filters
  Future<List<ActivityEvent>> getActivityEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? entityType,
  }) async {
    final query = select(activityEvents)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);

    if (startDate != null) {
      query.where((t) => t.occurredAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.occurredAt.isSmallerOrEqualValue(endDate));
    }
    if (entityType != null) {
      query.where((t) => t.entityType.equals(entityType));
    }

    return query.get();
  }

  /// Returns event counts grouped by eventType within a date range
  Future<Map<String, int>> getActivityCountsByType({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = customSelect(
      "SELECT event_type, COUNT(*) as count FROM activity_events "
      "WHERE occurred_at >= ? AND occurred_at <= ? "
      "GROUP BY event_type ORDER BY count DESC",
      variables: [
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
      ],
      readsFrom: {activityEvents},
    );

    final rows = await query.get();
    return {
      for (final row in rows)
        row.read<String>("event_type"): row.read<int>("count"),
    };
  }

  /// Returns daily activity counts for the activity timeline chart
  Future<List<DailyActivityCount>> getDailyActivityCounts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = customSelect(
      "SELECT DATE(occurred_at) as day, entity_type, COUNT(*) as count "
      "FROM activity_events "
      "WHERE occurred_at >= ? AND occurred_at <= ? "
      "GROUP BY day, entity_type ORDER BY day ASC",
      variables: [
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
      ],
      readsFrom: {activityEvents},
    );

    final rows = await query.get();
    return rows
        .map((row) => DailyActivityCount(
              date: DateTime.parse(row.read<String>("day")),
              entityType: row.read<String>("entity_type"),
              count: row.read<int>("count"),
            ))
        .toList();
  }

  /// Stream of the most recent activity events
  Stream<List<ActivityEvent>> watchRecentActivity({int limit = 20}) {
    return (select(activityEvents)
          ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
          ..limit(limit))
        .watch();
  }
}

class DailyActivityCount {
  final DateTime date;
  final String entityType;
  final int count;

  const DailyActivityCount({
    required this.date,
    required this.entityType,
    required this.count,
  });
}
