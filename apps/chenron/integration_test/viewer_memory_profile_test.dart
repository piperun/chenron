import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:math";

import "package:cache_manager/cache_manager.dart" hide ImageCacheManager;
import "package:chenron/components/favicon_display/favicon.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/locator.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../test/features/viewer/viewer_test.mocks.dart";
import "support/viewer_memory_probe.dart";

final class _ProfileDatabaseFixture {
  _ProfileDatabaseFixture._(this.database, this.file);

  static const int _seedBatchSize = 1000;
  static const int _tagCount = 32;

  final AppDatabase database;
  final File file;

  static Future<_ProfileDatabaseFixture> create(int itemCount) async {
    final seedStopwatch = Stopwatch()..start();
    final tempDirectory = Directory.systemTemp.absolute;
    final file = File(
      "${tempDirectory.path}${Platform.pathSeparator}"
      "chenron-viewer-profile-$pid-$itemCount.sqlite",
    ).absolute;
    if (file.parent.path != tempDirectory.path) {
      throw StateError("Profile database escaped the configured temp folder.");
    }
    if (file.existsSync()) {
      throw StateError("Profile database path already exists: ${file.path}");
    }

    final database = AppDatabase(queryExecutor: NativeDatabase(file));
    final fixture = _ProfileDatabaseFixture._(database, file);
    try {
      await fixture._seed(itemCount);
      seedStopwatch.stop();
      // Generic timing only; fixture rows and paths remain private.
      // ignore: avoid_print
      print(jsonEncode(<String, Object>{
        "profileFixtureItemCount": itemCount,
        "profileFixtureSeedMilliseconds": seedStopwatch.elapsedMilliseconds,
      }));
      return fixture;
    } catch (_) {
      await fixture.dispose();
      rethrow;
    }
  }

  Future<void> _seed(int itemCount) async {
    final createdAt = DateTime.utc(2026, 8, 10);
    await database.transaction(() async {
      await database.batch((batch) {
        for (var tag = 0; tag < _tagCount; tag++) {
          batch.insert(
            database.tags,
            TagsCompanion.insert(
              id: _tagId(tag),
              name: "topic-${tag.toString().padLeft(2, "0")}",
              createdAt: Value(createdAt.add(Duration(seconds: tag))),
            ),
          );
        }
      });

      for (var start = 0; start < itemCount; start += _seedBatchSize) {
        final end = min(start + _seedBatchSize, itemCount);
        await database.batch((batch) {
          for (var index = start; index < end; index++) {
            final padded = index.toString().padLeft(7, "0");
            final itemId = _id(index.isEven ? "f" : "l", index);
            final itemCreatedAt = createdAt.add(Duration(seconds: index));
            if (index.isEven) {
              batch.insert(
                database.folders,
                FoldersCompanion.insert(
                  id: itemId,
                  title: "profile-$padded.example",
                  description: "Generic profile folder ${index % 97}: "
                      "bounded viewer description ${index % 13}",
                  createdAt: Value(itemCreatedAt),
                ),
              );
            } else {
              batch.insert(
                database.links,
                LinksCompanion.insert(
                  id: itemId,
                  path: "https://profile-$padded.example/link/${index % 211}",
                  createdAt: Value(itemCreatedAt),
                ),
              );
            }

            final firstTag = index % _tagCount;
            final secondTag = (index * 7 + 3) % _tagCount;
            batch.insert(
              database.metadataRecords,
              MetadataRecordsCompanion.insert(
                id: _id("ma", index),
                typeId: MetadataTypeEnum.tag,
                itemId: itemId,
                metadataId: _tagId(firstTag),
              ),
            );
            if (secondTag != firstTag) {
              batch.insert(
                database.metadataRecords,
                MetadataRecordsCompanion.insert(
                  id: _id("mb", index),
                  typeId: MetadataTypeEnum.tag,
                  itemId: itemId,
                  metadataId: _tagId(secondTag),
                ),
              );
            }
          }
        });
      }
    });
  }

  static String _tagId(int index) => _id("t", index);

  static String _id(String prefix, int index) =>
      "$prefix${index.toString().padLeft(30 - prefix.length, "0")}";

  Future<void> dispose() async {
    await database.close();
    for (final suffix in <String>["", "-wal", "-shm"]) {
      final target = File("${file.path}$suffix").absolute;
      if (target.parent.path != file.parent.path) {
        throw StateError("Profile cleanup target escaped its temp folder.");
      }
      final type = FileSystemEntity.typeSync(target.path, followLinks: false);
      if (type == FileSystemEntityType.notFound) continue;
      if (type != FileSystemEntityType.file) {
        throw StateError("Unexpected profile cleanup target: ${target.path}");
      }
      await target.delete();
    }
  }
}

class _ProfileViewerRepository
    implements ViewerPageRepository, ViewerTagFacetSearchRepository {
  _ProfileViewerRepository(this.database);

  final AppDatabase database;
  final List<({int limit, int offset})> pageRequests = [];

  @override
  Future<int> count(ViewerQuery query) => database.getViewerItemCount(query);

  @override
  Future<List<ViewerTagFacet>> loadTagFacets(
    ViewerQuery query, {
    String searchText = "",
  }) =>
      database.getViewerTagFacets(query, searchText: searchText);

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) {
    pageRequests.add((limit: limit, offset: offset));
    return database.getViewerPage(query, limit: limit, offset: offset);
  }

  @override
  Stream<void> invalidations() => database.watchViewerInvalidations();

  @override
  Future<ViewerSelectionLease> createSelectionLease({
    required ViewerQuery query,
    Set<ViewerItemKey>? onlyKeys,
    Set<ViewerItemKey> excludedKeys = const <ViewerItemKey>{},
  }) =>
      database.createViewerSelectionLease(
        query: query,
        onlyKeys: onlyKeys,
        excludedKeys: excludedKeys,
      );

  @override
  Future<List<FolderItem>> loadSelectionLeaseBatch(
    ViewerSelectionLease lease, {
    required int limit,
  }) =>
      database.getViewerSelectionLeaseBatch(lease, limit: limit);

  @override
  Future<int> countSelectionLease(ViewerSelectionLease lease) =>
      database.getViewerSelectionLeaseCount(lease);

  @override
  Future<void> consumeSelectionLeaseBatch(
    ViewerSelectionLease lease,
    Iterable<ViewerItemKey> consumed,
  ) =>
      database.consumeViewerSelectionLeaseBatch(lease, consumed);

  @override
  Future<void> releaseSelectionLease(ViewerSelectionLease lease) =>
      database.releaseViewerSelectionLease(lease);
}

void _printSnapshot(ViewerMemorySnapshot snapshot) {
  // One machine-readable object per profile checkpoint.
  // ignore: avoid_print
  print(jsonEncode(snapshot.toJson()));
}

Future<ViewerMemorySnapshot> _capture(
  WidgetTester tester,
  ViewerMemoryProbe probe,
  String label,
  ViewerRetentionSnapshot retention,
) async {
  final cache = locator.get<MetadataCache>();
  final metadata = locator.get<MetadataService>();
  final runtimeCaches = ViewerRuntimeCacheSnapshot(
    metadataCacheSize: cache.memoryCacheSize,
    metadataCacheCapacity: cache.memoryCacheCapacity,
    metadataSignalCacheSize: metadata.signalCacheSize,
    metadataSignalCacheCapacity: metadata.signalCacheCapacity,
    metadataDomainThrottleSize: metadata.domainThrottleMapSize,
    metadataInFlightRequests: metadata.inFlightRequestCount,
    metadataActiveFetches: metadata.activeFetchCount,
    metadataQueuedFetches: metadata.queuedFetchCount,
    metadataMaxConcurrentFetches: metadata.maxConcurrentFetches,
    faviconCacheSize: Favicon.debugCacheSize,
    faviconCacheCapacity: Favicon.debugMaxCacheSize,
  );
  final snapshot = (await tester.runAsync(
    () => probe.capture(label, retention, runtimeCaches),
  ))!;
  expect(snapshot.processWorkingSetBytes, greaterThan(0));
  if (Platform.isWindows) {
    expect(snapshot.processPrivateBytes, greaterThan(0));
  }
  if (kProfileMode) {
    expect(snapshot.dartHeapUsedBytes, greaterThan(0));
    expect(snapshot.dartHeapCapacityBytes, greaterThan(0));
    expect(snapshot.externalMemoryBytes, greaterThanOrEqualTo(0));
  }
  expect(snapshot.cachedViewerPages, lessThanOrEqualTo(5));
  expect(snapshot.retainedViewerRows, lessThanOrEqualTo(500));
  expect(snapshot.activeViewerPageLoads, lessThanOrEqualTo(4));
  expect(snapshot.queuedViewerPageLoads, lessThanOrEqualTo(16));
  expect(snapshot.retainedViewerPageErrors, lessThanOrEqualTo(20));
  expect(snapshot.activeViewerSummaryLoads, lessThanOrEqualTo(1));
  expect(snapshot.metadataCacheSize, lessThanOrEqualTo(100));
  expect(snapshot.metadataSignalCacheSize, lessThanOrEqualTo(100));
  expect(
    snapshot.metadataActiveFetches,
    lessThanOrEqualTo(snapshot.metadataMaxConcurrentFetches),
  );
  expect(snapshot.faviconCacheSize, lessThanOrEqualTo(500));
  expect(snapshot.imageCacheBytes, 0);
  return snapshot;
}

final class _ProfileCycle {
  _ProfileCycle(this.itemCount, this.repository, this.metadataService);

  final int itemCount;
  final _ProfileViewerRepository repository;
  final MetadataService metadataService;
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
    repository.pageRequests.clear();
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
        attempt < 100 &&
            (repository.pageRequests.isEmpty ||
                presenter.pageSource.cachedRowCount == 0);
        attempt++) {
      await tester.pump();
      await Future<void>.delayed(Duration.zero);
    }

    expect(find.byType(Viewer), findsOneWidget);
    expect(repository.pageRequests, isNotEmpty);
    expect(repository.pageRequests.first.offset, 0);
    expect(
      repository.pageRequests.first.limit,
      ViewerPageSource.defaultPageSize,
    );
    expect(
      presenter.pageSource.cachedRowCount,
      min(itemCount, ViewerPageSource.defaultPageSize),
    );
    await metadataService.settle();
    metadataService.cleanupStale();
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
      await Future<void>.delayed(Duration.zero);
      attempts++;
    } while (distinctRequestedPages < expectedPages && attempts < 16);
    for (var attempt = 0;
        attempt < 100 && presenter.pageSource.activeLoadCount > 0;
        attempt++) {
      await tester.pump();
      await Future<void>.delayed(Duration.zero);
    }
    await metadataService.settle();
    metadataService.cleanupStale();

    expect(position.pixels, greaterThan(initialPixels));
    expect(distinctRequestedPages, greaterThanOrEqualTo(expectedPages));
    expect(
      repository.pageRequests.every(
        (request) => request.limit == ViewerPageSource.defaultPageSize,
      ),
      isTrue,
    );
    expect(presenter.pageSource.cachedRowCount, lessThanOrEqualTo(500));
  }

  Future<void> leave(WidgetTester tester) async {
    if (_left) return;
    _left = true;
    if (_viewerPumped) {
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();
    }
    final createdPresenter = _presenter;
    if (createdPresenter != null) {
      expect(find.byType(Viewer), findsNothing);
      await tester.runAsync(createdPresenter.disposeAndWait);
      await tester.runAsync(metadataService.settle);
      metadataService.cleanupStale();
      expect(createdPresenter.retentionSnapshot.disposed, isTrue);
      expect(createdPresenter.retentionSnapshot.settled, isTrue);
    }
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
    expect(itemCount, greaterThan(0));

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await locator.reset();
    final fixture = (await tester.runAsync(
      () => _ProfileDatabaseFixture.create(itemCount),
    ))!;
    addTearDown(() => tester.runAsync(fixture.dispose));
    final repository = _ProfileViewerRepository(fixture.database);
    final metadataCache = MetadataCache();
    final metadataService = MetadataService(
      cache: metadataCache,
      failures: FailureTracker(),
      domainCircuitBreaker: DomainCircuitBreaker(),
      maxConcurrent: 3,
      domainDelay: Duration.zero,
      fetcher: (url, {previous}) async => MetadataModified(
        candidate: MetadataCandidate(
          title: "Profile link ${Uri.parse(url).pathSegments.last}",
          description: "Generic offline profile metadata",
          resolvedUrl: url,
        ),
        statusCode: 200,
        responseBytes: 256,
        elapsed: Duration.zero,
      ),
    );
    locator.registerSingleton<MetadataCache>(metadataCache);
    locator.registerSingleton<MetadataService>(
      metadataService,
      dispose: (service) => service.dispose(),
    );
    locator.registerSingleton<SettingsCoordinator>(SettingsCoordinator(
      configService: MockConfigService(),
      dataService: MockDataSettingsService(),
      themeApplier: MockThemeNotifier(),
      optionsStore: ThemeOptionsStore(),
    ));
    Favicon.debugClearCache();
    Favicon.debugResolver = (_) async => null;
    await tester.binding.setSurfaceSize(const Size(1600, 900));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.binding.setSurfaceSize(null);
      Favicon.debugResolver = null;
      Favicon.debugClearCache();
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
        settled: true,
      ),
    );
    _printSnapshot(cold);

    final firstCycle = _ProfileCycle(itemCount, repository, metadataService);
    addTearDown(() => firstCycle.leave(tester));
    await firstCycle.mount(tester);

    final afterOpen = await _capture(
      tester,
      probe,
      "open",
      firstCycle.presenter.retentionSnapshot,
    );
    _printSnapshot(afterOpen);
    expect(afterOpen.viewerSubscriptions, 1);

    await firstCycle.scroll(tester);
    final afterScroll = await _capture(
      tester,
      probe,
      "scroll",
      firstCycle.presenter.retentionSnapshot,
    );
    _printSnapshot(afterScroll);
    expect(afterScroll.viewerSubscriptions, 1);

    await firstCycle.leave(tester);
    final afterLeave = await _capture(
      tester,
      probe,
      "leave",
      firstCycle.presenter.retentionSnapshot,
    );
    _printSnapshot(afterLeave);
    _expectSettledAfterLeave(afterLeave);

    late ViewerMemorySnapshot afterTenCycles;
    for (var cycle = 2; cycle <= 10; cycle++) {
      final profileCycle = _ProfileCycle(
        itemCount,
        repository,
        metadataService,
      );
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
      _expectSettledAfterLeave(snapshot, reason: "cycle $cycle");
      if (cycle == 10) afterTenCycles = snapshot;
    }
    _expectSettledAfterLeave(afterTenCycles);
  });
}

void _expectSettledAfterLeave(
  ViewerMemorySnapshot snapshot, {
  String? reason,
}) {
  expect(snapshot.retainedViewerRows, 0, reason: reason);
  expect(snapshot.cachedViewerPages, 0, reason: reason);
  expect(snapshot.activeViewerPageLoads, 0, reason: reason);
  expect(snapshot.queuedViewerPageLoads, 0, reason: reason);
  expect(snapshot.activeViewerSummaryLoads, 0, reason: reason);
  expect(snapshot.dirtyViewerSummaryRefresh, isFalse, reason: reason);
  expect(snapshot.viewerSubscriptions, 0, reason: reason);
  expect(snapshot.viewerSettled, isTrue, reason: reason);
  expect(snapshot.metadataInFlightRequests, 0, reason: reason);
  expect(snapshot.metadataActiveFetches, 0, reason: reason);
  expect(snapshot.metadataQueuedFetches, 0, reason: reason);
  expect(snapshot.metadataDomainThrottleSize, 0, reason: reason);
}
