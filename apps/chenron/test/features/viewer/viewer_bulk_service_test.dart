import "dart:async";
import "dart:math";

import "package:cache_manager/cache_manager.dart";
import "package:chenron/features/viewer/services/viewer_bulk_service.dart";
import "package:catalog/catalog.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter_test/flutter_test.dart";
import "package:signals/signals.dart";

FolderItem _link(int index) => FolderItem.link(
      id: "link-$index",
      itemId: null,
      url: "https://item-$index.example/path",
      archiveOrg: null,
      archiveIs: null,
      createdAt: DateTime.utc(2026, 8, 10),
      tags: const <Tag>[],
    );

FolderItem _folder(String id) => FolderItem.folder(
      id: id,
      itemId: null,
      folderId: id,
      title: "Folder $id",
      description: "",
      createdAt: DateTime.utc(2026, 8, 10),
      tags: const <Tag>[],
    );

ViewerItemKey _key(FolderItem item) => (type: item.type, id: item.id!);

final class _SharedViewerInvalidations {
  final StreamController<void> _controller =
      StreamController<void>.broadcast(sync: true);
  bool _closed = false;

  Stream<void> get stream => _controller.stream;

  void invalidate() => _controller.add(null);

  Future<void> close() {
    if (_closed) return Future<void>.value();
    _closed = true;
    return _controller.close();
  }
}

class _LeaseRepository
    implements
        CatalogSource<FolderItem, ViewerQuery>,
        CatalogSelectionLeases<FolderItem, ViewerQuery>,
        CatalogInvalidationDomain {
  _LeaseRepository(
    List<FolderItem> rows, {
    _SharedViewerInvalidations? invalidations,
  })  : _invalidations = invalidations ?? _SharedViewerInvalidations(),
        _rowsByKey = <ViewerItemKey, FolderItem>{
          for (final row in rows) _key(row): row,
        };

  final Map<ViewerItemKey, FolderItem> _rowsByKey;
  final Map<Object, List<FolderItem>> _leases = <Object, List<FolderItem>>{};
  final List<int> requestedLimits = <int>[];
  final List<Set<ViewerItemKey>?> createdOnlyKeys = <Set<ViewerItemKey>?>[];
  final List<Set<ViewerItemKey>> createdExcludedKeys = <Set<ViewerItemKey>>[];
  final _SharedViewerInvalidations _invalidations;
  int releaseCalls = 0;
  int loadCalls = 0;
  int consumeCalls = 0;
  int countLeaseCalls = 0;
  int countCalls = 0;
  int facetCalls = 0;
  bool failNextConsume = false;

  @override
  Object get invalidationDomain => _invalidations;

  void invalidate() => _invalidations.invalidate();

  Future<void> close() => _invalidations.close();

  @override
  Future<CatalogSelectionLease> createSelectionLease({
    required ViewerQuery query,
    Set<Object>? onlyKeys,
    Set<Object> excludedKeys = const <Object>{},
  }) async {
    final onlyItemKeys = onlyKeys?.cast<ViewerItemKey>().toSet();
    createdOnlyKeys.add(onlyItemKeys == null ? null : Set.of(onlyItemKeys));
    createdExcludedKeys.add(excludedKeys.cast<ViewerItemKey>().toSet());
    final lease = CatalogSelectionLease("lease-${_leases.length}");
    final selectedKeys = onlyItemKeys ??
        _rowsByKey.entries
            .where((entry) => query.types.contains(entry.value.type))
            .map((entry) => entry.key)
            .toSet();
    _leases[lease.id] = selectedKeys
        .where((key) => !excludedKeys.contains(key))
        .map((key) => _rowsByKey[key])
        .whereType<FolderItem>()
        .toList();
    return lease;
  }

  @override
  Future<List<FolderItem>> loadSelectionLeaseBatch(
    CatalogSelectionLease lease, {
    required int limit,
  }) async {
    loadCalls++;
    requestedLimits.add(limit);
    return _leases[lease.id]!.take(limit).toList(growable: false);
  }

  @override
  Future<void> consumeSelectionLeaseBatch(
    CatalogSelectionLease lease,
    Iterable<Object> consumed,
  ) async {
    consumeCalls++;
    if (failNextConsume) {
      failNextConsume = false;
      throw StateError("consume failed");
    }
    final consumedKeys = consumed.toSet();
    _leases[lease.id]!.removeWhere((item) => consumedKeys.contains(_key(item)));
  }

  @override
  Future<void> releaseSelectionLease(CatalogSelectionLease lease) async {
    releaseCalls++;
    _leases.remove(lease.id);
  }

  @override
  Future<int> countSelectionLease(CatalogSelectionLease lease) async {
    countLeaseCalls++;
    return _leases[lease.id]!.length;
  }

  @override
  Future<int> count(ViewerQuery query) async {
    countCalls++;
    return _rowsByKey.length;
  }

  @override
  Stream<void> invalidations() => _invalidations.stream;

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) async =>
      _rowsByKey.values.skip(offset).take(limit).toList(growable: false);

  @override
  Future<List<CatalogFacetGroup>> loadFacets(ViewerQuery query) async {
    facetCalls++;
    return const <CatalogFacetGroup>[];
  }
}

final class _ImmediateBulkBoundary implements CatalogBulkUpdateBoundary {
  const _ImmediateBulkBoundary();

  @override
  Future<T> runBulkUpdate<T>(Future<T> Function() operation) => operation();
}

const _immediateBulkBoundary = _ImmediateBulkBoundary();

void main() {
  test("bulk invalidations across async batches produce one trailing refresh",
      () async {
    final rows = List<FolderItem>.generate(201, _link);
    final repository = _LeaseRepository(rows);
    final source = CatalogPager<FolderItem, ViewerQuery>(source: repository);
    await source.setQuery(const ViewerQuery());
    final baselineGeneration = source.summaryGeneration.value;
    final baselineCountCalls = repository.countCalls;
    final baselineFacetCalls = repository.facetCalls;
    var processed = 0;
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: source,
      deleteItem: (item) async {
        processed++;
        if (processed == 1 || processed == 101 || processed == 201) {
          repository.invalidate();
          await Future<void>.delayed(Duration.zero);
        }
        return true;
      },
    );

    final result = await service.delete(
      CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>(
        query: const ViewerQuery(),
        totalCount: rows.length,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(result.processed, rows.length);
    expect(source.summaryGeneration.value - baselineGeneration, 1);
    expect(repository.countCalls - baselineCountCalls, 1);
    expect(repository.facetCalls - baselineFacetCalls, 1);

    source.dispose();
    await source.invalidationCancellation;
    await repository.close();
  });

  test("bulk exception still produces exactly one trailing refresh", () async {
    final rows = List<FolderItem>.generate(100, _link);
    final repository = _LeaseRepository(rows)..failNextConsume = true;
    final source = CatalogPager<FolderItem, ViewerQuery>(source: repository);
    await source.setQuery(const ViewerQuery());
    final baselineGeneration = source.summaryGeneration.value;
    var processed = 0;
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: source,
      deleteItem: (item) async {
        processed++;
        if (processed <= 2) {
          repository.invalidate();
          await Future<void>.delayed(Duration.zero);
        }
        return true;
      },
    );

    await expectLater(
      service.delete(
        CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>(
          query: const ViewerQuery(),
          totalCount: rows.length,
        ),
      ),
      throwsStateError,
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(source.summaryGeneration.value - baselineGeneration, 1);

    source.dispose();
    await source.invalidationCancellation;
    await repository.close();
  });

  test("shared-domain nested bulk refreshes every live source exactly once",
      () async {
    final invalidations = _SharedViewerInvalidations();
    final rows = List<FolderItem>.generate(3, _link);
    final repositoryA = _LeaseRepository(rows, invalidations: invalidations);
    final repositoryB = _LeaseRepository(rows, invalidations: invalidations);
    final sourceA = CatalogPager<FolderItem, ViewerQuery>(source: repositoryA);
    final sourceB = CatalogPager<FolderItem, ViewerQuery>(source: repositoryB);

    try {
      await sourceA.setQuery(const ViewerQuery(searchText: "retained"));
      await sourceB.setQuery(const ViewerQuery(searchText: "active"));
      final baselineGenerationA = sourceA.summaryGeneration.value;
      final baselineGenerationB = sourceB.summaryGeneration.value;
      final baselineCountA = repositoryA.countCalls;
      final baselineCountB = repositoryB.countCalls;
      final baselineFacetsA = repositoryA.facetCalls;
      final baselineFacetsB = repositoryB.facetCalls;
      var processed = 0;
      final service = ViewerBulkService(
        repository: repositoryB,
        bulkUpdateBoundary: sourceB,
        batchSize: 1,
        deleteItem: (item) async {
          processed++;
          if (processed == 1) {
            await sourceA.runBulkUpdate(() async {
              repositoryB.invalidate();
              await Future<void>.delayed(Duration.zero);
            });
          } else {
            repositoryB.invalidate();
            await Future<void>.delayed(Duration.zero);
          }
          return true;
        },
      );

      final result = await service.delete(
        CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>(
          query: const ViewerQuery(),
          totalCount: rows.length,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(result.processed, 3);
      expect(sourceA.summaryGeneration.value - baselineGenerationA, 1);
      expect(sourceB.summaryGeneration.value - baselineGenerationB, 1);
      expect(repositoryA.countCalls - baselineCountA, 1);
      expect(repositoryB.countCalls - baselineCountB, 1);
      expect(repositoryA.facetCalls - baselineFacetsA, 1);
      expect(repositoryB.facetCalls - baselineFacetsB, 1);
    } finally {
      await sourceA.disposeAndWait();
      await sourceB.disposeAndWait();
      await invalidations.close();
    }
  });

  test("shared-domain exception refreshes every live source exactly once",
      () async {
    final invalidations = _SharedViewerInvalidations();
    final rows = List<FolderItem>.generate(3, _link);
    final repositoryA = _LeaseRepository(rows, invalidations: invalidations);
    final repositoryB = _LeaseRepository(rows, invalidations: invalidations)
      ..failNextConsume = true;
    final sourceA = CatalogPager<FolderItem, ViewerQuery>(source: repositoryA);
    final sourceB = CatalogPager<FolderItem, ViewerQuery>(source: repositoryB);

    try {
      await sourceA.setQuery(const ViewerQuery(searchText: "retained"));
      await sourceB.setQuery(const ViewerQuery(searchText: "active"));
      final baselineGenerationA = sourceA.summaryGeneration.value;
      final baselineGenerationB = sourceB.summaryGeneration.value;
      final baselineCountA = repositoryA.countCalls;
      final baselineCountB = repositoryB.countCalls;
      final service = ViewerBulkService(
        repository: repositoryB,
        bulkUpdateBoundary: sourceB,
        deleteItem: (item) async {
          repositoryB.invalidate();
          await Future<void>.delayed(Duration.zero);
          return true;
        },
      );

      await expectLater(
        service.delete(
          CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>(
            query: const ViewerQuery(),
            totalCount: rows.length,
          ),
        ),
        throwsStateError,
      );
      await Future<void>.delayed(Duration.zero);

      expect(sourceA.summaryGeneration.value - baselineGenerationA, 1);
      expect(sourceB.summaryGeneration.value - baselineGenerationB, 1);
      expect(repositoryA.countCalls - baselineCountA, 1);
      expect(repositoryB.countCalls - baselineCountB, 1);
    } finally {
      await sourceA.disposeAndWait();
      await sourceB.disposeAndWait();
      await invalidations.close();
    }
  });

  test("shared flush starts later sources before propagating a sync error",
      () async {
    final invalidations = _SharedViewerInvalidations();
    final rows = List<FolderItem>.generate(3, _link);
    final repositoryA = _LeaseRepository(rows, invalidations: invalidations);
    final repositoryB = _LeaseRepository(rows, invalidations: invalidations);
    final sourceA = CatalogPager<FolderItem, ViewerQuery>(source: repositoryA);
    final sourceB = CatalogPager<FolderItem, ViewerQuery>(source: repositoryB);

    try {
      await sourceA.setQuery(const ViewerQuery(searchText: "first"));
      await sourceB.setQuery(const ViewerQuery(searchText: "second"));
      final baselineGenerationA = sourceA.summaryGeneration.value;
      final baselineGenerationB = sourceB.summaryGeneration.value;
      final baselineCountB = repositoryB.countCalls;
      final baselineFacetsB = repositoryB.facetCalls;
      final subscriberFailure = StateError("source A subscriber failed");
      var failNextGeneration = false;
      final unsubscribe = sourceA.summaryGeneration.subscribe((generation) {
        if (failNextGeneration && generation > baselineGenerationA) {
          throw subscriberFailure;
        }
      });

      try {
        failNextGeneration = true;
        await expectLater(
          sourceB.runBulkUpdate(() async {
            repositoryB.invalidate();
            await Future<void>.delayed(Duration.zero);
          }),
          throwsA(
            isA<SignalEffectException>().having(
              (error) => error.error,
              "original error",
              same(subscriberFailure),
            ),
          ),
        );

        expect(sourceA.summaryGeneration.value - baselineGenerationA, 1);
        expect(sourceB.summaryGeneration.value - baselineGenerationB, 1);
        expect(repositoryB.countCalls - baselineCountB, 1);
        expect(repositoryB.facetCalls - baselineFacetsB, 1);
        expect(sourceB.invalidationCoordinator.dirtySourceCount, 0);
      } finally {
        failNextGeneration = false;
        unsubscribe();
      }
    } finally {
      await sourceA.disposeAndWait();
      await sourceB.disposeAndWait();
      await invalidations.close();
    }
  });

  test("dirty shared-domain source unregisters when disposed during bulk",
      () async {
    final invalidations = _SharedViewerInvalidations();
    final rows = List<FolderItem>.generate(3, _link);
    final repositoryA = _LeaseRepository(rows, invalidations: invalidations);
    final repositoryB = _LeaseRepository(rows, invalidations: invalidations);
    final sourceA = CatalogPager<FolderItem, ViewerQuery>(source: repositoryA);
    final sourceB = CatalogPager<FolderItem, ViewerQuery>(source: repositoryB);

    try {
      await sourceA.setQuery(const ViewerQuery(searchText: "disposed"));
      await sourceB.setQuery(const ViewerQuery(searchText: "active"));
      final baselineCountA = repositoryA.countCalls;
      final baselineFacetsA = repositoryA.facetCalls;
      final baselineGenerationB = sourceB.summaryGeneration.value;
      expect(
        identical(
          sourceA.invalidationCoordinator,
          sourceB.invalidationCoordinator,
        ),
        isTrue,
      );
      expect(sourceB.invalidationCoordinator.registeredSourceCount, 2);
      var disposedA = false;
      final service = ViewerBulkService(
        repository: repositoryB,
        bulkUpdateBoundary: sourceB,
        batchSize: 1,
        deleteItem: (item) async {
          repositoryB.invalidate();
          await Future<void>.delayed(Duration.zero);
          if (!disposedA) {
            disposedA = true;
            await sourceA.disposeAndWait();
          }
          return true;
        },
      );

      await service.delete(
        CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>(
          query: const ViewerQuery(),
          totalCount: rows.length,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(repositoryA.countCalls, baselineCountA);
      expect(repositoryA.facetCalls, baselineFacetsA);
      expect(sourceB.summaryGeneration.value - baselineGenerationB, 1);
      expect(sourceB.invalidationCoordinator.registeredSourceCount, 1);
      expect(sourceB.invalidationCoordinator.dirtySourceCount, 0);
    } finally {
      await sourceA.disposeAndWait();
      await sourceB.disposeAndWait();
      await invalidations.close();
    }
  });

  test("delete batches query rows including virtual parents in one lease",
      () async {
    final rows = List<FolderItem>.generate(235, _link);
    final prefix = _folder("parent");
    final repository = _LeaseRepository(<FolderItem>[...rows, prefix]);
    final failedKey = _key(rows[120]);
    final processed = <ViewerItemKey>[];
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: _immediateBulkBoundary,
      deleteItem: (item) async {
        processed.add(_key(item));
        if (_key(item) == failedKey) throw StateError("structured failure");
        return true;
      },
    );
    const query = ViewerQuery(
      folderId: "current-folder",
      includeFolderParents: true,
      types: <FolderItemType>{FolderItemType.folder, FolderItemType.link},
    );
    final exclusions = <ViewerItemKey>{
      _key(rows[1]),
      _key(rows[2]),
      _key(rows[3]),
    };
    final selection = CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>(
      query: query,
      totalCount: rows.length + 1,
      excluded: exclusions,
    );

    final result = await service.delete(
      selection,
      expectedCount: 233,
    );

    expect(result.processed, 233);
    expect(result.succeeded, 232);
    expect(result.failed, 1);
    expect(processed, hasLength(233));
    expect(processed, contains(_key(rows.last)));
    expect(processed, contains(_key(prefix)));
    expect(repository.requestedLimits, isNotEmpty);
    expect(repository.requestedLimits.every((limit) => limit <= 100), isTrue);
    expect(repository.releaseCalls, 1);
    expect(repository.countLeaseCalls, 1);
    expect(service.retainedBatchRowCount, 0);
    expect(repository.createdOnlyKeys.first, isNull);
    expect(repository.createdExcludedKeys.first, exclusions);
  });

  test("tag continues after one item failure and preserves typed key identity",
      () async {
    final sameIdLink = FolderItem.link(
      id: "same-id",
      itemId: null,
      url: "https://same-id.example/path",
      archiveOrg: null,
      archiveIs: null,
      createdAt: DateTime.utc(2026, 8, 10),
      tags: const <Tag>[],
    );
    final sameIdFolder = _folder("same-id");
    final tail = _link(2);
    final repository = _LeaseRepository(
      <FolderItem>[sameIdLink, sameIdFolder, tail],
    );
    final calls = <ViewerItemKey>[];
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: _immediateBulkBoundary,
      tagItem: (item, tagsToAdd, tagsToRemove) async {
        expect(tagsToAdd, <String>{"add"});
        expect(tagsToRemove, <String>{"remove"});
        calls.add(_key(item));
        if (item.type == FolderItemType.folder) {
          throw StateError("one item failed");
        }
        return true;
      },
    );
    final selection = CatalogExplicitSelection<ViewerItemKey, ViewerQuery>(<ViewerItemKey>{
      _key(sameIdLink),
      _key(sameIdFolder),
      _key(tail),
    });

    final result = await service.tag(
      selection,
      tagsToAdd: const <String>{"add"},
      tagsToRemove: const <String>{"remove"},
    );

    expect(result.processed, 3);
    expect(result.succeeded, 2);
    expect(result.failed, 1);
    expect(calls.toSet(), <ViewerItemKey>{
      _key(sameIdLink),
      _key(sameIdFolder),
      _key(tail),
    });
    expect(repository.releaseCalls, 1);
    expect(service.retainedBatchRowCount, 0);
  });

  test("metadata refresh caps concurrency at three and continues failures",
      () async {
    final rows = List<FolderItem>.generate(205, _link);
    final repository = _LeaseRepository(rows);
    var active = 0;
    var maxActive = 0;
    final refreshed = <String>[];
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: _immediateBulkBoundary,
      refreshMetadata: (url) async {
        active++;
        maxActive = max(maxActive, active);
        await Future<void>.delayed(Duration.zero);
        active--;
        refreshed.add(url);
        if (url ==
            rows[101].map(
              link: (link) => link.url,
              document: (_) => "",
              folder: (_) => "",
            )) {
          throw StateError("refresh failed");
        }
        return MetadataRefreshResult(
          url: url,
          outcome: MetadataRefreshOutcome.updated,
          state: const MetadataState.unavailable(),
        );
      },
    );

    final result = await service.refreshMetadata(
      CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>(
        query: const ViewerQuery(
          types: <FolderItemType>{FolderItemType.link},
        ),
        totalCount: rows.length,
      ),
    );

    expect(result.processed, 205);
    expect(result.succeeded, 204);
    expect(result.failed, 1);
    expect(refreshed, hasLength(205));
    expect(maxActive, 3);
    expect(repository.requestedLimits.every((limit) => limit <= 100), isTrue);
    expect(repository.releaseCalls, 1);
    expect(service.retainedBatchRowCount, 0);
  });

  test("metadata treats only updated and unchanged as success", () async {
    final rows = List<FolderItem>.generate(5, _link);
    final repository = _LeaseRepository(rows);
    final outcomes = <MetadataRefreshOutcome>[
      MetadataRefreshOutcome.updated,
      MetadataRefreshOutcome.unchanged,
      MetadataRefreshOutcome.rejected,
      MetadataRefreshOutcome.failed,
      MetadataRefreshOutcome.skipped,
    ];
    var index = 0;
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: _immediateBulkBoundary,
      refreshMetadata: (url) async => MetadataRefreshResult(
        url: url,
        outcome: outcomes[index++],
        state: const MetadataState.unavailable(),
      ),
    );

    final result = await service.refreshMetadata(
      CatalogExplicitSelection<ViewerItemKey, ViewerQuery>(rows.map(_key).toSet()),
    );

    expect(result.processed, 5);
    expect(result.succeeded, 2);
    expect(result.failed, 3);
  });

  test("expected count mismatch aborts the same lease before processing",
      () async {
    final rows = List<FolderItem>.generate(3, _link);
    final repository = _LeaseRepository(rows);
    var processed = 0;
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: _immediateBulkBoundary,
      deleteItem: (item) async {
        processed++;
        return true;
      },
    );

    await expectLater(
      service.delete(
        const CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>(
          query: ViewerQuery(),
          totalCount: 2,
        ),
        expectedCount: 2,
      ),
      throwsA(isA<ViewerSelectionChangedException>()),
    );

    expect(processed, 0);
    expect(repository.loadCalls, 0);
    expect(repository.consumeCalls, 0);
    expect(repository.countLeaseCalls, 1);
    expect(repository.releaseCalls, 1);
    expect(service.retainedBatchRowCount, 0);
  });

  test("consume failure aborts before refetch and always releases the lease",
      () async {
    final rows = List<FolderItem>.generate(150, _link);
    final repository = _LeaseRepository(rows)..failNextConsume = true;
    var terminalItems = 0;
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: _immediateBulkBoundary,
      deleteItem: (item) async {
        terminalItems++;
        return true;
      },
    );

    await expectLater(
      service.delete(
        CatalogAllMatchingSelection<ViewerItemKey, ViewerQuery>(
          query: const ViewerQuery(),
          totalCount: rows.length,
        ),
      ),
      throwsStateError,
    );

    expect(terminalItems, 100);
    expect(repository.loadCalls, 1);
    expect(repository.consumeCalls, 1);
    expect(repository.releaseCalls, 1);
    expect(service.retainedBatchRowCount, 0);
  });

  test("batch size must stay within the database contract", () {
    final repository = _LeaseRepository(<FolderItem>[]);

    expect(
      () => ViewerBulkService(
        repository: repository,
        bulkUpdateBoundary: _immediateBulkBoundary,
        batchSize: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => ViewerBulkService(
        repository: repository,
        bulkUpdateBoundary: _immediateBulkBoundary,
        batchSize: 101,
      ),
      throwsArgumentError,
    );
  });
}
