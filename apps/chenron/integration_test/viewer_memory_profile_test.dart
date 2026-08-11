import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:math";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/locator.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../test/features/viewer/viewer_test.mocks.dart";
import "support/viewer_memory_probe.dart";

class _ProfileViewerRepository implements ViewerPageRepository {
  _ProfileViewerRepository(this.itemCount);

  final int itemCount;
  final List<({int limit, int offset})> pageRequests = [];
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
    pageRequests.add((limit: limit, offset: offset));
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
  _ProfileCycle(this.itemCount)
      : repository = _ProfileViewerRepository(itemCount);

  final int itemCount;
  final _ProfileViewerRepository repository;
  ViewerPresenter? _presenter;
  var _viewerPumped = false;
  var _left = false;

  ViewerPresenter get presenter => _presenter!;

  int get distinctRequestedPages => repository.pageRequests
      .map((request) => request.offset ~/ ViewerPageSource.defaultPageSize)
      .toSet()
      .length;

  Future<void> mount(WidgetTester tester) async {
    expect(_viewerPumped, isFalse);
    _viewerPumped = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Viewer(
          presenterFactory: () {
            if (_presenter != null) {
              throw StateError("Viewer requested more than one presenter.");
            }
            return _presenter = ViewerPresenter(repository: repository);
          },
        ),
      ),
    );
    for (var attempt = 0;
        attempt < 20 && repository.pageRequests.isEmpty;
        attempt++) {
      await tester.pump();
    }
    await tester.pump();

    expect(find.byType(Viewer), findsOneWidget);
    expect(_presenter, isNotNull);
    expect(repository.pageRequests, isNotEmpty);
    expect(repository.pageRequests.first.offset, 0);
    expect(
        repository.pageRequests.first.limit, ViewerPageSource.defaultPageSize);
    expect(
      presenter.pageSource.cachedRowCount,
      min(itemCount, ViewerPageSource.defaultPageSize),
    );
  }

  Future<void> scroll(WidgetTester tester) async {
    final grid = find.descendant(
      of: find.byType(Viewer),
      matching: find.byType(GridView),
    );
    final scrollable = find.descendant(
      of: grid,
      matching: find.byType(Scrollable),
    );
    expect(grid, findsOneWidget);
    expect(scrollable, findsOneWidget);
    final position = tester.state<ScrollableState>(scrollable).position;
    final initialPixels = position.pixels;
    final expectedPages = min(
      ViewerPageSource.defaultMaxCachedPages + 1,
      (itemCount + ViewerPageSource.defaultPageSize - 1) ~/
          ViewerPageSource.defaultPageSize,
    );
    final pageDistance = max(
      600.0,
      position.maxScrollExtent *
          min(ViewerPageSource.defaultPageSize, itemCount) /
          itemCount,
    );
    var attempts = 0;
    do {
      await tester.drag(grid, Offset(0, -pageDistance));
      await tester.pump();
      await tester.pump();
      attempts++;
    } while (distinctRequestedPages < expectedPages && attempts < 12);

    expect(position.pixels, greaterThan(initialPixels));
    expect(
      distinctRequestedPages,
      greaterThanOrEqualTo(expectedPages),
    );
    expect(
      repository.pageRequests.every(
        (request) => request.limit == ViewerPageSource.defaultPageSize,
      ),
      isTrue,
    );
    expect(
      presenter.pageSource.cachedRowCount,
      min(
        itemCount,
        ViewerPageSource.defaultPageSize *
            ViewerPageSource.defaultMaxCachedPages,
      ),
    );
  }

  Future<void> leave(WidgetTester tester) async {
    if (_left) return;
    _left = true;
    if (_viewerPumped) {
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox.shrink()),
      );
      await tester.pump();
    }
    final createdPresenter = _presenter;
    if (createdPresenter != null) {
      expect(find.byType(Viewer), findsNothing);
      expect(createdPresenter.retentionSnapshot.disposed, isTrue);
      final cancellation = createdPresenter.pageSource.invalidationCancellation;
      expect(cancellation, isNotNull);
      await tester.runAsync(() => cancellation!);
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
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await locator.reset();
    locator.registerSingleton<SettingsCoordinator>(SettingsCoordinator(
      configService: MockConfigService(),
      dataService: MockDataSettingsService(),
      themeApplier: MockThemeNotifier(),
      optionsStore: ThemeOptionsStore(),
    ));
    await tester.binding.setSurfaceSize(const Size(1600, 900));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.binding.setSurfaceSize(null);
      await locator.reset();
    });
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
    addTearDown(() => firstCycle.leave(tester));
    await firstCycle.mount(tester);

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

    await firstCycle.scroll(tester);

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

    await firstCycle.leave(tester);

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
      try {
        await profileCycle.mount(tester);
        await profileCycle.scroll(tester);
      } finally {
        await profileCycle.leave(tester);
      }
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
