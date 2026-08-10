import "dart:async";
import "dart:convert";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/locator.dart";
import "package:database/database.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";

import "../test/features/viewer/viewer_test.mocks.dart";
import "support/viewer_memory_probe.dart";

class _ProfileViewerModel extends ViewerModel {
  final StreamController<List<ViewerItem>> controller =
      StreamController<List<ViewerItem>>.broadcast();

  @override
  Stream<List<ViewerItem>> watchAllItems() => controller.stream;
}

ViewerItem _profileItem(int index) {
  final id = index.toString().padLeft(6, "0");
  return ViewerItem(
    id: "item-$id",
    title: "Item $id",
    description: "",
    type: FolderItemType.link,
    tags: const [],
    createdAt: DateTime(2020, 1, 1),
    url: "https://item-$id.example/path",
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

  late _ProfileViewerModel model;
  late ViewerPresenter presenter;

  setUp(() async {
    await locator.reset();
    locator.registerSingleton<SettingsCoordinator>(SettingsCoordinator(
      configService: MockConfigService(),
      dataService: MockDataSettingsService(),
      themeApplier: MockThemeNotifier(),
      optionsStore: ThemeOptionsStore(),
    ));
    model = _ProfileViewerModel();
    presenter = ViewerPresenter(model: model);
  });

  tearDown(() async {
    presenter.dispose();
    await model.controller.close();
  });

  testWidgets("captures cold, open, and leave viewer memory", (tester) async {
    const defaultItemCount = 100000;
    final itemCount = int.tryParse(
          const String.fromEnvironment("CHENRON_MEMORY_ITEM_COUNT"),
        ) ??
        defaultItemCount;

    final cold = captureViewerMemory("cold", presenter.retentionSnapshot);
    _printSnapshot(cold);
    expect(cold.imageCacheBytes, 0);

    await presenter.init();
    model.controller.add(List.generate(itemCount, _profileItem));
    await tester.pump();

    final open = captureViewerMemory("open", presenter.retentionSnapshot);
    _printSnapshot(open);
    expect(open.retainedViewerRows, itemCount);
    expect(open.viewerSubscriptions, 1);
    expect(open.imageCacheBytes, 0);

    presenter.dispose();
    await tester.pump();

    final leave = captureViewerMemory("leave", presenter.retentionSnapshot);
    _printSnapshot(leave);
    expect(leave.retainedViewerRows, 0);
    expect(leave.viewerSubscriptions, 0);
    expect(leave.imageCacheBytes, 0);
  });
}
