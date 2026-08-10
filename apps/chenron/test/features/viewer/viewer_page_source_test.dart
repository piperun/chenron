import "dart:async";

import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";

typedef _PageLoader = Future<List<FolderItem>> Function(
  ViewerQuery query,
  int limit,
  int offset,
);

class _FakeViewerPageRepository implements ViewerPageRepository {
  _FakeViewerPageRepository({
    this.pageLoader,
    this.cancellationGate,
    this.cancellationError,
  });

  final _PageLoader? pageLoader;
  final Completer<void>? cancellationGate;
  final Object? cancellationError;
  final Set<StreamController<void>> _invalidationControllers =
      <StreamController<void>>{};
  final Completer<void> cancellationRequested = Completer<void>();
  final Completer<void> cancellationFinished = Completer<void>();
  final Map<int, int> pageCalls = <int, int>{};
  int countCalls = 0;
  int facetCalls = 0;
  int activeInvalidationListeners = 0;
  int cancellationRequests = 0;

  void invalidate() {
    for (final controller in _invalidationControllers) {
      controller.add(null);
    }
  }

  Future<void> close() async {
    for (final controller in _invalidationControllers.toList()) {
      await controller.close();
    }
    _invalidationControllers.clear();
  }

  Future<void> _handleCancellation() async {
    cancellationRequests++;
    if (!cancellationRequested.isCompleted) cancellationRequested.complete();
    try {
      final gate = cancellationGate;
      if (gate != null) await gate.future;
      final cancellationFailure = cancellationError;
      if (cancellationFailure != null) throw cancellationFailure;
    } finally {
      activeInvalidationListeners--;
      if (!cancellationFinished.isCompleted) cancellationFinished.complete();
    }
  }

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) async {
    pageCalls.update(offset, (value) => value + 1, ifAbsent: () => 1);
    final loader = pageLoader;
    if (loader != null) return loader(query, limit, offset);
    return List<FolderItem>.generate(
      limit,
      (index) => _item(offset + index),
    );
  }

  @override
  Future<int> count(ViewerQuery query) async {
    countCalls++;
    return 100000;
  }

  @override
  Future<List<ViewerTagFacet>> loadTagFacets(ViewerQuery query) async {
    facetCalls++;
    return const <ViewerTagFacet>[];
  }

  @override
  Stream<void> invalidations() {
    late final StreamController<void> controller;
    controller = StreamController<void>(
      onListen: () => activeInvalidationListeners++,
      onCancel: () async {
        try {
          await _handleCancellation();
        } finally {
          _invalidationControllers.remove(controller);
        }
      },
    );
    _invalidationControllers.add(controller);
    return controller.stream;
  }

  @override
  Future<ViewerSelectionLease> createSelectionLease({
    required ViewerQuery query,
    Set<ViewerItemKey>? onlyKeys,
    Set<ViewerItemKey> excludedKeys = const <ViewerItemKey>{},
  }) async =>
      const ViewerSelectionLease("lease");

  @override
  Future<List<FolderItem>> loadSelectionLeaseBatch(
    ViewerSelectionLease lease, {
    required int limit,
  }) async =>
      const <FolderItem>[];

  @override
  Future<void> consumeSelectionLeaseBatch(
    ViewerSelectionLease lease,
    Iterable<ViewerItemKey> consumed,
  ) async {}

  @override
  Future<void> releaseSelectionLease(ViewerSelectionLease lease) async {}
}

FolderItem _item(int index, {String? prefix}) => FolderItem.link(
      id: "${prefix ?? "item"}-$index",
      url: "https://item-$index.example/path",
      createdAt: DateTime.utc(2026, 1, 1),
    );

Future<void> _waitForLoads(ViewerPageSource source) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await Future<void>.delayed(Duration.zero);
    if (source.activeLoadCount == 0) return;
  }
  fail("page source did not settle");
}

Future<void> _loadPage(ViewerPageSource source, int pageIndex) async {
  source.itemAt(pageIndex * source.pageSize);
  await _waitForLoads(source);
}

void main() {
  group("ViewerPageSource bounds and races", () {
    late _FakeViewerPageRepository repository;
    late ViewerPageSource source;

    setUp(() async {
      repository = _FakeViewerPageRepository();
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());
    });

    tearDown(() async {
      source.dispose();
      await repository.close();
    });

    test("loading a sixth page evicts page zero and retains at most 500 rows",
        () async {
      for (var page = 0; page <= 5; page++) {
        await _loadPage(source, page);
      }

      expect(source.cachedPageCount, 5);
      expect(source.cachedRowCount, lessThanOrEqualTo(500));
      expect(source.itemAt(0), isNull);
      await _waitForLoads(source);
      expect(repository.pageCalls[0], 2);
    });

    test("touching page zero makes page one the next eviction victim",
        () async {
      for (var page = 0; page < 5; page++) {
        await _loadPage(source, page);
      }

      expect(source.itemAt(0)?.id, "item-0");
      await _loadPage(source, 5);

      expect(source.itemAt(0)?.id, "item-0");
      expect(source.itemAt(source.pageSize), isNull);
      await _waitForLoads(source);
      expect(repository.pageCalls[source.pageSize], 2);
    });

    test("two requests for page two share one repository load", () async {
      final pageCompleter = Completer<List<FolderItem>>();
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        pageLoader: (query, limit, offset) => pageCompleter.future,
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());

      expect(source.itemAt(source.pageSize * 2), isNull);
      expect(source.itemAt(source.pageSize * 2 + 1), isNull);
      expect(repository.pageCalls[source.pageSize * 2], 1);
      expect(source.activeLoadCount, 1);

      pageCompleter.complete(
        List<FolderItem>.generate(source.pageSize, _item),
      );
      await _waitForLoads(source);
      expect(source.itemAt(source.pageSize * 2)?.id, "item-0");
    });

    test("changing query discards a pending page completion", () async {
      final oldPageCompleter = Completer<List<FolderItem>>();
      final newPageCompleter = Completer<List<FolderItem>>();
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        pageLoader: (query, limit, offset) {
          if (query.searchText == "old") return oldPageCompleter.future;
          return newPageCompleter.future;
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery(searchText: "old"));
      source.itemAt(0);
      expect(source.activeLoadCount, 1);

      await source.setQuery(const ViewerQuery(searchText: "new"));
      expect(source.activeLoadCount, 0);
      expect(source.itemAt(0), isNull);
      expect(source.activeLoadCount, 1);
      oldPageCompleter.complete(<FolderItem>[_item(0, prefix: "old")]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(source.cachedRowCount, 0);
      expect(source.activeLoadCount, 1);
      newPageCompleter.complete(<FolderItem>[_item(0, prefix: "new")]);
      await _waitForLoads(source);
      expect(source.itemAt(0)?.id, "new-0");
      expect(repository.pageCalls[0], 2);
    });

    test("transaction invalidations coalesce into one generation refresh",
        () async {
      await _loadPage(source, 0);
      expect(source.cachedRowCount, source.pageSize);

      repository.invalidate();
      repository.invalidate();
      repository.invalidate();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(source.cachedRowCount, 0);
      expect(repository.countCalls, 2);
      expect(repository.facetCalls, 2);

      repository.invalidate();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repository.countCalls, 3);
      expect(repository.facetCalls, 3);
    });

    test("a query change supersedes a pending invalidation reset", () async {
      repository.invalidate();
      await Future<void>.microtask(() {});

      await source.setQuery(const ViewerQuery(searchText: "new"));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repository.countCalls, 2);
      expect(repository.facetCalls, 2);
    });

    test("a page error is retryable without discarding healthy pages",
        () async {
      var failingPageAttempts = 0;
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        pageLoader: (_, limit, offset) async {
          if (offset == ViewerPageSource.defaultPageSize &&
              failingPageAttempts++ == 0) {
            throw StateError("retryable page failure");
          }
          return List<FolderItem>.generate(
            limit,
            (index) => _item(offset + index),
          );
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());
      await _loadPage(source, 0);

      await _loadPage(source, 1);
      expect(source.errorAt(source.pageSize), isA<StateError>());
      expect(source.itemAt(0)?.id, "item-0");
      expect(source.cachedPageCount, 1);

      await source.retryPage(1);

      expect(source.errorAt(source.pageSize), isNull);
      expect(source.itemAt(source.pageSize)?.id, "item-${source.pageSize}");
      expect(source.itemAt(0)?.id, "item-0");
      expect(source.cachedPageCount, 2);
      expect(repository.pageCalls[source.pageSize], 2);
    });

    test("an error subscriber can retry the failed page synchronously",
        () async {
      var attempts = 0;
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        pageLoader: (_, limit, offset) async {
          attempts++;
          if (attempts == 1) throw StateError("first page load failed");
          return List<FolderItem>.generate(
            limit,
            (index) => _item(offset + index),
          );
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());
      final unsubscribe = source.error.subscribe((pageError) {
        if (pageError != null) unawaited(source.retryPage(1));
      });
      addTearDown(unsubscribe);

      expect(source.itemAt(source.pageSize), isNull);
      await _waitForLoads(source);

      expect(repository.pageCalls[source.pageSize], 2);
      expect(source.errorAt(source.pageSize), isNull);
      expect(source.itemAt(source.pageSize)?.id, "item-${source.pageSize}");
    });

    test("dispose clears state, cancels invalidation, and ignores late loads",
        () async {
      final pendingPage = Completer<List<FolderItem>>();
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        pageLoader: (_, limit, offset) {
          if (offset == 0) return pendingPage.future;
          return Future<List<FolderItem>>.value(
            List<FolderItem>.generate(
              limit,
              (index) => _item(offset + index),
            ),
          );
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());
      await _loadPage(source, 1);
      source.itemAt(0);
      expect(source.cachedRowCount, source.pageSize);
      expect(source.activeLoadCount, 1);
      expect(source.activeSubscriptionCount, 1);
      repository.invalidate();
      await Future<void>.microtask(() {});

      source.dispose();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(source.cachedRowCount, 0);
      expect(source.cachedPageCount, 0);
      expect(source.activeLoadCount, 0);
      expect(source.activeSubscriptionCount, 0);
      expect(repository.activeInvalidationListeners, 0);
      expect(repository.countCalls, 1);
      expect(repository.facetCalls, 1);

      pendingPage.complete(<FolderItem>[_item(0, prefix: "late")]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(source.cachedRowCount, 0);
      expect(source.itemAt(0), isNull);
      expect(repository.pageCalls[0], 1);
    });

    test("dispose counts invalidation until delayed cancellation completes",
        () async {
      final cancellationGate = Completer<void>();
      final pendingPage = Completer<List<FolderItem>>();
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        cancellationGate: cancellationGate,
        pageLoader: (query, limit, offset) => pendingPage.future,
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());
      source.itemAt(0);

      source.dispose();

      expect(repository.cancellationRequests, 1);
      expect(source.activeSubscriptionCount, 1);
      expect(source.activeLoadCount, 0);
      repository.invalidate();
      pendingPage.complete(<FolderItem>[_item(0, prefix: "late")]);
      cancellationGate.complete();
      await repository.cancellationFinished.future;
      await Future<void>.microtask(() {});

      expect(source.activeSubscriptionCount, 0);
      expect(source.cachedRowCount, 0);
      expect(repository.countCalls, 1);
      expect(repository.facetCalls, 1);
    });

    test("cancellation failure settles and remains available diagnostically",
        () async {
      final cancellationFailure = StateError("invalidation cancel failed");
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        cancellationError: cancellationFailure,
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());

      source.dispose();
      final cancellation = source.invalidationCancellation;

      expect(cancellation, isNotNull);
      expect(source.activeSubscriptionCount, 1);
      await cancellation;
      expect(source.activeSubscriptionCount, 0);
      expect(
        source.subscriptionCancellationError,
        same(cancellationFailure),
      );
      expect(repository.cancellationRequests, 1);
    });
  });

  test("ten create-load-dispose cycles leave no cached rows or listeners",
      () async {
    final repository = _FakeViewerPageRepository();
    addTearDown(repository.close);

    for (var cycle = 0; cycle < 10; cycle++) {
      final source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());
      await _loadPage(source, 0);
      expect(source.cachedRowCount, source.pageSize);

      source.dispose();
      await Future<void>.delayed(Duration.zero);

      expect(source.cachedRowCount, 0);
      expect(source.activeLoadCount, 0);
      expect(source.activeSubscriptionCount, 0);
      expect(repository.activeInvalidationListeners, 0);
    }
  });

  test("ViewerModel delegates bounded queries through its injected database",
      () async {
    final database = AppDatabase(queryExecutor: NativeDatabase.memory());
    addTearDown(database.close);
    final ViewerPageRepository repository = ViewerModel(database: database);

    expect(
      await repository.loadPage(const ViewerQuery(), limit: 100, offset: 0),
      isEmpty,
    );
    expect(await repository.count(const ViewerQuery()), 0);
    expect(await repository.loadTagFacets(const ViewerQuery()), isEmpty);

    final lease = await repository.createSelectionLease(
      query: const ViewerQuery(),
    );
    expect(
      await repository.loadSelectionLeaseBatch(lease, limit: 100),
      isEmpty,
    );
    await repository.consumeSelectionLeaseBatch(
      lease,
      const <ViewerItemKey>[],
    );
    await repository.releaseSelectionLease(lease);
  });
}
