import "dart:async";
import "dart:math";

import "package:cache_manager/cache_manager.dart";
import "package:chenron/features/viewer/services/viewer_bulk_service.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/features/viewer/state/viewer_selection_state.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter_test/flutter_test.dart";

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

class _LeaseRepository implements ViewerPageRepository {
  _LeaseRepository(List<FolderItem> rows)
      : _rowsByKey = <ViewerItemKey, FolderItem>{
          for (final row in rows) _key(row): row,
        };

  final Map<ViewerItemKey, FolderItem> _rowsByKey;
  final Map<String, List<FolderItem>> _leases = <String, List<FolderItem>>{};
  final List<int> requestedLimits = <int>[];
  final List<Set<ViewerItemKey>?> createdOnlyKeys = <Set<ViewerItemKey>?>[];
  final List<Set<ViewerItemKey>> createdExcludedKeys = <Set<ViewerItemKey>>[];
  int releaseCalls = 0;
  int loadCalls = 0;
  int consumeCalls = 0;
  bool failNextConsume = false;

  @override
  Future<ViewerSelectionLease> createSelectionLease({
    required ViewerQuery query,
    Set<ViewerItemKey>? onlyKeys,
    Set<ViewerItemKey> excludedKeys = const <ViewerItemKey>{},
  }) async {
    createdOnlyKeys.add(onlyKeys == null ? null : Set.of(onlyKeys));
    createdExcludedKeys.add(Set.of(excludedKeys));
    final lease = ViewerSelectionLease("lease-${_leases.length}");
    final selectedKeys = onlyKeys ??
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
    ViewerSelectionLease lease, {
    required int limit,
  }) async {
    loadCalls++;
    requestedLimits.add(limit);
    return _leases[lease.id]!.take(limit).toList(growable: false);
  }

  @override
  Future<void> consumeSelectionLeaseBatch(
    ViewerSelectionLease lease,
    Iterable<ViewerItemKey> consumed,
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
  Future<void> releaseSelectionLease(ViewerSelectionLease lease) async {
    releaseCalls++;
    _leases.remove(lease.id);
  }

  @override
  Future<int> count(ViewerQuery query) => throw UnimplementedError();

  @override
  Stream<void> invalidations() => const Stream<void>.empty();

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<ViewerTagFacet>> loadTagFacets(ViewerQuery query) =>
      throw UnimplementedError();
}

void main() {
  test("delete batches query rows and explicit prefix keys without retention",
      () async {
    final rows = List<FolderItem>.generate(235, _link);
    final prefix = _folder("parent");
    final repository = _LeaseRepository(<FolderItem>[...rows, prefix]);
    final failedKey = _key(rows[120]);
    final processed = <ViewerItemKey>[];
    final service = ViewerBulkService(
      repository: repository,
      deleteItem: (item) async {
        processed.add(_key(item));
        if (_key(item) == failedKey) throw StateError("structured failure");
        return true;
      },
    );
    const query = ViewerQuery(types: <FolderItemType>{FolderItemType.link});
    final exclusions = <ViewerItemKey>{
      _key(rows[1]),
      _key(rows[2]),
      _key(rows[3]),
    };
    final selection = AllMatchingViewerSelection(
      query: query,
      totalCount: rows.length,
      excluded: exclusions,
    );

    final result = await service.delete(
      selection,
      additionalKeys: <ViewerItemKey>{_key(prefix)},
    );

    expect(result.processed, 233);
    expect(result.succeeded, 232);
    expect(result.failed, 1);
    expect(processed, hasLength(233));
    expect(processed, contains(_key(rows.last)));
    expect(processed, contains(_key(prefix)));
    expect(repository.requestedLimits, isNotEmpty);
    expect(repository.requestedLimits.every((limit) => limit <= 100), isTrue);
    expect(repository.releaseCalls, 2);
    expect(service.retainedBatchRowCount, 0);
    expect(repository.createdOnlyKeys.first, isNull);
    expect(repository.createdExcludedKeys.first, exclusions);
    expect(repository.createdOnlyKeys.last, <ViewerItemKey>{_key(prefix)});
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
    final selection = ExplicitViewerSelection(<ViewerItemKey>{
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
      AllMatchingViewerSelection(
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

  test("consume failure aborts before refetch and always releases the lease",
      () async {
    final rows = List<FolderItem>.generate(150, _link);
    final repository = _LeaseRepository(rows)..failNextConsume = true;
    var terminalItems = 0;
    final service = ViewerBulkService(
      repository: repository,
      deleteItem: (item) async {
        terminalItems++;
        return true;
      },
    );

    await expectLater(
      service.delete(
        AllMatchingViewerSelection(
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
      () => ViewerBulkService(repository: repository, batchSize: 0),
      throwsArgumentError,
    );
    expect(
      () => ViewerBulkService(repository: repository, batchSize: 101),
      throwsArgumentError,
    );
  });
}
