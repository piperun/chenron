// SQL is deliberately composed from fixed constants. Runtime substitution is
// reserved for the enum-owned ORDER BY fragment in [_viewerPageSql].
// ignore_for_file: prefer_interpolation_to_compose_strings

import "dart:convert";

import "package:database/database.dart";
import "package:database/src/core/id.dart";
import "package:drift/drift.dart";
import "package:meta/meta.dart";

enum ViewerSort { nameAsc, nameDesc, dateAsc, dateDesc }

const int viewerCardTagLimit = 20;
const int viewerTagFacetLimit = 100;

typedef ViewerItemKey = ({FolderItemType type, String id});

class ViewerSelectionLease {
  const ViewerSelectionLease(this.id);

  final String id;
}

@immutable
class ViewerQuery {
  const ViewerQuery({
    this.folderId,
    this.includeFolderParents = false,
    this.searchText = "",
    this.types = const <FolderItemType>{
      FolderItemType.link,
      FolderItemType.document,
      FolderItemType.folder,
    },
    this.includedTags = const <String>{},
    this.excludedTags = const <String>{},
    this.sort = ViewerSort.nameAsc,
  });

  /// Null selects the top-level library (folders + links only).
  /// Non-null selects direct items of this folder through `items`, including
  /// links, documents, and nested folders.
  final String? folderId;
  final bool includeFolderParents;
  final String searchText;
  final Set<FolderItemType> types;
  final Set<String> includedTags;
  final Set<String> excludedTags;
  final ViewerSort sort;

  ViewerQuery withoutTagFilters() => ViewerQuery(
        folderId: folderId,
        includeFolderParents: includeFolderParents,
        searchText: searchText,
        types: types,
        sort: sort,
      );

  @override
  bool operator ==(Object other) =>
      other is ViewerQuery &&
      other.folderId == folderId &&
      other.includeFolderParents == includeFolderParents &&
      other.searchText == searchText &&
      other.sort == sort &&
      _sameSet(other.types, types) &&
      _sameSet(other.includedTags, includedTags) &&
      _sameSet(other.excludedTags, excludedTags);

  @override
  int get hashCode => Object.hash(
        folderId,
        includeFolderParents,
        searchText,
        sort,
        Object.hashAllUnordered(types),
        Object.hashAllUnordered(includedTags),
        Object.hashAllUnordered(excludedTags),
      );
}

bool _sameSet<T>(Set<T> left, Set<T> right) =>
    left.length == right.length && left.containsAll(right);

class ViewerTagFacet {
  const ViewerTagFacet({required this.tag, required this.itemCount});

  final Tag tag;
  final int itemCount;
}

extension ViewerQueryExtensions on AppDatabase {
  Future<List<FolderItem>> getViewerPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) async {
    _validatePageArguments(limit: limit, offset: offset);
    final variables = _viewerFilterVariables(query)
      ..add(Variable<int>(limit))
      ..add(Variable<int>(offset));
    final rows = await customSelect(
      _viewerPageSql(query),
      variables: variables,
      readsFrom: _viewerTables,
    ).get();
    return _materializeRows(rows, limit: limit);
  }

  /// Returns SQLite's plan for the exact statement built by [getViewerPage].
  ///
  /// This diagnostic keeps every query value bound and is intended only for
  /// regression tests and local performance investigation.
  @visibleForTesting
  Future<List<String>> debugExplainViewerPageQueryPlan(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) async {
    _validatePageArguments(limit: limit, offset: offset);
    final variables = _viewerFilterVariables(query)
      ..add(Variable<int>(limit))
      ..add(Variable<int>(offset));
    final rows = await customSelect(
      "EXPLAIN QUERY PLAN " + _viewerPageSql(query),
      variables: variables,
      readsFrom: _viewerTables,
    ).get();
    return rows.map((row) => row.read<String>("detail")).toList();
  }

  Future<int> getViewerItemCount(ViewerQuery query) async {
    final row = await customSelect(
      query.folderId == null
          ? _topLevelCountSql
          : query.includeFolderParents
              ? _folderWithParentsCountSql
              : _folderCountSql,
      variables: _viewerFilterVariables(query),
      readsFrom: _viewerTables,
    ).getSingle();
    return row.read<int>("item_count");
  }

  Future<List<ViewerTagFacet>> getViewerTagFacets(
    ViewerQuery query, {
    String searchText = "",
  }) async {
    final facetQuery = query.withoutTagFilters();
    final variables = _viewerFilterVariables(facetQuery)
      ..add(Variable<String>(searchText))
      ..add(Variable<String>(searchText))
      ..add(const Variable<int>(viewerTagFacetLimit));
    final rows = await customSelect(
      facetQuery.folderId == null
          ? _topLevelFacetSql
          : facetQuery.includeFolderParents
              ? _folderWithParentsFacetSql
              : _folderFacetSql,
      // Folder facets use the same virtual parent/direct source as pages.
      // This keeps filter counts exact without a materialized prefix.
      variables: variables,
      readsFrom: _viewerTables,
    ).get();
    return rows
        .map(
          (row) => ViewerTagFacet(
            tag: Tag(
              id: row.read<String>("tag_id"),
              createdAt: row.read<DateTime>("tag_created_at"),
              name: row.read<String>("tag_name"),
              color: row.readNullable<int>("tag_color"),
            ),
            itemCount: row.read<int>("item_count"),
          ),
        )
        .toList();
  }

  Stream<void> watchViewerInvalidations() => tableUpdates(
        TableUpdateQuery.onAllTables(
          <TableInfo<Table, Object?>>[
            folders,
            links,
            documents,
            items,
            metadataRecords,
            tags,
          ],
        ),
      ).map((_) {});

  Future<ViewerSelectionLease> createViewerSelectionLease({
    required ViewerQuery query,
    Set<ViewerItemKey>? onlyKeys,
    Set<ViewerItemKey> excludedKeys = const <ViewerItemKey>{},
  }) async {
    final lease = ViewerSelectionLease(generateId());
    await transaction(() async {
      await customStatement(_createSelectionTableSql);
      if (onlyKeys == null) {
        final variables = <Variable<Object>>[
          Variable<String>(lease.id),
          ..._viewerFilterVariables(query),
        ];
        await customStatement(
          query.folderId == null
              ? _populateTopLevelSelectionSql
              : query.includeFolderParents
                  ? _populateFolderWithParentsSelectionSql
                  : _populateFolderSelectionSql,
          variables.map((variable) => variable.value).toList(),
        );
      } else if (onlyKeys.isNotEmpty) {
        await batch((batch) {
          for (final key in onlyKeys) {
            batch.customStatement(
              _insertSelectionKeySql,
              <Object?>[lease.id, key.type.index, key.id],
            );
          }
        });
      }
      if (excludedKeys.isNotEmpty) {
        await batch((batch) {
          for (final key in excludedKeys) {
            batch.customStatement(
              _deleteSelectionKeySql,
              <Object?>[lease.id, key.type.index, key.id],
            );
          }
        });
      }
    });
    return lease;
  }

  Future<List<FolderItem>> getViewerSelectionLeaseBatch(
    ViewerSelectionLease lease, {
    int limit = 100,
  }) async {
    _validatePageArguments(limit: limit, offset: 0);
    final rows = await customSelect(
      _selectionBatchSql,
      variables: <Variable<Object>>[
        Variable<String>(lease.id),
        Variable<int>(limit),
      ],
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        links,
        documents,
        folders,
        metadataRecords,
        tags,
      },
    ).get();
    return _materializeRows(rows, limit: limit);
  }

  Future<int> getViewerSelectionLeaseCount(
    ViewerSelectionLease lease,
  ) async {
    final row = await customSelect(
      _selectionCountSql,
      variables: <Variable<Object>>[Variable<String>(lease.id)],
    ).getSingle();
    return row.read<int>("item_count");
  }

  Future<void> consumeViewerSelectionLeaseBatch(
    ViewerSelectionLease lease,
    Iterable<ViewerItemKey> consumed,
  ) async {
    final consumedKeys = consumed.toList();
    if (consumedKeys.isEmpty) return;
    await batch((batch) {
      for (final key in consumedKeys) {
        batch.customStatement(
          _deleteSelectionKeySql,
          <Object?>[lease.id, key.type.index, key.id],
        );
      }
    });
  }

  Future<void> releaseViewerSelectionLease(
    ViewerSelectionLease lease,
  ) async {
    await customStatement(_releaseSelectionSql, <Object?>[lease.id]);
  }

  /// Loads only the requested tags for one item, independently of the
  /// card-hydration cap used by viewer pages and selection batches.
  Future<List<Tag>> getViewerItemTagsByNames({
    required String itemId,
    required Set<String> tagNames,
  }) async {
    if (tagNames.isEmpty) return const <Tag>[];
    final normalizedNames = tagNames.map((name) => name.toLowerCase()).toList()
      ..sort();
    final rows = await customSelect(
      _loadItemTagsByNamesSql,
      variables: <Variable<Object>>[
        Variable<String>(itemId),
        Variable<int>(MetadataTypeEnum.tag.index),
        Variable<String>(jsonEncode(normalizedNames)),
      ],
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        metadataRecords,
        tags,
      },
    ).get();
    return rows
        .map(
          (row) => Tag(
            id: row.read<String>("tag_id"),
            createdAt: row.read<DateTime>("tag_created_at"),
            name: row.read<String>("tag_name"),
            color: row.readNullable<int>("tag_color"),
          ),
        )
        .toList(growable: false);
  }

  Future<List<FolderItem>> _materializeRows(
    List<QueryRow> rows, {
    required int limit,
  }) async {
    final boundedRows = rows.length <= limit ? rows : rows.take(limit).toList();
    final itemIds = boundedRows.map((row) => row.read<String>("id")).toList();
    final tagsByItemId = await _loadViewerTags(itemIds);
    return boundedRows.map((row) {
      final id = row.read<String>("id");
      final relationId = row.readNullable<String>("relation_id");
      final entityCreatedAt = row.read<DateTime>("entity_created_at");
      final addedAt =
          relationId == null ? null : row.read<DateTime>("created_at");
      final itemTags = tagsByItemId[id] ?? const <Tag>[];
      final type = FolderItemType.values[row.read<int>("type_id")];
      return switch (type) {
        FolderItemType.link => FolderItem.link(
            id: id,
            itemId: relationId,
            url: row.read<String>("url"),
            archiveOrg: row.readNullable<String>("archive_org_url"),
            archiveIs: row.readNullable<String>("archive_is_url"),
            createdAt: entityCreatedAt,
            addedAt: addedAt,
            tags: itemTags,
          ),
        FolderItemType.document => FolderItem.document(
            id: id,
            itemId: relationId,
            title: row.read<String>("display_name"),
            filePath: row.read<String>("file_path"),
            fileType:
                DocumentFileType.values.byName(row.read<String>("file_type")),
            fileSize: row.readNullable<int>("file_size"),
            checksum: row.readNullable<String>("checksum"),
            createdAt: entityCreatedAt,
            updatedAt: row.readNullable<DateTime>("updated_at"),
            addedAt: addedAt,
            tags: itemTags,
          ),
        FolderItemType.folder => FolderItem.folder(
            id: id,
            itemId: relationId,
            folderId: id,
            title: row.read<String>("display_name"),
            description: row.readNullable<String>("description"),
            createdAt: entityCreatedAt,
            updatedAt: row.readNullable<DateTime>("updated_at"),
            addedAt: addedAt,
            tags: itemTags,
          ),
      };
    }).toList();
  }

  Future<Map<String, List<Tag>>> _loadViewerTags(List<String> itemIds) async {
    if (itemIds.isEmpty) return <String, List<Tag>>{};
    final rows = await customSelect(
      _loadTagsSql,
      variables: <Variable<Object>>[
        Variable<int>(MetadataTypeEnum.tag.index),
        Variable<String>(jsonEncode(itemIds)),
        const Variable<int>(viewerCardTagLimit),
      ],
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        metadataRecords,
        tags,
      },
    ).get();
    final result = <String, List<Tag>>{};
    for (final row in rows) {
      final itemId = row.read<String>("item_id");
      result.putIfAbsent(itemId, () => <Tag>[]).add(
            Tag(
              id: row.read<String>("tag_id"),
              createdAt: row.read<DateTime>("tag_created_at"),
              name: row.read<String>("tag_name"),
              color: row.readNullable<int>("tag_color"),
            ),
          );
    }
    return result;
  }

  Set<ResultSetImplementation<Table, Object?>> get _viewerTables =>
      <ResultSetImplementation<Table, Object?>>{
        folders,
        links,
        documents,
        items,
        metadataRecords,
        tags,
      };
}

extension on ViewerSort {
  // Folder viewers intentionally pin virtual parent rows (rank 0) before
  // direct rows (rank 1) for every sort, then use typed stable tie-breakers.
  String get orderBy => switch (this) {
        ViewerSort.nameAsc =>
          "source_rank ASC, display_name COLLATE NOCASE ASC, "
              "type_id ASC, id ASC",
        ViewerSort.nameDesc =>
          "source_rank ASC, display_name COLLATE NOCASE DESC, "
              "type_id ASC, id ASC",
        ViewerSort.dateAsc =>
          "source_rank ASC, created_at ASC, type_id ASC, id ASC",
        ViewerSort.dateDesc =>
          "source_rank ASC, created_at DESC, type_id ASC, id ASC",
      };
}

void _validatePageArguments({required int limit, required int offset}) {
  if (limit <= 0) {
    throw ArgumentError.value(limit, "limit", "must be greater than zero");
  }
  if (offset < 0) {
    throw ArgumentError.value(offset, "offset", "must not be negative");
  }
}

String _viewerPageSql(ViewerQuery query) {
  final template = query.folderId == null
      ? _topLevelPageSql
      : query.includeFolderParents
          ? _folderWithParentsPageSql
          : _folderPageSql;
  return template.replaceFirst("@ORDER_BY@", query.sort.orderBy);
}

List<Variable<Object>> _viewerFilterVariables(ViewerQuery query) {
  final includedTags = query.includedTags.toList()..sort();
  final excludedTags = query.excludedTags.toList()..sort();
  return <Variable<Object>>[
    if (query.folderId case final folderId?) ...<Variable<Object>>[
      if (query.includeFolderParents) Variable<String>(folderId),
      Variable<String>(folderId),
    ],
    Variable<int>(query.types.contains(FolderItemType.link) ? 1 : 0),
    Variable<int>(query.types.contains(FolderItemType.document) ? 1 : 0),
    Variable<int>(query.types.contains(FolderItemType.folder) ? 1 : 0),
    Variable<String>(query.searchText),
    Variable<String>(query.searchText),
    Variable<String>(query.searchText),
    Variable<int>(MetadataTypeEnum.tag.index),
    Variable<String>(query.searchText),
    Variable<String>(jsonEncode(includedTags)),
    Variable<int>(MetadataTypeEnum.tag.index),
    Variable<String>(jsonEncode(includedTags)),
    Variable<String>(jsonEncode(excludedTags)),
    Variable<int>(MetadataTypeEnum.tag.index),
    Variable<String>(jsonEncode(excludedTags)),
  ];
}

const _viewerFilterSql = """
WHERE ((? = 1 AND type_id = 0)
    OR (? = 1 AND type_id = 1)
    OR (? = 1 AND type_id = 2))
  AND display_name IS NOT NULL
  AND (
    ? = ''
    OR instr(lower(display_name), lower(?)) > 0
    OR instr(lower(COALESCE(file_path, '')), lower(?)) > 0
    OR EXISTS (
      SELECT 1
      FROM metadata_records search_metadata
      INNER JOIN tags search_tags
        ON search_tags.id = search_metadata.metadata_id
      WHERE search_metadata.item_id = viewer_items.id
        AND search_metadata.type_id = ?
        AND instr(lower(search_tags.name), lower(?)) > 0
    )
  )
  AND (
    json_array_length(?) = 0
    OR EXISTS (
      SELECT 1
      FROM metadata_records included_metadata
      INNER JOIN tags included_tags
        ON included_tags.id = included_metadata.metadata_id
      WHERE included_metadata.item_id = viewer_items.id
        AND included_metadata.type_id = ?
        AND lower(included_tags.name) IN (
          SELECT lower(CAST(value AS TEXT)) FROM json_each(?)
        )
    )
  )
  AND (
    json_array_length(?) = 0
    OR NOT EXISTS (
      SELECT 1
      FROM metadata_records excluded_metadata
      INNER JOIN tags excluded_tags
        ON excluded_tags.id = excluded_metadata.metadata_id
      WHERE excluded_metadata.item_id = viewer_items.id
        AND excluded_metadata.type_id = ?
        AND lower(excluded_tags.name) IN (
          SELECT lower(CAST(value AS TEXT)) FROM json_each(?)
        )
    )
  )
""";

const _topLevelSourceSql = """
SELECT id, type_id, relation_id, display_name, description, url, created_at,
       entity_created_at, updated_at, file_path, file_type, file_size,
       checksum, archive_org_url, archive_is_url, source_rank
FROM (
  SELECT id, 2 AS type_id, NULL AS relation_id, title AS display_name,
         description, NULL AS url, created_at, created_at AS entity_created_at,
         updated_at, NULL AS file_path, NULL AS file_type, NULL AS file_size,
         NULL AS checksum, NULL AS archive_org_url, NULL AS archive_is_url,
         0 AS source_rank
  FROM folders
  UNION ALL
  SELECT id, 0 AS type_id, NULL AS relation_id, path AS display_name,
         path AS description, path AS url, created_at,
         created_at AS entity_created_at, NULL AS updated_at,
         NULL AS file_path, NULL AS file_type, NULL AS file_size,
         NULL AS checksum, archive_org_url, archive_is_url, 0 AS source_rank
  FROM links
) AS viewer_items
""";

const _folderSourceSql = """
SELECT id, type_id, relation_id, display_name, description,
       url, created_at, entity_created_at, updated_at, file_path, file_type,
       file_size, checksum, archive_org_url, archive_is_url, source_rank
FROM (
  SELECT items.item_id AS id,
         items.type_id AS type_id,
         items.id AS relation_id,
         CASE items.type_id
           WHEN 0 THEN links.path
           WHEN 1 THEN documents.title
           WHEN 2 THEN folders.title
         END AS display_name,
         CASE items.type_id
           WHEN 0 THEN links.path
           WHEN 1 THEN documents.file_path
           WHEN 2 THEN folders.description
         END AS description,
         links.path AS url,
         items.created_at AS created_at,
         CASE items.type_id
           WHEN 0 THEN links.created_at
           WHEN 1 THEN documents.created_at
           WHEN 2 THEN folders.created_at
         END AS entity_created_at,
         CASE items.type_id
           WHEN 1 THEN documents.updated_at
           WHEN 2 THEN folders.updated_at
         END AS updated_at,
         documents.file_path AS file_path,
         documents.file_type AS file_type,
         documents.file_size AS file_size,
         documents.checksum AS checksum,
         links.archive_org_url AS archive_org_url,
         links.archive_is_url AS archive_is_url,
         1 AS source_rank
  FROM items
  LEFT JOIN links
    ON items.type_id = 0 AND links.id = items.item_id
  LEFT JOIN documents
    ON items.type_id = 1 AND documents.id = items.item_id
  LEFT JOIN folders
    ON items.type_id = 2 AND folders.id = items.item_id
  WHERE items.folder_id = ?
) AS viewer_items
""";

const _folderWithParentsSourceSql = """
SELECT id, type_id, relation_id, display_name, description,
       url, created_at, entity_created_at, updated_at, file_path, file_type,
       file_size, checksum, archive_org_url, archive_is_url, source_rank
FROM (
  SELECT id, type_id, relation_id, display_name, description,
         url, created_at, entity_created_at, updated_at, file_path, file_type,
         file_size, checksum, archive_org_url, archive_is_url, source_rank
  FROM (
    SELECT ranked_items.*,
         ROW_NUMBER() OVER (
           PARTITION BY ranked_items.type_id, ranked_items.id
           ORDER BY ranked_items.source_rank
         ) AS source_row
    FROM (
    SELECT parent_folders.id AS id,
           2 AS type_id,
           NULL AS relation_id,
           parent_folders.title AS display_name,
           parent_folders.description AS description,
           NULL AS url,
           parent_folders.created_at AS created_at,
           parent_folders.created_at AS entity_created_at,
           parent_folders.updated_at AS updated_at,
           NULL AS file_path,
           NULL AS file_type,
           NULL AS file_size,
           NULL AS checksum,
           NULL AS archive_org_url,
           NULL AS archive_is_url,
           0 AS source_rank
    FROM items AS parent_relations
    INNER JOIN folders AS parent_folders
      ON parent_folders.id = parent_relations.folder_id
    WHERE parent_relations.item_id = ?
      AND parent_relations.type_id = 2
    UNION ALL
    SELECT items.item_id AS id,
           items.type_id AS type_id,
           items.id AS relation_id,
           CASE items.type_id
             WHEN 0 THEN links.path
             WHEN 1 THEN documents.title
             WHEN 2 THEN folders.title
           END AS display_name,
           CASE items.type_id
             WHEN 0 THEN links.path
             WHEN 1 THEN documents.file_path
             WHEN 2 THEN folders.description
           END AS description,
           links.path AS url,
           items.created_at AS created_at,
           CASE items.type_id
             WHEN 0 THEN links.created_at
             WHEN 1 THEN documents.created_at
             WHEN 2 THEN folders.created_at
           END AS entity_created_at,
           CASE items.type_id
             WHEN 1 THEN documents.updated_at
             WHEN 2 THEN folders.updated_at
           END AS updated_at,
           documents.file_path AS file_path,
           documents.file_type AS file_type,
           documents.file_size AS file_size,
           documents.checksum AS checksum,
           links.archive_org_url AS archive_org_url,
           links.archive_is_url AS archive_is_url,
           1 AS source_rank
    FROM items
    LEFT JOIN links
      ON items.type_id = 0 AND links.id = items.item_id
    LEFT JOIN documents
      ON items.type_id = 1 AND documents.id = items.item_id
    LEFT JOIN folders
      ON items.type_id = 2 AND folders.id = items.item_id
    WHERE items.folder_id = ?
    ) AS ranked_items
  ) AS deduplicated_items
  WHERE source_row = 1
) AS viewer_items
""";

const _topLevelPageSql = _topLevelSourceSql +
    _viewerFilterSql +
    """
ORDER BY @ORDER_BY@
LIMIT ? OFFSET ?
""";

const _folderPageSql = _folderSourceSql +
    _viewerFilterSql +
    """
ORDER BY @ORDER_BY@
LIMIT ? OFFSET ?
""";

const _folderWithParentsPageSql = _folderWithParentsSourceSql +
    _viewerFilterSql +
    """
ORDER BY @ORDER_BY@
LIMIT ? OFFSET ?
""";

const _topLevelCountSql = """
SELECT COUNT(*) AS item_count
FROM (
""" +
    _topLevelSourceSql +
    _viewerFilterSql +
    """
)
""";

const _folderCountSql = """
SELECT COUNT(*) AS item_count
FROM (
""" +
    _folderSourceSql +
    _viewerFilterSql +
    """
)
""";

const _folderWithParentsCountSql = """
SELECT COUNT(*) AS item_count
FROM (
""" +
    _folderWithParentsSourceSql +
    _viewerFilterSql +
    """
)
""";

const _topLevelFacetSql = """
SELECT facet_tags.id AS tag_id,
       facet_tags.created_at AS tag_created_at,
       facet_tags.name AS tag_name,
       facet_tags.color AS tag_color,
       COUNT(*) AS item_count
FROM (
""" +
    _topLevelSourceSql +
    _viewerFilterSql +
    """
) AS filtered_items
INNER JOIN metadata_records facet_metadata
  ON facet_metadata.item_id = filtered_items.id
 AND facet_metadata.type_id = 0
INNER JOIN tags facet_tags
  ON facet_tags.id = facet_metadata.metadata_id
WHERE (? = '' OR instr(lower(facet_tags.name), lower(?)) > 0)
GROUP BY facet_tags.id, facet_tags.created_at, facet_tags.name, facet_tags.color
ORDER BY facet_tags.name COLLATE NOCASE, facet_tags.id
LIMIT ?
""";

const _folderFacetSql = """
SELECT facet_tags.id AS tag_id,
       facet_tags.created_at AS tag_created_at,
       facet_tags.name AS tag_name,
       facet_tags.color AS tag_color,
       COUNT(*) AS item_count
FROM (
""" +
    _folderSourceSql +
    _viewerFilterSql +
    """
) AS filtered_items
INNER JOIN metadata_records facet_metadata
  ON facet_metadata.item_id = filtered_items.id
 AND facet_metadata.type_id = 0
INNER JOIN tags facet_tags
  ON facet_tags.id = facet_metadata.metadata_id
WHERE (? = '' OR instr(lower(facet_tags.name), lower(?)) > 0)
GROUP BY facet_tags.id, facet_tags.created_at, facet_tags.name, facet_tags.color
ORDER BY facet_tags.name COLLATE NOCASE, facet_tags.id
LIMIT ?
""";

const _folderWithParentsFacetSql = """
SELECT facet_tags.id AS tag_id,
       facet_tags.created_at AS tag_created_at,
       facet_tags.name AS tag_name,
       facet_tags.color AS tag_color,
       COUNT(*) AS item_count
FROM (
""" +
    _folderWithParentsSourceSql +
    _viewerFilterSql +
    """
) AS filtered_items
INNER JOIN metadata_records facet_metadata
  ON facet_metadata.item_id = filtered_items.id
 AND facet_metadata.type_id = 0
INNER JOIN tags facet_tags
  ON facet_tags.id = facet_metadata.metadata_id
WHERE (? = '' OR instr(lower(facet_tags.name), lower(?)) > 0)
GROUP BY facet_tags.id, facet_tags.created_at, facet_tags.name, facet_tags.color
ORDER BY facet_tags.name COLLATE NOCASE, facet_tags.id
LIMIT ?
""";

const _loadTagsSql = """
SELECT item_id, tag_id, tag_created_at, tag_name, tag_color
FROM (
  SELECT metadata_records.item_id AS item_id,
         tags.id AS tag_id,
         tags.created_at AS tag_created_at,
         tags.name AS tag_name,
         tags.color AS tag_color,
         ROW_NUMBER() OVER (
           PARTITION BY metadata_records.item_id
           ORDER BY tags.name COLLATE NOCASE, tags.id
         ) AS tag_row
  FROM metadata_records
  INNER JOIN tags ON tags.id = metadata_records.metadata_id
  WHERE metadata_records.type_id = ?
    AND metadata_records.item_id IN (SELECT value FROM json_each(?))
)
WHERE tag_row <= ?
ORDER BY item_id, tag_name COLLATE NOCASE, tag_id
""";

const _loadItemTagsByNamesSql = """
SELECT tags.id AS tag_id,
       tags.created_at AS tag_created_at,
       tags.name AS tag_name,
       tags.color AS tag_color
FROM metadata_records
INNER JOIN tags ON tags.id = metadata_records.metadata_id
WHERE metadata_records.item_id = ?
  AND metadata_records.type_id = ?
  AND lower(tags.name) IN (
    SELECT lower(CAST(value AS TEXT)) FROM json_each(?)
  )
ORDER BY tags.name COLLATE NOCASE, tags.id
""";

const _createSelectionTableSql = """
CREATE TEMP TABLE IF NOT EXISTS viewer_selection_keys (
  session_id TEXT NOT NULL,
  type_id INTEGER NOT NULL,
  item_id TEXT NOT NULL,
  relation_id TEXT,
  added_at TEXT,
  PRIMARY KEY (session_id, type_id, item_id)
)
""";

const _insertSelectionKeySql = """
INSERT OR IGNORE INTO viewer_selection_keys (session_id, type_id, item_id)
VALUES (?, ?, ?)
""";

const _deleteSelectionKeySql = """
DELETE FROM viewer_selection_keys
WHERE session_id = ? AND type_id = ? AND item_id = ?
""";

const _releaseSelectionSql = """
DELETE FROM viewer_selection_keys WHERE session_id = ?
""";

const _selectionCountSql = """
SELECT COUNT(*) AS item_count
FROM viewer_selection_keys AS selection
WHERE selection.session_id = ?
  AND (
    (selection.type_id = 0 AND EXISTS (
      SELECT 1 FROM links WHERE links.id = selection.item_id
    ))
    OR (selection.type_id = 1 AND EXISTS (
      SELECT 1 FROM documents WHERE documents.id = selection.item_id
    ))
    OR (selection.type_id = 2 AND EXISTS (
      SELECT 1 FROM folders WHERE folders.id = selection.item_id
    ))
  )
""";

const _populateTopLevelSelectionSql = """
INSERT OR IGNORE INTO viewer_selection_keys (
  session_id, type_id, item_id, relation_id, added_at
)
SELECT ?, type_id, id, relation_id, created_at
FROM (
""" +
    _topLevelSourceSql +
    _viewerFilterSql +
    """
)
""";

const _populateFolderSelectionSql = """
INSERT OR IGNORE INTO viewer_selection_keys (
  session_id, type_id, item_id, relation_id, added_at
)
SELECT ?, type_id, id, relation_id, created_at
FROM (
""" +
    _folderSourceSql +
    _viewerFilterSql +
    """
)
""";

const _populateFolderWithParentsSelectionSql = """
INSERT OR IGNORE INTO viewer_selection_keys (
  session_id, type_id, item_id, relation_id, added_at
)
SELECT ?, type_id, id, relation_id, created_at
FROM (
""" +
    _folderWithParentsSourceSql +
    _viewerFilterSql +
    """
)
""";

const _selectionBatchSql = """
SELECT item_id AS id, type_id, relation_id, display_name, description, url,
       created_at, entity_created_at, updated_at, file_path, file_type,
       file_size, checksum, archive_org_url, archive_is_url
FROM (
  SELECT selection.item_id AS item_id,
         selection.type_id AS type_id,
         selection.relation_id AS relation_id,
         CASE selection.type_id
           WHEN 0 THEN links.path
           WHEN 1 THEN documents.title
           WHEN 2 THEN folders.title
         END AS display_name,
         CASE selection.type_id
           WHEN 0 THEN links.path
           WHEN 1 THEN documents.file_path
           WHEN 2 THEN folders.description
         END AS description,
         links.path AS url,
         COALESCE(
           selection.added_at,
           CASE selection.type_id
             WHEN 0 THEN links.created_at
             WHEN 1 THEN documents.created_at
             WHEN 2 THEN folders.created_at
           END
         ) AS created_at,
         CASE selection.type_id
           WHEN 0 THEN links.created_at
           WHEN 1 THEN documents.created_at
           WHEN 2 THEN folders.created_at
         END AS entity_created_at,
         CASE selection.type_id
           WHEN 1 THEN documents.updated_at
           WHEN 2 THEN folders.updated_at
         END AS updated_at,
         documents.file_path AS file_path,
         documents.file_type AS file_type,
         documents.file_size AS file_size,
         documents.checksum AS checksum,
         links.archive_org_url AS archive_org_url,
         links.archive_is_url AS archive_is_url
  FROM viewer_selection_keys selection
  LEFT JOIN links
    ON selection.type_id = 0 AND links.id = selection.item_id
  LEFT JOIN documents
    ON selection.type_id = 1 AND documents.id = selection.item_id
  LEFT JOIN folders
    ON selection.type_id = 2 AND folders.id = selection.item_id
  WHERE selection.session_id = ?
) AS selected_items
WHERE display_name IS NOT NULL
ORDER BY type_id, item_id
LIMIT ?
""";
