import "dart:async";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:catalog/catalog.dart";
import "package:chenron/features/viewer/state/chenron_catalog_source.dart";
import "package:chenron/features/viewer/ui/paged_viewer_display.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/item_display/item_list_view.dart";
import "package:chenron/shared/item_display/widgets/selectable_item_wrapper.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "viewer_test.mocks.dart";

/// The single group chenron's own source publishes, so the fake hands the
/// display the shape it sees in the app.
List<CatalogFacetGroup> _tagGroups(List<ViewerTagFacet> facets) =>
    <CatalogFacetGroup>[
      CatalogFacetGroup(
        dimension: chenronTagDimension,
        label: chenronTagDimensionLabel,
        facets: <CatalogFacet>[
          for (final facet in facets)
            ChenronTagFacet(facet.tag, facet.itemCount),
        ],
      ),
    ];

FolderItem _folderItem(int index) => FolderItem.folder(
      id: "folder-$index",
      itemId: null,
      folderId: "folder-$index",
      title: "Folder $index",
      description: "",
      createdAt: DateTime(2026, 8, 10),
      tags: const <Tag>[],
    );

class _PagedRepository implements
        CatalogSource<FolderItem, ViewerQuery>,
        CatalogSelectionLeases<FolderItem, ViewerQuery> {
  final List<({int limit, int offset})> pageRequests = [];
  final StreamController<void> invalidationController =
      StreamController<void>.broadcast();
  Completer<List<FolderItem>>? pageGate;
  Completer<int>? countGate;
  Completer<List<ViewerTagFacet>>? facetGate;
  bool failNextPage = false;
  bool failNextCount = false;
  bool failNextFacets = false;
  int countCalls = 0;
  int facetCalls = 0;
  int totalItemCount = 100000;
  List<FolderItem>? pageRows;
  List<ViewerTagFacet> facets = const <ViewerTagFacet>[];

  @override
  Future<int> count(ViewerQuery query) async {
    countCalls++;
    if (failNextCount) {
      failNextCount = false;
      throw StateError("count failed");
    }
    final gate = countGate;
    if (gate != null) return gate.future;
    return totalItemCount;
  }

  @override
  Future<List<CatalogFacetGroup>> loadFacets(ViewerQuery query) async {
    facetCalls++;
    if (failNextFacets) {
      failNextFacets = false;
      throw StateError("facets failed");
    }
    final gate = facetGate;
    return _tagGroups(gate == null ? facets : await gate.future);
  }

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) async {
    pageRequests.add((limit: limit, offset: offset));
    if (failNextPage) {
      failNextPage = false;
      throw StateError("page failed");
    }
    final gate = pageGate;
    if (gate != null) return gate.future;
    final configuredRows = pageRows;
    if (configuredRows != null) {
      return configuredRows.skip(offset).take(limit).toList(growable: false);
    }
    return List<FolderItem>.generate(
      limit,
      (index) => _folderItem(offset + index),
    );
  }

  @override
  Stream<void> invalidations() => invalidationController.stream;

  @override
  Future<CatalogSelectionLease> createSelectionLease({
    required ViewerQuery query,
    Set<Object>? onlyKeys,
    Set<Object> excludedKeys = const <Object>{},
  }) =>
      throw UnimplementedError();

  @override
  Future<List<FolderItem>> loadSelectionLeaseBatch(
    CatalogSelectionLease lease, {
    required int limit,
  }) =>
      throw UnimplementedError();

  @override
  Future<int> countSelectionLease(CatalogSelectionLease lease) =>
      throw UnimplementedError();

  @override
  Future<void> consumeSelectionLeaseBatch(
    CatalogSelectionLease lease,
    Iterable<Object> consumed,
  ) =>
      throw UnimplementedError();

  @override
  Future<void> releaseSelectionLease(CatalogSelectionLease lease) =>
      throw UnimplementedError();

  Future<void> dispose() => invalidationController.close();
}

Widget _host(
  ViewerPresenter presenter, {
  ValueChanged<CatalogSelectionTarget<ViewerItemKey, ViewerQuery>>?
      onDeleteRequested,
}) =>
    MaterialApp(
      home: Scaffold(
        body: PagedViewerDisplay(
          presenter: presenter,
          showSearch: false,
          onDeleteRequested: onDeleteRequested,
        ),
      ),
    );

void _unmountAfterTest(WidgetTester tester) {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

Future<void> _useWideSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1600, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  late _PagedRepository repository;
  late ViewerPresenter presenter;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await locator.reset();
    locator.registerSingleton<SettingsCoordinator>(SettingsCoordinator(
      configService: MockConfigService(),
      dataService: MockDataSettingsService(),
      themeApplier: MockThemeNotifier(),
      optionsStore: ThemeOptionsStore(),
    ));
  });

  tearDown(() async {
    presenter.dispose();
    await presenter.pageSource.invalidationCancellation;
    await repository.dispose();
    await locator.reset();
  });

  testWidgets("100,000 logical rows build only visible widgets and page zero",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    repository = _PagedRepository();
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();

    await tester.pumpWidget(_host(presenter));
    await tester.pump();
    await tester.pump();

    final builtItems = find.byType(ViewerItem).evaluate().length;
    expect(builtItems, greaterThan(0));
    expect(builtItems, lessThan(100));
    expect(repository.pageRequests, isNotEmpty);
    expect(
      repository.pageRequests.map((request) => request.offset).toSet(),
      {0},
    );
    expect(
      repository.pageRequests.every((request) => request.limit == 100),
      isTrue,
    );
    expect(presenter.pageSource.cachedRowCount, 100);
  });

  testWidgets("null rows render bounded loading skeletons", (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    repository = _PagedRepository()..pageGate = Completer<List<FolderItem>>();
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();

    await tester.pumpWidget(_host(presenter));
    await tester.pump();

    expect(
      find.byKey(const ValueKey("item-viewport-loading-0")),
      findsOneWidget,
    );

    repository.pageGate!.complete(<FolderItem>[_folderItem(0)]);
    await tester.pump();
    await tester.pump();
  });

  testWidgets("failed rows expose retry and recover in place", (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    repository = _PagedRepository()..failNextPage = true;
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();

    await tester.pumpWidget(_host(presenter));
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey("item-viewport-retry-0")),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey("item-viewport-retry-0")));
    await tester.pump();
    await tester.pump();

    expect(repository.pageRequests, hasLength(2));
    expect(find.byType(ViewerItem), findsWidgets);
  });

  testWidgets("count failure shows a retry state and recovers rows",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    repository = _PagedRepository()..failNextCount = true;
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();

    await tester.pumpWidget(_host(presenter));
    await tester.pump();

    expect(
      find.byKey(const ValueKey("viewer-summary-error")),
      findsOneWidget,
    );
    expect(find.text("Unable to load items."), findsOneWidget);
    expect(find.byType(ViewerItem), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey("viewer-summary-retry")),
    );
    await tester.pump();
    await tester.pump();

    expect(repository.countCalls, 2);
    expect(
      find.byKey(const ValueKey("viewer-summary-error")),
      findsNothing,
    );
    expect(find.byType(ViewerItem), findsWidgets);
  });

  testWidgets("visible count retry queues while facets remain pending",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    final countRetryGate = Completer<int>();
    final facetGate = Completer<List<ViewerTagFacet>>();
    repository = _PagedRepository()
      ..failNextCount = true
      ..countGate = countRetryGate
      ..facetGate = facetGate;
    presenter = ViewerPresenter(repository: repository);
    final initialization = presenter.init();

    try {
      for (var attempt = 0; attempt < 20; attempt++) {
        await tester.pump();
        if (presenter.pageSource.countError.value != null) break;
      }
      await tester.pumpWidget(_host(presenter));
      await tester.pump();
      expect(
        find.byKey(const ValueKey("viewer-summary-error")),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey("viewer-summary-retry")),
      );
      await tester.pump();

      expect(repository.countCalls, 1);
      expect(repository.facetCalls, 1);
      expect(presenter.pageSource.activeSummaryLoadCount, 1);
      expect(presenter.pageSource.hasDirtySummaryRefresh, isTrue);
      expect(presenter.pageSource.countError.value, isA<StateError>());

      facetGate.complete(const <ViewerTagFacet>[]);
      await initialization;
      for (var attempt = 0; attempt < 20; attempt++) {
        await tester.pump();
        if (repository.countCalls == 2) break;
      }
      expect(repository.countCalls, 2);
      expect(presenter.pageSource.activeSummaryLoadCount, 1);

      countRetryGate.complete(100000);
      await tester.pump();
      await tester.pump();

      expect(
        find.byKey(const ValueKey("viewer-summary-error")),
        findsNothing,
      );
      expect(presenter.pageSource.activeSummaryLoadCount, 0);
    } finally {
      if (!countRetryGate.isCompleted) countRetryGate.complete(100000);
      if (!facetGate.isCompleted) {
        facetGate.complete(const <ViewerTagFacet>[]);
      }
      await initialization;
    }
  });

  testWidgets("facet failure keeps rows visible and recovers tag modal",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    repository = _PagedRepository()
      ..failNextFacets = true
      ..facets = <ViewerTagFacet>[
        ViewerTagFacet(
          tag: Tag(
            id: "tag-id-not-name",
            name: "topic",
            createdAt: DateTime.utc(2026, 1, 1),
          ),
          itemCount: 3,
        ),
      ];
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();

    await tester.pumpWidget(_host(presenter));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ViewerItem), findsWidgets);
    expect(find.text("Unable to load tag filters."), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey("viewer-summary-retry")),
    );
    await tester.pump();
    await tester.pump();

    expect(repository.countCalls, 1);
    expect(repository.facetCalls, 2);
    expect(
      find.byKey(const ValueKey("viewer-summary-error")),
      findsNothing,
    );
    expect(find.byType(ViewerItem), findsWidgets);

    await tester.tap(find.text("Tags"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Available Tags"));
    await tester.pumpAndSettle();
    expect(find.text("topic"), findsOneWidget);
  });

  testWidgets("list mode remains lazy over the same virtual source",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{
      "view_mode_preference": "list",
    });
    repository = _PagedRepository();
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();

    await tester.pumpWidget(_host(presenter));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ItemListView), findsOneWidget);
    expect(find.byType(ViewerItem), findsWidgets);
    expect(find.byType(ViewerItem).evaluate().length, lessThan(100));
    expect(
      repository.pageRequests.map((request) => request.offset).toSet(),
      {0},
    );
  });

  testWidgets("select-all captures 100,000 query rows without page visits",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    repository = _PagedRepository();
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();
    CatalogSelectionTarget<ViewerItemKey, ViewerQuery>? requested;

    await tester.pumpWidget(_host(
      presenter,
      onDeleteRequested: (target) => requested = target,
    ));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text("Select"));
    await tester.pump();
    repository.pageRequests.clear();

    await tester.tap(find.text("Select All"));
    await tester.pump();

    expect(find.text("100000 selected"), findsOneWidget);
    expect(repository.pageRequests, isEmpty);
    expect(presenter.selectionState.value, isA<CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>>());
    final selection =
        presenter.selectionState.value as CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>;
    expect(selection.query, presenter.query.value);
    expect(selection.totalCount, 100000);

    await tester.tap(find.text("Delete (100000)"));
    expect(requested, isNotNull);
    expect(requested!.selection, same(selection));
    expect(requested!.selectedCount, 100000);
  });

  testWidgets("select-all stays disabled until the current count is ready",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    final countGate = Completer<int>();
    repository = _PagedRepository()..countGate = countGate;
    presenter = ViewerPresenter(repository: repository);
    final initialization = presenter.init();

    try {
      await tester.pumpWidget(_host(
        presenter,
        onDeleteRequested: (_) {},
      ));
      await tester.pump();
      await tester.tap(find.text("Select"));
      await tester.pump();

      var selectAll = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, "Select All"),
      );
      expect(selectAll.onPressed, isNull);
      expect(presenter.selectionState.selectedCount, 0);

      countGate.complete(37);
      await initialization;
      await tester.pump();

      selectAll = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, "Select All"),
      );
      expect(selectAll.onPressed, isNotNull);
      await tester.tap(find.text("Select All"));
      await tester.pump();
      expect(find.text("37 selected"), findsOneWidget);
    } finally {
      if (!countGate.isCompleted) countGate.complete(37);
      await initialization;
    }
  });

  testWidgets("summary invalidation clears select-all until reselected",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    repository = _PagedRepository()..totalItemCount = 100;
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();
    final refreshedCount = Completer<int>();

    await tester.pumpWidget(_host(
      presenter,
      onDeleteRequested: (_) {},
    ));
    await tester.pump();
    await tester.tap(find.text("Select"));
    await tester.pump();
    await tester.tap(find.text("Select All"));
    await tester.pump();
    expect(find.text("100 selected"), findsOneWidget);

    repository.countGate = refreshedCount;
    repository.invalidationController.add(null);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(presenter.pageSource.summaryGeneration.value, 2);
    expect(presenter.selectionState.selectedCount, 0);
    expect(find.text("None selected"), findsOneWidget);
    var selectAll = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, "Select All"),
    );
    expect(selectAll.onPressed, isNull);

    refreshedCount.complete(75);
    await tester.pump();
    await tester.pump();
    selectAll = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, "Select All"),
    );
    expect(selectAll.onPressed, isNotNull);
    await tester.tap(find.text("Select All"));
    await tester.pump();
    expect(find.text("75 selected"), findsOneWidget);
  });

  testWidgets(
      "folder select-all keeps virtual parent keys in the query selection",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    final parent = _folderItem(999999);
    repository = _PagedRepository()
      ..totalItemCount = 100001
      ..pageRows = <FolderItem>[parent];
    presenter = ViewerPresenter(
      repository: repository,
      folderId: "folder-current",
    );
    await presenter.init();
    CatalogSelectionTarget<ViewerItemKey, ViewerQuery>? requested;

    await tester.pumpWidget(_host(
      presenter,
      onDeleteRequested: (target) => requested = target,
    ));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text("Select"));
    await tester.pump();
    repository.pageRequests.clear();

    await tester.tap(find.text("Select All"));
    await tester.pump();
    await tester.tap(find.text("Delete (100001)"));

    expect(repository.pageRequests, isEmpty);
    expect(requested, isNotNull);
    expect(requested!.selection, isA<CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>>());
    expect(
      (requested!.selection as CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>).totalCount,
      100001,
    );
    expect(requested!.selectedCount, 100001);
  });

  testWidgets("query changes clear a query-backed selection", (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    repository = _PagedRepository();
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();

    await tester.pumpWidget(_host(
      presenter,
      onDeleteRequested: (_) {},
    ));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text("Select"));
    await tester.pump();
    await tester.tap(find.text("Select All"));
    await tester.pump();
    expect(find.text("100000 selected"), findsOneWidget);

    presenter.onSearchSubmitted("changed");
    await tester.pump();
    await tester.pump();

    expect(find.text("None selected"), findsOneWidget);
    expect(presenter.selectionState.selectedCount, 0);
  });

  testWidgets("same-id rows of different types select as distinct keys",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    final document = FolderItem.document(
      id: "same-id",
      itemId: null,
      title: "Same ID document",
      filePath: "same-id.txt",
      createdAt: DateTime.utc(2026, 8, 10),
      tags: const <Tag>[],
    );
    final folder = FolderItem.folder(
      id: "same-id",
      itemId: null,
      folderId: "same-id",
      title: "Same ID folder",
      description: "",
      createdAt: DateTime.utc(2026, 8, 10),
      tags: const <Tag>[],
    );
    repository = _PagedRepository()
      ..totalItemCount = 2
      ..pageRows = <FolderItem>[document, folder];
    presenter = ViewerPresenter(repository: repository);
    await presenter.init();
    CatalogSelectionTarget<ViewerItemKey, ViewerQuery>? requested;

    await tester.pumpWidget(_host(
      presenter,
      onDeleteRequested: (target) => requested = target,
    ));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text("Select"));
    await tester.pump();

    final rows = find.byType(SelectableItemWrapper);
    expect(rows, findsNWidgets(2));
    await tester.tap(rows.at(0));
    await tester.pump();
    await tester.tap(rows.at(1));
    await tester.pump();
    await tester.tap(find.text("Delete (2)"));

    expect(requested, isNotNull);
    expect(
      (requested!.selection as CatalogExplicitSelection<ViewerItemKey, ViewerQuery>).keys,
      <ViewerItemKey>{
        (type: FolderItemType.document, id: "same-id"),
        (type: FolderItemType.folder, id: "same-id"),
      },
    );
  });

  testWidgets("manual selection cap explains how to select the full result",
      (tester) async {
    _unmountAfterTest(tester);
    await _useWideSurface(tester);
    repository = _PagedRepository()
      ..totalItemCount = 2
      ..pageRows = <FolderItem>[_folderItem(0), _folderItem(1)];
    presenter = ViewerPresenter(
      repository: repository,
      selectionState: CatalogSelectionState<ViewerItemKey, ViewerQuery>(
        maxManualKeys: 1,
      ),
    );
    await presenter.init();

    await tester.pumpWidget(_host(
      presenter,
      onDeleteRequested: (_) {},
    ));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text("Select"));
    await tester.pump();

    final rows = find.byType(SelectableItemWrapper);
    await tester.tap(rows.at(0));
    await tester.pump();
    await tester.tap(rows.at(1));
    await tester.pump();

    expect(presenter.selectionState.selectedCount, 1);
    expect(
      find.text("Manual selection is limited to 1 item. Use Select All."),
      findsOneWidget,
    );
  });
}
