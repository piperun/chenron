import "package:catalog/catalog.dart";
import "package:database/database.dart";
import "package:database/features.dart";

/// The one axis chenron filters on. Never shown to a reader.
const String chenronTagDimension = "tag";

/// That axis as a reader sees it.
const String chenronTagDimensionLabel = "Tags";

/// A [CatalogFacet] that keeps the [Tag] it was built from.
///
/// For a chenron tag both halves of the generic type are the tag's name: the
/// query filters on it, and it is what a reader sees. The rest of the [Tag] —
/// its id and its colour — has nowhere to go in the four generic fields, and
/// the tag-filter modal renders it. So it rides along here, and
/// [chenronTagsOf] takes it back out.
class ChenronTagFacet extends CatalogFacet {
  ChenronTagFacet(this.tag, int itemCount)
      : super(
          dimension: chenronTagDimension,
          value: tag.name,
          label: tag.name,
          itemCount: itemCount,
        );

  final Tag tag;
}

/// The [Tag]s inside [groups], in the order the source returned them.
///
/// Flattens because chenron has exactly one axis: every facet it will ever see
/// is a tag, so there is nothing for a caller to choose between.
List<Tag> chenronTagsOf(List<CatalogFacetGroup> groups) => groups
    .expand((group) => group.facets)
    .whereType<ChenronTagFacet>()
    .map((facet) => facet.tag)
    .toList(growable: false);

/// Reads chenron's viewer tables as a [CatalogSource].
///
/// A mixin rather than a class because chenron has three of these — the
/// viewer's model, the folder viewer's service, and the memory profile's
/// probe — that differ only in which [AppDatabase] they reach and what else
/// they do. Each supplies [catalogDatabase] and gets the whole source
/// contract; each keeps its own identity, so every call site that passed one
/// as a repository passes it as a source unchanged.
mixin ChenronCatalogSource
    implements
        CatalogSource<FolderItem, ViewerQuery>,
        CatalogFacetSearch<ViewerQuery>,
        CatalogSelectionLeases<FolderItem, ViewerQuery>,
        CatalogInvalidationDomain {
  /// The database every method below delegates to.
  AppDatabase get catalogDatabase;

  /// Two sources reading the same database share one coordinator, so a bulk
  /// edit refreshes each pager once rather than once per source.
  @override
  Object get invalidationDomain => catalogDatabase;

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) =>
      catalogDatabase.getViewerPage(query, limit: limit, offset: offset);

  @override
  Future<int> count(ViewerQuery query) =>
      catalogDatabase.getViewerItemCount(query);

  /// The unsearched case of [searchFacets]. The database takes an empty
  /// search text to mean "all of them", which is what this asks for.
  @override
  Future<List<CatalogFacetGroup>> loadFacets(ViewerQuery query) =>
      searchFacets(query);

  /// Always one group, even when it is empty.
  ///
  /// The tag axis is a property of this source, not of the query: chenron can
  /// filter on tags whether or not the current query matched any. An axis that
  /// vanished when it happened to be empty would be a different claim.
  @override
  Future<List<CatalogFacetGroup>> searchFacets(
    ViewerQuery query, {
    String searchText = "",
  }) async {
    final facets = await catalogDatabase.getViewerTagFacets(
      query,
      searchText: searchText,
    );
    return <CatalogFacetGroup>[
      CatalogFacetGroup(
        dimension: chenronTagDimension,
        label: chenronTagDimensionLabel,
        facets: <CatalogFacet>[
          for (final facet in facets)
            ChenronTagFacet(facet.tag, facet.itemCount),
        ],
      ),
    ];
  }

  @override
  Stream<void> invalidations() => catalogDatabase.watchViewerInvalidations();

  @override
  Future<CatalogSelectionLease> createSelectionLease({
    required ViewerQuery query,
    Set<Object>? onlyKeys,
    Set<Object> excludedKeys = const <Object>{},
  }) async =>
      CatalogSelectionLease(
        await catalogDatabase.createViewerSelectionLease(
          query: query,
          onlyKeys: onlyKeys?.cast<ViewerItemKey>().toSet(),
          excludedKeys: excludedKeys.cast<ViewerItemKey>().toSet(),
        ),
      );

  @override
  Future<List<FolderItem>> loadSelectionLeaseBatch(
    CatalogSelectionLease lease, {
    required int limit,
  }) =>
      catalogDatabase.getViewerSelectionLeaseBatch(
        _viewerLease(lease),
        limit: limit,
      );

  @override
  Future<int> countSelectionLease(CatalogSelectionLease lease) =>
      catalogDatabase.getViewerSelectionLeaseCount(_viewerLease(lease));

  @override
  Future<void> consumeSelectionLeaseBatch(
    CatalogSelectionLease lease,
    Iterable<Object> consumed,
  ) =>
      catalogDatabase.consumeViewerSelectionLeaseBatch(
        _viewerLease(lease),
        consumed.cast<ViewerItemKey>(),
      );

  @override
  Future<void> releaseSelectionLease(CatalogSelectionLease lease) =>
      catalogDatabase.releaseViewerSelectionLease(_viewerLease(lease));
}

/// A lease id means something only to the source that issued it, and this
/// source puts the database's own lease there rather than a copy of its id.
ViewerSelectionLease _viewerLease(CatalogSelectionLease lease) =>
    lease.id as ViewerSelectionLease;
