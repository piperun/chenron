import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:math";

import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

import "support/viewer_memory_probe.dart";

class _ProfileViewerRepository implements ViewerPageRepository {
  _ProfileViewerRepository(this.itemCount);

  final int itemCount;
  final StreamController<void> _invalidations =
      StreamController<void>.broadcast();

  @override
  Future<int> count(ViewerQuery query) async => itemCount;

  @override
  Future<List<ViewerTagFacet>> loadTagFacets(ViewerQuery query) async =>
      const <ViewerTagFacet>[];

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) async {
    final length = min(limit, max(0, itemCount - offset));
    return List<FolderItem>.generate(
      length,
      (index) => _profileItem(offset + index),
      growable: false,
    );
  }

  @override
  Stream<void> invalidations() => _invalidations.stream;

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
  Future<int> countSelectionLease(ViewerSelectionLease lease) =>
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

  Future<void> dispose() => _invalidations.close();
}

FolderItem _profileItem(int index) {
  final id = index.toString().padLeft(6, "0");
  return FolderItem.folder(
    id: "item-$id",
    itemId: null,
    folderId: "folder-$id",
    title: "Item $id",
    description: "",
    tags: const <Tag>[],
    createdAt: DateTime(2020, 1, 1),
  );
}

void _printSnapshot(ViewerMemorySnapshot snapshot) {
  // One machine-readable object per profile checkpoint.
  // The fixture has no previews, so image-cache values should remain zero.
  // ignore: avoid_print
  print(jsonEncode(snapshot.toJson()));
}

Future<ViewerMemorySnapshot> _capture(
  WidgetTester tester,
  ViewerMemoryProbe probe,
  String label,
  ViewerRetentionSnapshot retention,
) async {
  final snapshot =
      (await tester.runAsync(() => probe.capture(label, retention)))!;
  expect(snapshot.processWorkingSetBytes, greaterThan(0));
  if (Platform.isWindows) {
    expect(snapshot.processPrivateBytes, greaterThan(0));
  }
  if (kProfileMode) {
    expect(snapshot.dartHeapUsedBytes, greaterThan(0));
    expect(snapshot.dartHeapCapacityBytes, greaterThan(0));
    expect(snapshot.externalMemoryBytes, greaterThanOrEqualTo(0));
  }
  return snapshot;
}

final class _ProfileCycle {
  _ProfileCycle(int itemCount)
      : repository = _ProfileViewerRepository(itemCount) {
    presenter = ViewerPresenter(repository: repository);
  }

  final _ProfileViewerRepository repository;
  late final ViewerPresenter presenter;
  var _disposed = false;

  Future<void> init() => presenter.init();

  Future<void> requestPage(WidgetTester tester, int page) async {
    expect(
      presenter.pageSource.itemAt(
        page * ViewerPageSource.defaultPageSize,
      ),
      isNull,
    );
    await tester.pump();
    expect(
      presenter.pageSource.itemAt(
        page * ViewerPageSource.defaultPageSize,
      ),
      isNotNull,
    );
  }

  Future<void> dispose(WidgetTester tester) async {
    if (_disposed) return;
    _disposed = true;
    presenter.dispose();
    final cancellation = presenter.pageSource.invalidationCancellation;
    if (cancellation != null) {
      await tester.runAsync(() => cancellation);
    }
    await repository.dispose();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("captures bounded viewer memory through ten cycles", (
    tester,
  ) async {
    const defaultItemCount = 100000;
    final itemCount = int.tryParse(
          const String.fromEnvironment("CHENRON_MEMORY_ITEM_COUNT"),
        ) ??
        defaultItemCount;
    final probe = (await tester.runAsync(ViewerMemoryProbe.connect))!;
    addTearDown(probe.close);

    final cold = await _capture(
      tester,
      probe,
      "cold",
      const ViewerRetentionSnapshot(
        retainedRows: 0,
        activeSubscriptions: 0,
        disposed: false,
      ),
    );
    _printSnapshot(cold);
    expect(cold.imageCacheBytes, 0);

    final firstCycle = _ProfileCycle(itemCount);
    addTearDown(() => firstCycle.dispose(tester));
    await firstCycle.init();
    await firstCycle.requestPage(tester, 0);

    final afterOpen = await _capture(
      tester,
      probe,
      "open",
      firstCycle.presenter.retentionSnapshot,
    );
    _printSnapshot(afterOpen);
    expect(afterOpen.retainedViewerRows, lessThanOrEqualTo(500));
    expect(afterOpen.viewerSubscriptions, 1);
    expect(afterOpen.imageCacheBytes, 0);

    final requestedPages = min(
      ViewerPageSource.defaultMaxCachedPages + 1,
      (itemCount + ViewerPageSource.defaultPageSize - 1) ~/
          ViewerPageSource.defaultPageSize,
    );
    for (var page = 1; page < requestedPages; page++) {
      await firstCycle.requestPage(tester, page);
    }

    final afterScroll = await _capture(
      tester,
      probe,
      "scroll",
      firstCycle.presenter.retentionSnapshot,
    );
    _printSnapshot(afterScroll);
    expect(
      afterScroll.retainedViewerRows,
      min(
        itemCount,
        ViewerPageSource.defaultPageSize *
            ViewerPageSource.defaultMaxCachedPages,
      ),
    );
    expect(afterScroll.retainedViewerRows, lessThanOrEqualTo(500));
    expect(afterScroll.viewerSubscriptions, 1);
    expect(afterScroll.imageCacheBytes, 0);

    await firstCycle.dispose(tester);

    final afterLeave = await _capture(
      tester,
      probe,
      "leave",
      firstCycle.presenter.retentionSnapshot,
    );
    _printSnapshot(afterLeave);
    expect(afterLeave.retainedViewerRows, 0);
    expect(afterLeave.viewerSubscriptions, 0);
    expect(afterLeave.imageCacheBytes, 0);

    late ViewerMemorySnapshot afterTenCycles;
    for (var cycle = 2; cycle <= 10; cycle++) {
      final profileCycle = _ProfileCycle(itemCount);
      await profileCycle.init();
      for (var page = 0; page < requestedPages; page++) {
        await profileCycle.requestPage(tester, page);
      }
      await profileCycle.dispose(tester);
      final snapshot = await _capture(
        tester,
        probe,
        cycle == 10 ? "ten-cycle" : "cycle-$cycle-leave",
        profileCycle.presenter.retentionSnapshot,
      );
      _printSnapshot(snapshot);
      expect(snapshot.retainedViewerRows, 0, reason: "cycle $cycle");
      expect(snapshot.viewerSubscriptions, 0, reason: "cycle $cycle");
      expect(snapshot.imageCacheBytes, 0, reason: "cycle $cycle");
      if (cycle == 10) afterTenCycles = snapshot;
    }
    expect(afterTenCycles.retainedViewerRows, 0);
    expect(afterTenCycles.viewerSubscriptions, 0);
  });
}
