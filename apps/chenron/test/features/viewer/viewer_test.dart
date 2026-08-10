import "dart:async";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/viewer/state/viewer_page_source.dart";
import "package:chenron/locator.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:shared_preferences/shared_preferences.dart";

import "viewer_test.mocks.dart";

@GenerateMocks([ConfigService, DataSettingsService, ThemeNotifier])
void main() {
  late FakeViewerRepository fakeViewerRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    fakeViewerRepository = FakeViewerRepository();

    await locator.reset();

    locator.registerSingleton<SettingsCoordinator>(SettingsCoordinator(
      configService: MockConfigService(),
      dataService: MockDataSettingsService(),
      themeApplier: MockThemeNotifier(),
      optionsStore: ThemeOptionsStore(),
    ));
  });

  tearDown(() async {
    await fakeViewerRepository.dispose();
  });

  testWidgets("Viewer widget builds successfully", (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
    final presenter = ViewerPresenter(repository: fakeViewerRepository);

    await tester.pumpWidget(
      MaterialApp(
        home: Viewer(presenterFactory: () => presenter),
      ),
    );

    expect(find.byType(Viewer), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets("Viewer disposes each page-owned presenter across mounts",
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
    final presenters = <ViewerPresenter>[];

    for (var cycle = 0; cycle < 10; cycle++) {
      final repository = FakeViewerRepository();
      final presenter = ViewerPresenter(repository: repository);
      presenters.add(presenter);

      await tester.pumpWidget(MaterialApp(
        home: Viewer(presenterFactory: () => presenter),
      ));
      await tester.pump();
      expect(repository.activeSubscriptions, 1, reason: "mount $cycle");

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      final cancellation = presenter.pageSource.invalidationCancellation;
      expect(cancellation, isNotNull, reason: "unmount $cycle cancellation");
      await tester.runAsync(() => cancellation!);
      expect(presenter.retentionSnapshot.disposed, isTrue);
      expect(repository.activeSubscriptions, 0, reason: "unmount $cycle");
      expect(presenter.retentionSnapshot.retainedRows, 0);
      expect(presenter.retentionSnapshot.activeSubscriptions, 0);

      await tester.runAsync(repository.dispose);
    }

    expect(
      presenters.every((presenter) => presenter.retentionSnapshot.disposed),
      isTrue,
    );
  });
}

class FakeViewerRepository implements ViewerPageRepository {
  int _activeSubscriptions = 0;
  late final StreamController<void> _controller =
      StreamController<void>.broadcast(
    onListen: () => _activeSubscriptions++,
    onCancel: () {
      _activeSubscriptions--;
    },
  );

  int get activeSubscriptions => _activeSubscriptions;

  @override
  Stream<void> invalidations() => _controller.stream;

  @override
  Future<int> count(ViewerQuery query) async => 0;

  @override
  Future<List<ViewerTagFacet>> loadTagFacets(ViewerQuery query) async =>
      const <ViewerTagFacet>[];

  @override
  Future<List<FolderItem>> loadPage(
    ViewerQuery query, {
    required int limit,
    required int offset,
  }) async =>
      const <FolderItem>[];

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

  Future<void> dispose() => _controller.close();
}
