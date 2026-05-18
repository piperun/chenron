import "package:database/database.dart";
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
    // Map item.type_id (0/1/2) back to the enum name in SQL so the
    // shape of the returned rows stays stable now that the
    // `item_types` lookup table is gone (replaced by `intEnum<T>`).
    final query = customSelect(
      "SELECT f.title AS folder_title, "
      "CASE i.type_id "
      "WHEN ${FolderItemType.link.index} THEN '${FolderItemType.link.name}' "
      "WHEN ${FolderItemType.document.index} THEN '${FolderItemType.document.name}' "
      "WHEN ${FolderItemType.folder.index} THEN '${FolderItemType.folder.name}' "
      "END AS item_type, "
      "COUNT(i.id) AS item_count "
      "FROM folders f "
      "LEFT JOIN items i ON i.folder_id = f.id "
      "GROUP BY f.id, item_type ORDER BY item_count DESC",
      readsFrom: {folders, items},
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
