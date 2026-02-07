import "package:database/main.dart";
import "package:drift/drift.dart";

extension DerivedStatistics on AppDatabase {
  /// Gets tag distribution: count of items per tag name
  Future<List<TagCount>> getTagDistribution() async {
    final query = customSelect(
      "SELECT t.name AS tag_name, t.color AS tag_color, COUNT(mr.id) AS item_count "
      "FROM tags t "
      "LEFT JOIN metadata_records mr ON mr.metadata_id = t.id "
      "GROUP BY t.id ORDER BY item_count DESC",
      readsFrom: {tags, metadataRecords},
    );

    final rows = await query.get();
    return rows
        .map((row) => TagCount(
              tagName: row.read<String>("tag_name"),
              tagColor: row.readNullable<int>("tag_color"),
              itemCount: row.read<int>("item_count"),
            ))
        .toList();
  }

  /// Gets folder composition: count of items per folder, grouped by item type
  Future<List<FolderItemCount>> getFolderComposition() async {
    final query = customSelect(
      "SELECT f.title AS folder_title, it.name AS item_type, COUNT(i.id) AS item_count "
      "FROM folders f "
      "LEFT JOIN items i ON i.folder_id = f.id "
      "LEFT JOIN item_types it ON it.id = i.type_id "
      "GROUP BY f.id, it.name ORDER BY item_count DESC",
      readsFrom: {folders, items, itemTypes},
    );

    final rows = await query.get();
    return rows
        .map((row) => FolderItemCount(
              folderTitle: row.read<String>("folder_title"),
              itemType: row.readNullable<String>("item_type"),
              itemCount: row.read<int>("item_count"),
            ))
        .toList();
  }

  /// Gets a combined activity summary for a date range
  Future<ActivitySummary> getActivitySummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Total events
    final totalResult = await customSelect(
      "SELECT COUNT(*) AS total FROM activity_events "
      "WHERE datetime(occurred_at) >= datetime(?) AND datetime(occurred_at) <= datetime(?)",
      variables: [
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
      ],
      readsFrom: {activityEvents},
    ).getSingle();
    final totalEvents = totalResult.read<int>("total");

    // Most active day
    final dayResult = await customSelect(
      "SELECT DATE(occurred_at) AS day, COUNT(*) AS count "
      "FROM activity_events "
      "WHERE datetime(occurred_at) >= datetime(?) AND datetime(occurred_at) <= datetime(?) "
      "GROUP BY day ORDER BY count DESC LIMIT 1",
      variables: [
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
      ],
      readsFrom: {activityEvents},
    ).getSingleOrNull();

    DateTime? mostActiveDay;
    int mostActiveDayCount = 0;
    if (dayResult != null) {
      mostActiveDay = DateTime.parse(dayResult.read<String>("day"));
      mostActiveDayCount = dayResult.read<int>("count");
    }

    // Most common action
    final actionResult = await customSelect(
      "SELECT event_type, COUNT(*) AS count "
      "FROM activity_events "
      "WHERE datetime(occurred_at) >= datetime(?) AND datetime(occurred_at) <= datetime(?) "
      "GROUP BY event_type ORDER BY count DESC LIMIT 1",
      variables: [
        Variable.withDateTime(startDate),
        Variable.withDateTime(endDate),
      ],
      readsFrom: {activityEvents},
    ).getSingleOrNull();

    return ActivitySummary(
      totalEvents: totalEvents,
      mostActiveDay: mostActiveDay,
      mostActiveDayCount: mostActiveDayCount,
      mostCommonAction: actionResult?.read<String>("event_type"),
      mostCommonActionCount: actionResult?.read<int>("count") ?? 0,
    );
  }
}

class TagCount {
  final String tagName;
  final int? tagColor;
  final int itemCount;

  const TagCount({
    required this.tagName,
    this.tagColor,
    required this.itemCount,
  });
}

class FolderItemCount {
  final String folderTitle;
  final String? itemType;
  final int itemCount;

  const FolderItemCount({
    required this.folderTitle,
    this.itemType,
    required this.itemCount,
  });
}

class ActivitySummary {
  final int totalEvents;
  final DateTime? mostActiveDay;
  final int mostActiveDayCount;
  final String? mostCommonAction;
  final int mostCommonActionCount;

  const ActivitySummary({
    required this.totalEvents,
    this.mostActiveDay,
    required this.mostActiveDayCount,
    this.mostCommonAction,
    required this.mostCommonActionCount,
  });
}
