import "dart:async";
import "dart:math";

import "package:cache_manager/cache_manager.dart";
import "package:chenron/features/viewer/services/viewer_bulk_service.dart";
import "package:catalog/catalog.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/viewer/item_handler.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:drift/native.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:signals/signals.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  test("refreshMetadataUrls deduplicates, caps workers, and summarizes",
      () async {
    final processed = <String>[];
    var active = 0;
    var maxObserved = 0;
    final gate = Completer<void>();
    final urls = [
      "https://example.com/updated",
      "https://example.com/unchanged",
      "https://example.com/skipped",
      "https://example.com/rejected",
      "https://example.com/failed",
      "https://example.com/updated",
    ];

    final future = refreshMetadataUrls(
      urls,
      maxConcurrent: 3,
      refreshOne: (url) async {
        processed.add(url);
        active++;
        maxObserved = max(maxObserved, active);
        await gate.future;
        active--;
        return _result(
          url,
          MetadataRefreshOutcome.values
              .byName(Uri.parse(url).pathSegments.last),
        );
      },
    );

    await pumpEventQueue();
    expect(maxObserved, 3);

    gate.complete();
    final summary = await future;

    expect(processed.toSet(), urls.toSet());
    expect(processed.length, 5);
    expect(summary.updated, 1);
    expect(summary.unchanged, 1);
    expect(summary.skipped, 1);
    expect(summary.rejected, 1);
    expect(summary.failed, 1);
    expect(summary.total, 5);
  });

  test("metadata refresh message reports every terminal category", () {
    const summary = MetadataRefreshSummary(
      updated: 4,
      unchanged: 7,
      skipped: 2,
      rejected: 1,
    );

    expect(
      metadataRefreshSummaryMessage(summary),
      "Metadata: 4 updated, 7 unchanged, 2 skipped, 1 rejected, 0 failed",
    );
  });

  test("refreshMetadataUrls rejects a non-positive worker cap", () async {
    await expectLater(
      refreshMetadataUrls(
        ["https://example.com/item"],
        refreshOne: (url) async => _result(url, MetadataRefreshOutcome.updated),
        maxConcurrent: 0,
      ),
      throwsArgumentError,
    );
  });

  test("refreshMetadataUrls counts a thrown item failure and continues",
      () async {
    final processed = <String>[];
    final summary = await refreshMetadataUrls(
      <String>[
        "https://first.example/path",
        "https://failed.example/path",
        "https://last.example/path",
      ],
      refreshOne: (url) async {
        processed.add(url);
        if (url == "https://failed.example/path") {
          throw StateError("failed");
        }
        return _result(url, MetadataRefreshOutcome.updated);
      },
      maxConcurrent: 3,
    );

    expect(processed, hasLength(3));
    expect(summary.updated, 2);
    expect(summary.failed, 1);
    expect(summary.total, 3);
  });

  testWidgets("selection delete confirms count and releases the lease",
      (tester) async {
    _unmountAfterTest(tester);
    final item = _folder("delete-folder");
    final repository = _HandlerRepository(item);
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: const _ImmediateBulkBoundary(),
      deleteItem: (_) async => true,
    );
    final target = CatalogSelectionTarget<ViewerItemKey, ViewerQuery>(
      selection: CatalogExplicitSelection<ViewerItemKey, ViewerQuery>(<ViewerItemKey>{_key(item)}),
    );

    await tester.pumpWidget(_handlerHost(
      onPressed: (context) => handleViewerSelectionDeletion(
        context,
        target,
        service,
        () {},
      ),
    ));
    await tester.tap(find.text("Run"));
    await tester.pumpAndSettle();

    expect(find.text("Delete Item?"), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, "Delete"));
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.pump();
      if (repository.releaseCalls == 1) break;
    }
    await tester.pump();

    expect(find.text("Deleted 1 of 1 items"), findsOneWidget);
    expect(repository.consumeCalls, 1);
    expect(repository.releaseCalls, 1);
    expect(service.retainedBatchRowCount, 0);
  });

  testWidgets("selection invalidated during confirmation never opens a lease",
      (tester) async {
    _unmountAfterTest(tester);
    final item = _folder("stale-delete-folder");
    final repository = _HandlerRepository(item);
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: const _ImmediateBulkBoundary(),
      deleteItem: (_) async => true,
    );
    var isCurrent = true;
    final target = CatalogSelectionTarget<ViewerItemKey, ViewerQuery>(
      selection: CatalogExplicitSelection<ViewerItemKey, ViewerQuery>(<ViewerItemKey>{_key(item)}),
      isCurrent: () => isCurrent,
    );

    await tester.pumpWidget(_handlerHost(
      onPressed: (context) => handleViewerSelectionDeletion(
        context,
        target,
        service,
        () {},
      ),
    ));
    await tester.tap(find.text("Run"));
    await tester.pumpAndSettle();
    expect(find.text("Delete Item?"), findsOneWidget);

    isCurrent = false;
    await tester.tap(find.widgetWithText(FilledButton, "Delete"));
    await tester.pumpAndSettle();

    expect(repository.countLeaseCalls, 0);
    expect(repository.consumeCalls, 0);
    expect(repository.releaseCalls, 0);
  });

  testWidgets("selection tag sends primitive intent through a released lease",
      (tester) async {
    final database = AppDatabase(
      queryExecutor: NativeDatabase.memory(),
      setupOnInit: true,
    );
    await database.setup();
    await locator.reset();
    locator.registerSingleton<Signal<AppDatabaseLifecycle>>(
      signal(_TestAppDatabaseLifecycle(database)),
    );
    await database.addTag("topic");
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await locator.reset();
      await database.close();
    });
    final item = _folder("tag-folder");
    final repository = _HandlerRepository(item);
    Set<String>? additions;
    Set<String>? removals;
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: const _ImmediateBulkBoundary(),
      tagItem: (_, tagsToAdd, tagsToRemove) async {
        additions = tagsToAdd;
        removals = tagsToRemove;
        return true;
      },
    );
    final target = CatalogSelectionTarget<ViewerItemKey, ViewerQuery>(
      selection: CatalogExplicitSelection<ViewerItemKey, ViewerQuery>(<ViewerItemKey>{_key(item)}),
    );

    await tester.pumpWidget(_handlerHost(
      onPressed: (context) => handleViewerSelectionTagging(
        context,
        target,
        service,
        () {},
      ),
    ));
    await tester.tap(find.text("Run"));
    await tester.pump();
    await tester.pump();
    expect(find.text("Manage tags for 1 item"), findsOneWidget);
    await tester.tap(find.text("topic"));
    await tester.pump();
    await tester.tap(find.text("Apply (+1)"));
    await tester.pumpAndSettle();

    expect(additions, <String>{"topic"});
    expect(removals, isEmpty);
    expect(find.text("Tagged 1 of 1 items"), findsOneWidget);
    expect(repository.releaseCalls, 1);
    expect(service.retainedBatchRowCount, 0);
  });

  testWidgets("selection metadata failure is visible and releases the lease",
      (tester) async {
    _unmountAfterTest(tester);
    final item = FolderItem.link(
      id: "metadata-link",
      itemId: null,
      url: "https://metadata-failure.example/path",
      createdAt: DateTime.utc(2026, 8, 10),
      tags: const <Tag>[],
    );
    final repository = _HandlerRepository(item);
    final service = ViewerBulkService(
      repository: repository,
      bulkUpdateBoundary: const _ImmediateBulkBoundary(),
      refreshMetadata: (_) async => throw StateError("refresh failed"),
    );
    final target = CatalogSelectionTarget<ViewerItemKey, ViewerQuery>(
      selection: CatalogExplicitSelection<ViewerItemKey, ViewerQuery>(<ViewerItemKey>{_key(item)}),
    );

    await tester.pumpWidget(_handlerHost(
      onPressed: (context) => handleViewerSelectionMetadataRefresh(
        context,
        target,
        service,
      ),
    ));
    await tester.tap(find.text("Run"));
    await tester.pumpAndSettle();

    expect(
      find.text("Metadata refreshed for 0 of 1 items, 1 failed"),
      findsOneWidget,
    );
    expect(repository.consumeCalls, 1);
    expect(repository.releaseCalls, 1);
    expect(service.retainedBatchRowCount, 0);
  });
}

MetadataRefreshResult _result(
  String url,
  MetadataRefreshOutcome outcome,
) =>
    MetadataRefreshResult(
      url: url,
      outcome: outcome,
      state: const MetadataState.unavailable(),
    );

Widget _handlerHost({
  required Future<void> Function(BuildContext context) onPressed,
}) =>
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => onPressed(context),
            child: const Text("Run"),
          ),
        ),
      ),
    );

void _unmountAfterTest(WidgetTester tester) {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

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

class _HandlerRepository implements
        CatalogSource<FolderItem, ViewerQuery>,
        CatalogSelectionLeases<FolderItem, ViewerQuery> {
  _HandlerRepository(this.item);

  final FolderItem item;
  bool _consumed = false;
  int consumeCalls = 0;
  int releaseCalls = 0;
  int countLeaseCalls = 0;

  @override
  Future<CatalogSelectionLease> createSelectionLease({
    required ViewerQuery query,
    Set<Object>? onlyKeys,
    Set<Object> excludedKeys = const <Object>{},
  }) async =>
      const CatalogSelectionLease("handler-lease");

  @override
  Future<List<FolderItem>> loadSelectionLeaseBatch(
    CatalogSelectionLease lease, {
    required int limit,
  }) async =>
      _consumed ? const <FolderItem>[] : <FolderItem>[item];

  @override
  Future<void> consumeSelectionLeaseBatch(
    CatalogSelectionLease lease,
    Iterable<Object> consumed,
  ) async {
    consumeCalls++;
    _consumed = true;
  }

  @override
  Future<void> releaseSelectionLease(CatalogSelectionLease lease) async {
    releaseCalls++;
  }

  @override
  Future<int> countSelectionLease(CatalogSelectionLease lease) async {
    countLeaseCalls++;
    return _consumed ? 0 : 1;
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
  Future<List<CatalogFacetGroup>> loadFacets(ViewerQuery query) =>
      throw UnimplementedError();
}

final class _ImmediateBulkBoundary implements CatalogBulkUpdateBoundary {
  const _ImmediateBulkBoundary();

  @override
  Future<T> runBulkUpdate<T>(Future<T> Function() operation) => operation();
}

class _TestAppDatabaseLifecycle extends AppDatabaseLifecycle {
  _TestAppDatabaseLifecycle(this._database);

  final AppDatabase _database;

  @override
  AppDatabase get appDatabase => _database;
}
