import "dart:async";
import "dart:convert";
import "dart:math";

import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:database/database.dart";
import "package:database/features.dart";
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("captures cold, open, and leave viewer memory", (tester) async {
    const defaultItemCount = 100000;
    final itemCount = int.tryParse(
          const String.fromEnvironment("CHENRON_MEMORY_ITEM_COUNT"),
        ) ??
        defaultItemCount;
    final repository = _ProfileViewerRepository(itemCount);
    final presenter = ViewerPresenter(repository: repository);
    addTearDown(() async {
      presenter.dispose();
      await presenter.pageSource.invalidationCancellation;
      await repository.dispose();
    });

    final cold = captureViewerMemory("cold", presenter.retentionSnapshot);
    _printSnapshot(cold);
    expect(cold.imageCacheBytes, 0);

    await presenter.init();
    final requestedPages = min(
      ViewerPageSource.defaultMaxCachedPages + 1,
      (itemCount + ViewerPageSource.defaultPageSize - 1) ~/
          ViewerPageSource.defaultPageSize,
    );
    for (var page = 0; page < requestedPages; page++) {
      expect(
        presenter.pageSource.itemAt(
          page * ViewerPageSource.defaultPageSize,
        ),
        isNull,
      );
      await tester.pump();
    }

    final open = captureViewerMemory("open", presenter.retentionSnapshot);
    _printSnapshot(open);
    expect(
      open.retainedViewerRows,
      min(
        itemCount,
        ViewerPageSource.defaultPageSize *
            ViewerPageSource.defaultMaxCachedPages,
      ),
    );
    expect(open.viewerSubscriptions, 1);
    expect(open.imageCacheBytes, 0);

    presenter.dispose();
    await tester.runAsync(
      () => presenter.pageSource.invalidationCancellation!,
    );

    final leave = captureViewerMemory("leave", presenter.retentionSnapshot);
    _printSnapshot(leave);
    expect(leave.retainedViewerRows, 0);
    expect(leave.viewerSubscriptions, 0);
    expect(leave.imageCacheBytes, 0);
  });
}
