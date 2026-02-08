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
        occurredAt: Value(DateTime.now()),
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
      "WHERE datetime(occurred_at) >= datetime(?) AND datetime(occurred_at) <= datetime(?) "
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
      "WHERE datetime(occurred_at) >= datetime(?) AND datetime(occurred_at) <= datetime(?) "
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

  /// Stream of recent activity events with resolved entity names.
  ///
  /// LEFT JOINs activity_events with links, documents, folders, and tags
  /// to resolve human-readable names for each entity.
  Stream<List<EnrichedActivityEvent>> watchRecentActivityWithNames(
      {int limit = 20}) {
    return customSelect(
      "SELECT ae.*, "
      "COALESCE(l.path, d.title, f.title, t.name) AS entity_name "
      "FROM activity_events ae "
      "LEFT JOIN links l ON ae.entity_type = 'link' AND ae.entity_id = l.id "
      "LEFT JOIN documents d ON ae.entity_type = 'document' AND ae.entity_id = d.id "
      "LEFT JOIN folders f ON ae.entity_type = 'folder' AND ae.entity_id = f.id "
      "LEFT JOIN tags t ON ae.entity_type = 'tag' AND ae.entity_id = t.id "
      "ORDER BY ae.occurred_at DESC LIMIT ?",
      variables: [Variable.withInt(limit)],
      readsFrom: {activityEvents, links, documents, folders, tags},
    ).watch().map((rows) => rows
        .map((row) => EnrichedActivityEvent(
              id: row.read<String>("id"),
              occurredAt: row.read<DateTime>("occurred_at"),
              eventType: row.read<String>("event_type"),
              entityType: row.read<String>("entity_type"),
              entityId: row.readNullable<String>("entity_id"),
              entityName: row.readNullable<String>("entity_name"),
            ))
        .toList());
  }
}

class EnrichedActivityEvent {
  final String id;
  final DateTime occurredAt;
  final String eventType;
  final String entityType;
  final String? entityId;
  final String? entityName;

  const EnrichedActivityEvent({
    required this.id,
    required this.occurredAt,
    required this.eventType,
    required this.entityType,
    this.entityId,
    this.entityName,
  });
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
