import "package:database/main.dart";
import "package:drift/drift.dart";
import "package:database/database.dart";

extension StatisticsTracking on AppDatabase {
  /// Records a snapshot of current item counts
  Future<void> recordStatisticsSnapshot() async {
    final counts = await _getCurrentCounts();
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
      query.where((t) => t.recordedAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.recordedAt.isSmallerOrEqualValue(endDate));
    }

    return query.get();
  }

  /// Internal helper to count all items
  Future<_Counts> _getCurrentCounts() async {
    final links = await (selectOnly(this.links)
          ..addColumns([this.links.id.count()]))
        .getSingle();
    final docs = await (selectOnly(documents)
          ..addColumns([documents.id.count()]))
        .getSingle();
    final tags = await (selectOnly(this.tags)
          ..addColumns([this.tags.id.count()]))
        .getSingle();
    final folders = await (selectOnly(this.folders)
          ..addColumns([this.folders.id.count()]))
        .getSingle();

    return _Counts(
      links: links.read(this.links.id.count()) ?? 0,
      documents: docs.read(documents.id.count()) ?? 0,
      tags: tags.read(this.tags.id.count()) ?? 0,
      folders: folders.read(this.folders.id.count()) ?? 0,
    );
  }
}

class _Counts {
  final int links;
  final int documents;
  final int tags;
  final int folders;

  _Counts({
    required this.links,
    required this.documents,
    required this.tags,
    required this.folders,
  });
}
