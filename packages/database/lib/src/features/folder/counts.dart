import "package:database/main.dart";
import "package:database/models/item.dart";
import "package:drift/drift.dart";

/// A lightweight projection of a folder row alongside per-type item
/// counts. Use when only counts are needed (e.g. navigation rail badges),
/// instead of `watchAllFolders(includeOptions: {AppDataInclude.items})`,
/// which joins the full item × link/document × metadata × tag tree.
class FolderItemCounts {
  final String id;
  final String title;
  final String description;
  final int? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Item counts keyed by [FolderItemType]. All three keys are present —
  /// folders with no items of a given type carry a count of `0`.
  final Map<FolderItemType, int> counts;

  const FolderItemCounts({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    required this.counts,
  });

  int countOf(FolderItemType type) => counts[type] ?? 0;

  int get total =>
      counts.values.fold<int>(0, (acc, value) => acc + value);
}

extension FolderCountsExtensions on AppDatabase {
  /// Watch every folder paired with its per-type item counts.
  ///
  /// Single aggregated SQL query keyed by folder + item type — refires
  /// only when `folders` or `items` change, not when the related
  /// link/document/metadata/tag rows shift. Replaces the heavy
  /// `watchAllFolders(includeOptions: {AppDataInclude.items})` join for
  /// count-only consumers.
  Stream<List<FolderItemCounts>> watchFoldersWithItemCounts() {
    return customSelect(
      """
SELECT
  f.id AS id,
  f.title AS title,
  f.description AS description,
  f.color AS color,
  f.created_at AS created_at,
  f.updated_at AS updated_at,
  COALESCE(SUM(CASE WHEN i.type_id = ?1 THEN 1 ELSE 0 END), 0) AS link_count,
  COALESCE(SUM(CASE WHEN i.type_id = ?2 THEN 1 ELSE 0 END), 0) AS document_count,
  COALESCE(SUM(CASE WHEN i.type_id = ?3 THEN 1 ELSE 0 END), 0) AS folder_count
FROM folders f
LEFT JOIN items i ON i.folder_id = f.id
GROUP BY f.id
""",
      variables: [
        Variable<int>(FolderItemType.link.dbId),
        Variable<int>(FolderItemType.document.dbId),
        Variable<int>(FolderItemType.folder.dbId),
      ],
      readsFrom: {folders, items},
    ).watch().map((rows) {
      return rows
          .map((row) => FolderItemCounts(
                id: row.read<String>("id"),
                title: row.read<String>("title"),
                description: row.read<String>("description"),
                color: row.readNullable<int>("color"),
                createdAt: row.read<DateTime>("created_at"),
                updatedAt: row.read<DateTime>("updated_at"),
                counts: {
                  FolderItemType.link: row.read<int>("link_count"),
                  FolderItemType.document: row.read<int>("document_count"),
                  FolderItemType.folder: row.read<int>("folder_count"),
                },
              ))
          .toList();
    });
  }
}
