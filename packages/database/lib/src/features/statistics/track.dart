import "package:database/database.dart";
import "package:database/features.dart";
import "package:database/src/core/time.dart";
import "package:drift/drift.dart";

extension StatisticsTracking on AppDatabase {
  /// Records a snapshot of current item counts
  Future<void> recordStatisticsSnapshot() async {
    final counts = await getCurrentCounts();
    await into(statistics).insert(
      StatisticsCompanion.insert(
        id: generateId(),
        totalLinks: Value(counts.links),
        totalDocuments: Value(counts.documents),
        totalTags: Value(counts.tags),
        totalFolders: Value(counts.folders),
      ),
    );
  }

  /// Gets the latest statistics snapshot
  Future<Statistic?> getLatestStatistics() async {
    return (select(statistics)
          ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Gets statistics history within a date range
  Future<List<Statistic>> getStatisticsHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = select(statistics)
      ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]);

    if (startDate != null) {
      query.where((t) => t.recordedAt.isBiggerOrEqualValue(dbBound(startDate)));
    }
    if (endDate != null) {
      query.where((t) => t.recordedAt.isSmallerOrEqualValue(dbBound(endDate)));
    }

    return query.get();
  }

  /// Counts all items in the database right now.
  ///
  /// One round-trip: four `COUNT(*)` scalar subqueries in a single
  /// statement instead of four sequential awaited queries.
  Future<ItemCounts> getCurrentCounts() async {
    final row = await customSelect(
      "SELECT "
      "(SELECT COUNT(*) FROM links) AS link_count, "
      "(SELECT COUNT(*) FROM documents) AS document_count, "
      "(SELECT COUNT(*) FROM tags) AS tag_count, "
      "(SELECT COUNT(*) FROM folders) AS folder_count",
      readsFrom: {links, documents, tags, folders},
    ).getSingle();

    return ItemCounts(
      links: row.read<int>("link_count"),
      documents: row.read<int>("document_count"),
      tags: row.read<int>("tag_count"),
      folders: row.read<int>("folder_count"),
    );
  }
}

class ItemCounts {
  final int links;
  final int documents;
  final int tags;
  final int folders;

  ItemCounts({
    required this.links,
    required this.documents,
    required this.tags,
    required this.folders,
  });
}