import "dart:async";

import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/tag_filter/tag_filter_notifier.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter_test/flutter_test.dart";

FolderItem _folderItem(String id) => FolderItem.folder(
      id: id,
      itemId: null,
      folderId: id,
      title: "Folder $id",
      description: "",
      createdAt: DateTime(2026, 8, 10),
      tags: const <Tag>[],
    );

class _FakeViewerRepository implements ViewerPageRepository {
  final List<ViewerQuery> countQueries = <ViewerQuery>[];
  final List<ViewerQuery> facetQueries = <ViewerQuery>[];
  final List<ViewerQuery> pageQueries = <ViewerQuery>[];
  late final StreamController<void> invalidationController =
      StreamController<void>.broadcast(
    onListen: () => activeSubscriptions++,
    onCancel: () => activeSubscriptions--,
  );

  int activeSubscriptions = 0;

  @override
  Future<int> count(ViewerQuery query) async {
    countQueries.add(query);
    return 100000;
  }

  @override
  Future<List<ViewerTagFacet>> loadTagFacets(ViewerQuery query) async {
    facetQueries.add(query);
    return const <ViewerTagFacet>[];
  }

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) async {
    pageQueries.add(query);
    return <FolderItem>[_folderItem("item-$offset")];
  }

  @override
  Stream<void> invalidations() => invalidationController.stream;

  @override
  Future<ViewerSelectionLease> createSelectionLease({
    required ViewerQuery query,
    Set<ViewerItemKey>? onlyKeys,
    Set<ViewerItemKey> excludedKeys = const <ViewerItemKey>{},
  }) =>
      throw UnimplementedError();

  @override
  Future<List<FolderItem>> loadSelectionLeaseBatch(
    ViewerSelectionLease lease, {
    required int limit,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> consumeSelectionLeaseBatch(
    ViewerSelectionLease lease,
    Iterable<ViewerItemKey> consumed,
  ) =>
      throw UnimplementedError();

  @override
  Future<void> releaseSelectionLease(ViewerSelectionLease lease) =>
      throw UnimplementedError();

  Future<void> dispose() => invalidationController.close();
}

void main() {
  late _FakeViewerRepository repository;
  late ViewerPresenter presenter;

  setUp(() {
    repository = _FakeViewerRepository();
  });

  tearDown(() async {
    presenter.dispose();
    await presenter.pageSource.invalidationCancellation;
    await repository.dispose();
  });

  test("init applies one top-level query without a list stream", () async {
    presenter = ViewerPresenter(repository: repository);

    await presenter.init();
    await presenter.init();

    expect(repository.countQueries, hasLength(1));
    expect(repository.facetQueries, hasLength(1));
    expect(presenter.query.value.folderId, isNull);
    expect(presenter.pageSource, isA<ViewerPageSource>());
    expect(repository.activeSubscriptions, 1);
  });

  test("search, type, tag, and sort changes replace ViewerQuery", () async {
    final searchFilter = SearchFilter();
    final tagFilter = TagFilterNotifier();
    addTearDown(searchFilter.dispose);
    addTearDown(tagFilter.dispose);
    presenter = ViewerPresenter(
      repository: repository,
      searchFilter: searchFilter,
      tagFilterState: tagFilter,
    );
    await presenter.init();

    searchFilter.controller.value = "needle #inline -#blocked";
    tagFilter.addIncluded("chosen");
    tagFilter.addExcluded("hidden");
    presenter.onTypesChanged(const <FolderItemType>{FolderItemType.folder});
    presenter.onSortChanged(SortMode.dateDesc);
    await Future<void>.delayed(Duration.zero);

    expect(
      presenter.query.value,
      const ViewerQuery(
        searchText: "needle",
        types: <FolderItemType>{FolderItemType.folder},
        includedTags: <String>{"inline", "chosen"},
        excludedTags: <String>{"blocked", "hidden"},
        sort: ViewerSort.dateDesc,
      ),
    );
    expect(repository.countQueries.last, presenter.query.value);
    expect(repository.facetQueries.last, presenter.query.value);
  });

  test("folder presenter keeps the folder scope across query changes",
      () async {
    final searchFilter = SearchFilter();
    addTearDown(searchFilter.dispose);
    presenter = ViewerPresenter(
      repository: repository,
      searchFilter: searchFilter,
      folderId: "folder-1",
    );
    await presenter.init();

    searchFilter.controller.value = "child";
    await Future<void>.delayed(Duration.zero);

    expect(presenter.query.value.folderId, "folder-1");
    expect(presenter.query.value.searchText, "child");
    expect(repository.countQueries.last.folderId, "folder-1");
  });

  test("dispose releases page rows, subscription, effects, and signals",
      () async {
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();

    expect(presenter.pageSource.itemAt(0), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(presenter.retentionSnapshot.retainedRows, 1);
    expect(presenter.retentionSnapshot.activeSubscriptions, 1);

    presenter.dispose();
    await presenter.pageSource.invalidationCancellation;

    expect(presenter.retentionSnapshot.retainedRows, 0);
    expect(presenter.retentionSnapshot.activeSubscriptions, 0);
    expect(presenter.retentionSnapshot.disposed, isTrue);
    expect(presenter.query.disposed, isTrue);
    expect(presenter.viewMode.disposed, isTrue);
    expect(presenter.sortMode.disposed, isTrue);
    expect(presenter.selectedTypes.disposed, isTrue);
    expect(presenter.selectedItemIds.disposed, isTrue);
    expect(presenter.pageSource.revision.disposed, isTrue);
  });

  test("dispose is idempotent", () async {
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();

    presenter.dispose();

    expect(presenter.dispose, returnsNormally);
  });
}
