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
typedef _CountLoader = Future<int> Function(ViewerQuery query);
typedef _FacetLoader = Future<List<ViewerTagFacet>> Function(ViewerQuery query);

class _FakeViewerPageRepository implements ViewerPageRepository {
  _FakeViewerPageRepository({
    this.pageLoader,
    this.countLoader,
    this.facetLoader,
    this.cancellationGate,
    this.cancellationError,
  });

  final _PageLoader? pageLoader;
  final _CountLoader? countLoader;
  final _FacetLoader? facetLoader;
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
    final loader = countLoader;
    if (loader != null) return loader(query);
    return 100000;
  }

  @override
  Future<List<ViewerTagFacet>> loadTagFacets(ViewerQuery query) async {
    facetCalls++;
    final loader = facetLoader;
    if (loader != null) return loader(query);
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

Future<void> _waitForCondition(
  bool Function() condition,
  String failureMessage,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await Future<void>.delayed(Duration.zero);
    if (condition()) return;
  }
  fail(failureMessage);
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
      expect(source.countError.value, isNull);
      expect(source.tagFacetsError.value, isNull);
      expect(source.itemAt(0)?.id, "item-0");
      expect(source.cachedPageCount, 1);

      await source.retryPage(1);

      expect(source.errorAt(source.pageSize), isNull);
      expect(source.itemAt(source.pageSize)?.id, "item-${source.pageSize}");
      expect(source.itemAt(0)?.id, "item-0");
      expect(source.cachedPageCount, 2);
      expect(repository.pageCalls[source.pageSize], 2);
    });

    test("count failure retries once for concurrent callers and recovers",
        () async {
      var countAttempts = 0;
      final retryGate = Completer<int>();
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (_) {
          countAttempts++;
          if (countAttempts == 1) {
            throw StateError("count failed");
          }
          return retryGate.future;
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());

      expect(source.countError.value, isA<StateError>());
      expect(source.tagFacetsError.value, isNull);
      expect(source.totalCount.value, 0);

      final firstRetry = source.retrySummary();
      final duplicateRetry = source.retrySummary();

      expect(identical(firstRetry, duplicateRetry), isTrue);
      expect(repository.countCalls, 2);
      expect(repository.facetCalls, 1);
      retryGate.complete(42);
      await firstRetry;

      expect(source.totalCount.value, 42);
      expect(source.countError.value, isNull);
      expect(source.tagFacetsError.value, isNull);
    });

    test("count retry does not wait for pending initial facets", () async {
      final facetGate = Completer<List<ViewerTagFacet>>();
      final countRetryGate = Completer<int>();
      var countAttempts = 0;
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (_) {
          countAttempts++;
          if (countAttempts == 1) throw StateError("count failed");
          return countRetryGate.future;
        },
        facetLoader: (_) => facetGate.future,
      );
      source = ViewerPageSource(repository: repository);
      final initialLoad = source.setQuery(const ViewerQuery());

      try {
        await _waitForCondition(
          () => source.countError.value != null,
          "count error was not published while facets remained pending",
        );
        expect(source.activeSummaryLoadCount, 1);
        var initialCompleted = false;
        unawaited(initialLoad.then((_) => initialCompleted = true));

        final firstRetry = source.retrySummary();
        final duplicateRetry = source.retrySummary();

        expect(identical(firstRetry, duplicateRetry), isTrue);
        expect(repository.countCalls, 2);
        expect(repository.facetCalls, 1);
        expect(source.activeSummaryLoadCount, 2);
        expect(source.countError.value, isA<StateError>());

        countRetryGate.complete(42);
        await firstRetry;

        expect(initialCompleted, isFalse);
        expect(source.totalCount.value, 42);
        expect(source.countError.value, isNull);
        expect(source.activeSummaryLoadCount, 1);

        facetGate.complete(const <ViewerTagFacet>[]);
        await initialLoad;
        expect(source.activeSummaryLoadCount, 0);
      } finally {
        if (!countRetryGate.isCompleted) countRetryGate.complete(42);
        if (!facetGate.isCompleted) {
          facetGate.complete(const <ViewerTagFacet>[]);
        }
        await initialLoad;
      }
    });

    test("facet failure retries without discarding a healthy count", () async {
      var facetAttempts = 0;
      final recoveredFacet = ViewerTagFacet(
        tag: Tag(
          id: "tag-id-not-name",
          name: "topic",
          createdAt: DateTime.utc(2026, 1, 1),
        ),
        itemCount: 7,
      );
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        facetLoader: (_) async {
          facetAttempts++;
          if (facetAttempts == 1) throw StateError("facets failed");
          return <ViewerTagFacet>[recoveredFacet];
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());

      expect(source.totalCount.value, 100000);
      expect(source.countError.value, isNull);
      expect(source.tagFacetsError.value, isA<StateError>());
      expect(source.tagFacets.value, isEmpty);

      await source.retrySummary();

      expect(source.totalCount.value, 100000);
      expect(source.tagFacetsError.value, isNull);
      expect(source.tagFacets.value, <ViewerTagFacet>[recoveredFacet]);
      expect(repository.countCalls, 1);
      expect(repository.facetCalls, 2);
    });

    test("facet retry does not wait for a pending initial count", () async {
      final countGate = Completer<int>();
      final facetRetryGate = Completer<List<ViewerTagFacet>>();
      var facetAttempts = 0;
      final recoveredFacet = ViewerTagFacet(
        tag: Tag(
          id: "tag-id-not-name",
          name: "topic",
          createdAt: DateTime.utc(2026, 1, 1),
        ),
        itemCount: 7,
      );
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (_) => countGate.future,
        facetLoader: (_) {
          facetAttempts++;
          if (facetAttempts == 1) throw StateError("facets failed");
          return facetRetryGate.future;
        },
      );
      source = ViewerPageSource(repository: repository);
      final initialLoad = source.setQuery(const ViewerQuery());

      try {
        await _waitForCondition(
          () => source.tagFacetsError.value != null,
          "facet error was not published while count remained pending",
        );
        expect(source.activeSummaryLoadCount, 1);
        var initialCompleted = false;
        unawaited(initialLoad.then((_) => initialCompleted = true));

        final firstRetry = source.retrySummary();
        final duplicateRetry = source.retrySummary();

        expect(identical(firstRetry, duplicateRetry), isTrue);
        expect(repository.countCalls, 1);
        expect(repository.facetCalls, 2);
        expect(source.activeSummaryLoadCount, 2);
        expect(source.tagFacetsError.value, isA<StateError>());

        facetRetryGate.complete(<ViewerTagFacet>[recoveredFacet]);
        await firstRetry;

        expect(initialCompleted, isFalse);
        expect(source.tagFacets.value, <ViewerTagFacet>[recoveredFacet]);
        expect(source.tagFacetsError.value, isNull);
        expect(source.activeSummaryLoadCount, 1);

        countGate.complete(42);
        await initialLoad;
        expect(source.totalCount.value, 42);
        expect(source.activeSummaryLoadCount, 0);
      } finally {
        if (!facetRetryGate.isCompleted) {
          facetRetryGate.complete(<ViewerTagFacet>[recoveredFacet]);
        }
        if (!countGate.isCompleted) countGate.complete(42);
        await initialLoad;
      }
    });

    test("a query change ignores a stale summary retry completion", () async {
      final staleRetry = Completer<int>();
      var oldCountCalls = 0;
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (query) {
          if (query.searchText == "old") {
            oldCountCalls++;
            if (oldCountCalls == 1) throw StateError("old count failed");
            return staleRetry.future;
          }
          return Future<int>.value(9);
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery(searchText: "old"));
      final retry = source.retrySummary();

      await source.setQuery(const ViewerQuery(searchText: "new"));
      expect(source.totalCount.value, 9);
      expect(source.countError.value, isNull);

      staleRetry.complete(999);
      await retry;

      expect(source.totalCount.value, 9);
      expect(source.countError.value, isNull);
    });

    test("dispose ignores a pending summary retry completion", () async {
      final retryGate = Completer<List<ViewerTagFacet>>();
      var facetAttempts = 0;
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        facetLoader: (_) {
          facetAttempts++;
          if (facetAttempts == 1) throw StateError("facets failed");
          return retryGate.future;
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());
      final retry = source.retrySummary();

      source.dispose();
      retryGate.complete(<ViewerTagFacet>[
        ViewerTagFacet(
          tag: Tag(
            id: "late-id",
            name: "late",
            createdAt: DateTime.utc(2026, 1, 1),
          ),
          itemCount: 1,
        ),
      ]);
      await retry;

      expect(source.cachedRowCount, 0);
      expect(source.activeSummaryLoadCount, 0);
      expect(source.countError.disposed, isTrue);
      expect(source.tagFacetsError.disposed, isTrue);
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
