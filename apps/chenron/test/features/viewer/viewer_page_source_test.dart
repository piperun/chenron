import "dart:async";

import "package:chenron/features/folder_viewer/services/folder_viewer_service.dart";
import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:drift/native.dart";
import "package:flutter_test/flutter_test.dart";
import "package:signals/signals.dart";

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
  Future<int> countSelectionLease(ViewerSelectionLease lease) async => 0;

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

    test("simultaneous page loads never exceed four active futures", () async {
      final pending = <Completer<List<FolderItem>>>[];
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        pageLoader: (_, __, ___) {
          final completer = Completer<List<FolderItem>>();
          pending.add(completer);
          return completer.future;
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());

      for (var page = 0; page < 25; page++) {
        source.itemAt(page * source.pageSize);
      }
      await Future<void>.delayed(Duration.zero);

      try {
        expect(source.activeLoadCount, lessThanOrEqualTo(4));
        expect(source.queuedLoadCount, lessThanOrEqualTo(16));
        expect(source.droppedPageRequestCount, 5);
      } finally {
        for (final completer in pending) {
          if (!completer.isCompleted) {
            completer.complete(const <FolderItem>[]);
          }
        }
        await Future<void>.delayed(Duration.zero);
      }
    });

    test("failed page bookkeeping retains at most twenty errors", () async {
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        pageLoader: (_, __, offset) async =>
            throw StateError("page ${offset ~/ 100} failed"),
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());

      for (var page = 0; page < 25; page++) {
        source.itemAt(page * source.pageSize);
        await _waitForLoads(source);
      }

      final retainedErrors = List<int>.generate(25, (page) => page)
          .where((page) => source.errorAt(page * source.pageSize) != null)
          .length;
      expect(retainedErrors, lessThanOrEqualTo(20));
    });

    test("dispose reports an uncancellable page future until it settles",
        () async {
      final pending = Completer<List<FolderItem>>();
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        pageLoader: (_, __, ___) => pending.future,
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());
      source.itemAt(0);
      await Future<void>.delayed(Duration.zero);
      expect(source.activeLoadCount, 1);

      source.dispose();

      try {
        expect(source.activeLoadCount, 1);
      } finally {
        pending.complete(const <FolderItem>[]);
        await Future<void>.delayed(Duration.zero);
      }
      expect(source.activeLoadCount, 0);
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
      expect(source.activeLoadCount, 1);
      expect(source.itemAt(0), isNull);
      expect(source.activeLoadCount, 2);
      expect(source.queuedLoadCount, 0);
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

    test("nested bulk boundaries defer one refresh until the outer exit",
        () async {
      final baselineGeneration = source.summaryGeneration.value;
      final baselineCountCalls = repository.countCalls;
      final baselineFacetCalls = repository.facetCalls;

      await source.runBulkUpdate(() async {
        repository.invalidate();
        await source.runBulkUpdate(() async {
          repository.invalidate();
          await Future<void>.delayed(Duration.zero);
        });
        expect(source.summaryGeneration.value, baselineGeneration);
        repository.invalidate();
      });
      await Future<void>.delayed(Duration.zero);

      expect(source.summaryGeneration.value - baselineGeneration, 1);
      expect(repository.countCalls - baselineCountCalls, 1);
      expect(repository.facetCalls - baselineFacetCalls, 1);
    });

    test("a debounce scheduled before bulk joins its trailing refresh",
        () async {
      final baselineGeneration = source.summaryGeneration.value;
      final baselineCountCalls = repository.countCalls;
      final baselineFacetCalls = repository.facetCalls;

      repository.invalidate();
      await Future<void>.microtask(() {});
      await source.runBulkUpdate(() async {
        await Future<void>.delayed(Duration.zero);
        expect(source.summaryGeneration.value, baselineGeneration);
        repository.invalidate();
      });
      await Future<void>.delayed(Duration.zero);

      expect(source.summaryGeneration.value - baselineGeneration, 1);
      expect(repository.countCalls - baselineCountCalls, 1);
      expect(repository.facetCalls - baselineFacetCalls, 1);
    });

    test("summary invalidations retain one active count and one dirty refresh",
        () async {
      final countLoads = <Completer<int>>[];
      var activeCounts = 0;
      var maxActiveCounts = 0;
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (_) {
          activeCounts++;
          if (activeCounts > maxActiveCounts) maxActiveCounts = activeCounts;
          final completer = Completer<int>();
          countLoads.add(completer);
          return completer.future.whenComplete(() => activeCounts--);
        },
      );
      source = ViewerPageSource(repository: repository);
      final initial = source.setQuery(const ViewerQuery());
      await Future<void>.delayed(Duration.zero);

      for (var turn = 0; turn < 3; turn++) {
        repository.invalidate();
        await Future<void>.delayed(Duration.zero);
      }

      try {
        expect(maxActiveCounts, 1);
      } finally {
        for (final completer in countLoads) {
          if (!completer.isCompleted) completer.complete(100000);
        }
        await initial;
        await Future<void>.delayed(Duration.zero);
        for (final completer in countLoads) {
          if (!completer.isCompleted) completer.complete(100000);
        }
        await Future<void>.delayed(Duration.zero);
      }
    });

    test("thousands of summary replacements share one latest queued future",
        () async {
      final activeCountGate = Completer<int>();
      final loadedCountQueries = <String>[];
      final loadedFacetQueries = <String>[];
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (query) {
          loadedCountQueries.add(query.searchText);
          if (loadedCountQueries.length == 1) return activeCountGate.future;
          return Future<int>.value(77);
        },
        facetLoader: (query) async {
          loadedFacetQueries.add(query.searchText);
          return const <ViewerTagFacet>[];
        },
      );
      source = ViewerPageSource(repository: repository);
      final initialLoad =
          source.setQuery(const ViewerQuery(searchText: "initial"));
      await _waitForCondition(
        () => repository.countCalls == 1,
        "initial summary did not stall",
      );

      final queuedFutures = <Future<void>>[];
      for (var index = 0; index < 2048; index++) {
        queuedFutures.add(
          source.setQuery(ViewerQuery(searchText: "query-$index")),
        );
      }

      try {
        expect(source.activeSummaryLoadCount, 1);
        expect(source.hasDirtySummaryRefresh, isTrue);
        expect(source.queuedSummaryRequestCount, 1);
        expect(source.retainedSummaryRequestCount, 2);
        expect(
          queuedFutures.skip(1).every(
                (future) => identical(future, queuedFutures.first),
              ),
          isTrue,
        );

        activeCountGate.complete(1);
        await initialLoad;
        await queuedFutures.first;
        await _waitForCondition(
          () => source.activeSummaryLoadCount == 0,
          "latest queued summary did not settle",
        );

        expect(loadedCountQueries, <String>["initial", "query-2047"]);
        expect(loadedFacetQueries, <String>["initial", "query-2047"]);
        expect(source.totalCount.value, 77);
        expect(source.queuedSummaryRequestCount, 0);
        expect(source.retainedSummaryRequestCount, 0);
      } finally {
        if (!activeCountGate.isCompleted) activeCountGate.complete(1);
        await initialLoad;
      }
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

    test("count retry queues behind pending initial facets", () async {
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
        expect(repository.countCalls, 1);
        expect(repository.facetCalls, 1);
        expect(source.activeSummaryLoadCount, 1);
        expect(source.hasDirtySummaryRefresh, isTrue);
        expect(source.countError.value, isA<StateError>());

        facetGate.complete(const <ViewerTagFacet>[]);
        await initialLoad;
        await _waitForCondition(
          () => repository.countCalls == 2,
          "queued count retry did not start",
        );
        expect(initialCompleted, isTrue);
        expect(source.activeSummaryLoadCount, 1);

        countRetryGate.complete(42);
        await firstRetry;
        await duplicateRetry;
        await _waitForCondition(
          () => source.activeSummaryLoadCount == 0,
          "queued count retry did not settle",
        );
        expect(source.totalCount.value, 42);
        expect(source.countError.value, isNull);
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

    test("facet retry queues behind a pending initial count", () async {
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
        expect(repository.facetCalls, 1);
        expect(source.activeSummaryLoadCount, 1);
        expect(source.hasDirtySummaryRefresh, isTrue);
        expect(source.tagFacetsError.value, isA<StateError>());

        countGate.complete(42);
        await initialLoad;
        await _waitForCondition(
          () => repository.facetCalls == 2,
          "queued facet retry did not start",
        );
        expect(initialCompleted, isTrue);
        expect(source.activeSummaryLoadCount, 1);

        facetRetryGate.complete(<ViewerTagFacet>[recoveredFacet]);
        await firstRetry;
        await duplicateRetry;
        await _waitForCondition(
          () => source.activeSummaryLoadCount == 0,
          "queued facet retry did not settle",
        );
        expect(source.tagFacets.value, <ViewerTagFacet>[recoveredFacet]);
        expect(source.tagFacetsError.value, isNull);
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

    test("dual summary retries reuse the same aggregate until its pair changes",
        () async {
      final firstCountRetry = Completer<int>();
      final firstFacetRetry = Completer<List<ViewerTagFacet>>();
      final secondCountRetry = Completer<int>();
      final secondFacetRetry = Completer<List<ViewerTagFacet>>();
      var countAttempts = 0;
      var facetAttempts = 0;
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (_) {
          countAttempts++;
          if (countAttempts == 1) throw StateError("count failed initially");
          if (countAttempts == 2) return firstCountRetry.future;
          return secondCountRetry.future;
        },
        facetLoader: (_) {
          facetAttempts++;
          if (facetAttempts == 1) throw StateError("facets failed initially");
          if (facetAttempts == 2) return firstFacetRetry.future;
          return secondFacetRetry.future;
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery());

      final firstPair = source.retrySummary();
      final duplicateFirstPair = source.retrySummary();

      expect(identical(firstPair, duplicateFirstPair), isTrue);
      expect(repository.countCalls, 2);
      expect(repository.facetCalls, 2);

      firstCountRetry.completeError(StateError("count retry failed"));
      firstFacetRetry.completeError(StateError("facet retry failed"));
      await firstPair;

      final secondPair = source.retrySummary();
      final duplicateSecondPair = source.retrySummary();

      expect(identical(secondPair, firstPair), isFalse);
      expect(identical(secondPair, duplicateSecondPair), isTrue);
      expect(repository.countCalls, 3);
      expect(repository.facetCalls, 3);

      secondCountRetry.complete(17);
      secondFacetRetry.complete(const <ViewerTagFacet>[]);
      await secondPair;
      expect(source.totalCount.value, 17);
      expect(source.countError.value, isNull);
      expect(source.tagFacetsError.value, isNull);
    });

    test("a query change invalidates a stale dual-summary aggregate", () async {
      final staleCountRetry = Completer<int>();
      final staleFacetRetry = Completer<List<ViewerTagFacet>>();
      var oldCountAttempts = 0;
      var oldFacetAttempts = 0;
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (query) {
          if (query.searchText == "old") {
            oldCountAttempts++;
            if (oldCountAttempts == 1) throw StateError("old count failed");
            return staleCountRetry.future;
          }
          return Future<int>.value(9);
        },
        facetLoader: (query) {
          if (query.searchText == "old") {
            oldFacetAttempts++;
            if (oldFacetAttempts == 1) throw StateError("old facets failed");
            return staleFacetRetry.future;
          }
          return Future<List<ViewerTagFacet>>.value(
            const <ViewerTagFacet>[],
          );
        },
      );
      source = ViewerPageSource(repository: repository);
      await source.setQuery(const ViewerQuery(searchText: "old"));
      final stalePair = source.retrySummary();
      expect(identical(stalePair, source.retrySummary()), isTrue);

      final latest = source.setQuery(const ViewerQuery(searchText: "new"));
      expect(source.totalCount.value, 0);
      expect(source.countError.value, isNull);
      expect(source.tagFacetsError.value, isNull);
      expect(source.activeSummaryLoadCount, 1);
      expect(source.hasDirtySummaryRefresh, isTrue);

      staleCountRetry.complete(999);
      staleFacetRetry.complete(const <ViewerTagFacet>[]);
      await stalePair;
      await latest;
      await _waitForCondition(
        () => source.totalCount.value == 9,
        "latest queued summary did not publish",
      );

      expect(source.totalCount.value, 9);
      expect(source.countError.value, isNull);
      expect(source.tagFacetsError.value, isNull);
      expect(source.activeSummaryLoadCount, 0);
    });

    test("count publication cannot write revision after a reentrant query",
        () async {
      final oldCount = Completer<int>();
      final oldFacets = Completer<List<ViewerTagFacet>>();
      final newCount = Completer<int>();
      final newFacets = Completer<List<ViewerTagFacet>>();
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (query) =>
            query.searchText == "old" ? oldCount.future : newCount.future,
        facetLoader: (query) =>
            query.searchText == "old" ? oldFacets.future : newFacets.future,
      );
      source = ViewerPageSource(repository: repository);
      final initialLoad = source.setQuery(const ViewerQuery(searchText: "old"));
      Future<void>? replacementLoad;
      int? revisionAfterReplacement;
      var reacted = false;
      final unsubscribe = source.totalCount.subscribe((count) {
        if (reacted || count != 7) return;
        reacted = true;
        replacementLoad = source.setQuery(const ViewerQuery(searchText: "new"));
        revisionAfterReplacement = source.revision.value;
      });

      try {
        oldCount.complete(7);
        await _waitForCondition(
          () => reacted,
          "count result did not trigger the reentrant query",
        );

        expect(source.revision.value, revisionAfterReplacement);
      } finally {
        unsubscribe();
        oldFacets.complete(const <ViewerTagFacet>[]);
        newCount.complete(11);
        newFacets.complete(const <ViewerTagFacet>[]);
        await initialLoad;
        await replacementLoad;
      }
      expect(source.totalCount.value, 11);
    });

    test("facet publication cannot write revision after a reentrant query",
        () async {
      final oldCount = Completer<int>();
      final oldFacets = Completer<List<ViewerTagFacet>>();
      final newCount = Completer<int>();
      final newFacets = Completer<List<ViewerTagFacet>>();
      final oldFacet = ViewerTagFacet(
        tag: Tag(
          id: "old-tag-id",
          name: "old-tag",
          createdAt: DateTime.utc(2026, 1, 1),
        ),
        itemCount: 1,
      );
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (query) =>
            query.searchText == "old" ? oldCount.future : newCount.future,
        facetLoader: (query) =>
            query.searchText == "old" ? oldFacets.future : newFacets.future,
      );
      source = ViewerPageSource(repository: repository);
      final initialLoad = source.setQuery(const ViewerQuery(searchText: "old"));
      Future<void>? replacementLoad;
      int? revisionAfterReplacement;
      var reacted = false;
      final unsubscribe = source.tagFacets.subscribe((facets) {
        if (reacted || facets.isEmpty) return;
        reacted = true;
        replacementLoad = source.setQuery(const ViewerQuery(searchText: "new"));
        revisionAfterReplacement = source.revision.value;
      });

      try {
        oldFacets.complete(<ViewerTagFacet>[oldFacet]);
        await _waitForCondition(
          () => reacted,
          "facet result did not trigger the reentrant query",
        );

        expect(source.revision.value, revisionAfterReplacement);
      } finally {
        unsubscribe();
        oldCount.complete(7);
        newCount.complete(11);
        newFacets.complete(const <ViewerTagFacet>[]);
        await initialLoad;
        await replacementLoad;
      }
      expect(source.totalCount.value, 11);
      expect(source.tagFacets.value, isEmpty);
    });

    test("count error publication may dispose the source reentrantly",
        () async {
      final facetGate = Completer<List<ViewerTagFacet>>();
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (_) => throw StateError("count failed"),
        facetLoader: (_) => facetGate.future,
      );
      source = ViewerPageSource(repository: repository);
      late final void Function() disposeEffect;
      disposeEffect = effect(() {
        final error = source.countError.value;
        if (error == null) return;
        disposeEffect();
        source.dispose();
      });

      final load = source.setQuery(const ViewerQuery());
      await _waitForCondition(
        () => source.countError.disposed,
        "count error did not trigger reentrant disposal",
      );
      facetGate.complete(const <ViewerTagFacet>[]);

      await expectLater(load, completes);
      expect(source.revision.disposed, isTrue);
    });

    test("facet error publication may dispose the source reentrantly",
        () async {
      final countGate = Completer<int>();
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (_) => countGate.future,
        facetLoader: (_) => throw StateError("facets failed"),
      );
      source = ViewerPageSource(repository: repository);
      late final void Function() disposeEffect;
      disposeEffect = effect(() {
        final error = source.tagFacetsError.value;
        if (error == null) return;
        disposeEffect();
        source.dispose();
      });

      final load = source.setQuery(const ViewerQuery());
      await _waitForCondition(
        () => source.tagFacetsError.disposed,
        "facet error did not trigger reentrant disposal",
      );
      countGate.complete(7);

      await expectLater(load, completes);
      expect(source.revision.disposed, isTrue);
    });

    test("a generation reset may dispose without starting stale summaries",
        () async {
      expect(source.totalCount.value, 100000);
      final countCallsBeforeReset = repository.countCalls;
      final facetCallsBeforeReset = repository.facetCalls;
      var disposedDuringReset = false;
      final unsubscribe = source.totalCount.subscribe((count) {
        if (disposedDuringReset || count != 0) return;
        disposedDuringReset = true;
        source.dispose();
      });

      await expectLater(
        source.setQuery(const ViewerQuery(searchText: "replacement")),
        completes,
      );

      unsubscribe();
      expect(disposedDuringReset, isTrue);
      expect(source.activeSummaryLoadCount, 0);
      expect(repository.countCalls, countCallsBeforeReset);
      expect(repository.facetCalls, facetCallsBeforeReset);
      expect(source.revision.disposed, isTrue);
    });

    test("summary publication does not hide subscriber failures", () async {
      final countGate = Completer<int>();
      final subscriberFailure = StateError("count subscriber failed");
      source.dispose();
      await repository.close();
      repository = _FakeViewerPageRepository(
        countLoader: (_) => countGate.future,
      );
      source = ViewerPageSource(repository: repository);
      final unsubscribe = source.totalCount.subscribe((count) {
        if (count == 7) throw subscriberFailure;
      });

      final load = source.setQuery(const ViewerQuery());
      countGate.complete(7);

      await expectLater(
        load,
        throwsA(
          isA<SignalEffectException>().having(
            (error) => error.error,
            "original error",
            same(subscriberFailure),
          ),
        ),
      );
      unsubscribe();
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

      final latest = source.setQuery(const ViewerQuery(searchText: "new"));
      expect(source.totalCount.value, 0);
      expect(source.countError.value, isNull);

      staleRetry.complete(999);
      await retry;
      await latest;
      await _waitForCondition(
        () => source.totalCount.value == 9,
        "latest queued count did not publish",
      );

      expect(source.totalCount.value, 9);
      expect(source.countError.value, isNull);
    });

    test("dispose ignores a pending summary retry completion", () async {
      final retryGate = Completer<List<ViewerTagFacet>>();
      var facetAttempts = 0;
      final settlement = source.disposeAndWait();
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
      await settlement;

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

      final settlement = source.disposeAndWait();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(source.cachedRowCount, 0);
      expect(source.cachedPageCount, 0);
      expect(source.activeLoadCount, 1);
      expect(source.activeSubscriptionCount, 0);
      expect(repository.activeInvalidationListeners, 0);
      expect(repository.countCalls, 1);
      expect(repository.facetCalls, 1);

      pendingPage.complete(<FolderItem>[_item(0, prefix: "late")]);
      await settlement;
      expect(source.activeLoadCount, 0);
      expect(source.cachedRowCount, 0);
      expect(source.itemAt(0), isNull);
      expect(repository.pageCalls[0], 1);
    });

    test("dispose counts invalidation until delayed cancellation completes",
        () async {
      final cancellationGate = Completer<void>();
      final pendingPage = Completer<List<FolderItem>>();
      final settlement = source.disposeAndWait();
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
      expect(source.activeLoadCount, 1);
      repository.invalidate();
      pendingPage.complete(<FolderItem>[_item(0, prefix: "late")]);
      cancellationGate.complete();
      await repository.cancellationFinished.future;
      await settlement;

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

  test("viewer and folder repositories share their database coordinator",
      () async {
    final database = AppDatabase(queryExecutor: NativeDatabase.memory());
    final viewerSource = ViewerPageSource(
      repository: ViewerModel(database: database),
    );
    final folderSource = ViewerPageSource(
      repository: FolderViewerService(database: database),
    );

    try {
      expect(
        identical(
          viewerSource.invalidationCoordinator,
          folderSource.invalidationCoordinator,
        ),
        isTrue,
      );
      expect(viewerSource.invalidationCoordinator.registeredSourceCount, 2);
    } finally {
      await viewerSource.disposeAndWait();
      await folderSource.disposeAndWait();
      await database.close();
    }
  });
}
