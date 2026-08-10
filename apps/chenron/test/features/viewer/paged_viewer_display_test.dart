import "dart:async";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/features/viewer/ui/paged_viewer_display.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/item_display/item_list_view.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "viewer_test.mocks.dart";

FolderItem _folderItem(int index) => FolderItem.folder(
      id: "folder-$index",
      itemId: null,
      folderId: "folder-$index",
      title: "Folder $index",
      description: "",
      createdAt: DateTime(2026, 8, 10),
      tags: const <Tag>[],
    );

class _PagedRepository implements ViewerPageRepository {
  final List<({int limit, int offset})> pageRequests = [];
  final StreamController<void> invalidationController =
      StreamController<void>.broadcast();
  Completer<List<FolderItem>>? pageGate;
  bool failNextPage = false;
  bool failNextCount = false;
  bool failNextFacets = false;
  int countCalls = 0;
  int facetCalls = 0;
  List<ViewerTagFacet> facets = const <ViewerTagFacet>[];

  @override
  Future<int> count(ViewerQuery query) async {
    countCalls++;
    if (failNextCount) {
      failNextCount = false;
      throw StateError("count failed");
    }
    return 100000;
  }

  @override
  Future<List<ViewerTagFacet>> loadTagFacets(ViewerQuery query) async {
    facetCalls++;
    if (failNextFacets) {
      failNextFacets = false;
      throw StateError("facets failed");
    }
    return facets;
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
    return List<FolderItem>.generate(
      limit,
      (index) => _folderItem(offset + index),
    );
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

Widget _host(ViewerPresenter presenter) => MaterialApp(
      home: Scaffold(
        body: PagedViewerDisplay(
          presenter: presenter,
          showSearch: false,
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
}
