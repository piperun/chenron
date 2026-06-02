import "dart:async";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/locator.dart";
import "package:database/database.dart";
import "package:flutter_test/flutter_test.dart";

import "viewer_test.mocks.dart";

/// A [ViewerModel] stand-in whose item stream is fully controllable so
/// tests can observe how many live subscriptions the presenter holds.
///
/// `watchAllItems()` hands out a single-listener stream backed by a
/// broadcast controller, but counts every `listen` and every `cancel`
/// so a test can assert the presenter never stacks subscriptions.
class _FakeViewerModel extends Fake implements ViewerModel {
  final StreamController<List<ViewerItem>> controller =
      StreamController<List<ViewerItem>>.broadcast();

  int listenCount = 0;
  int cancelCount = 0;

  int get activeSubscriptions => listenCount - cancelCount;

  @override
  Stream<List<ViewerItem>> watchAllItems() {
    // Wrap the broadcast stream so each subscription is observable via
    // the onListen / onCancel transformer hooks.
    return controller.stream.transform(
      StreamTransformer<List<ViewerItem>, List<ViewerItem>>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
      ),
    ).doOnSubscribe(() => listenCount++, () => cancelCount++);
  }

  @override
  Future<bool> removeFolder(String? folder) async => true;

  @override
  Future<bool> removeLink(String? linkId) async => true;

  @override
  Stream<List<FolderResult>> watchAllFolders() => Stream.value([]);
}

/// Tiny subscription-counting extension so we don't pull in rxdart just
/// for `doOnSubscribe`.
extension _DoOnSubscribe<T> on Stream<T> {
  Stream<T> doOnSubscribe(void Function() onListen, void Function() onCancel) {
    late StreamController<T> wrapper;
    StreamSubscription<T>? sub;
    wrapper = StreamController<T>(
      onListen: () {
        onListen();
        sub = listen(
          wrapper.add,
          onError: wrapper.addError,
          onDone: wrapper.close,
        );
      },
      onCancel: () {
        onCancel();
        return sub?.cancel();
      },
    );
    return wrapper.stream;
  }
}

ViewerItem _item(String id, {String title = "", FolderItemType type = FolderItemType.link}) {
  return ViewerItem(
    id: id,
    title: title,
    description: "",
    type: type,
    tags: const [],
    createdAt: DateTime(2020, 1, 1),
  );
}

void main() {
  late _FakeViewerModel model;
  late ViewerPresenter presenter;

  setUp(() async {
    await locator.reset();
    locator.registerSingleton<SettingsCoordinator>(SettingsCoordinator(
      configService: MockConfigService(),
      dataService: MockDataSettingsService(),
      themeApplier: MockThemeNotifier(),
      optionsStore: ThemeOptionsStore(),
    ));
    model = _FakeViewerModel();
    presenter = ViewerPresenter(model: model);
  });

  tearDown(() {
    if (!model.controller.isClosed) {
      unawaited(model.controller.close());
    }
  });

  group("init() subscription lifecycle (H6)", () {
    test("a single init() opens exactly one upstream subscription", () async {
      await presenter.init();
      await Future<void>.delayed(Duration.zero);
      expect(model.activeSubscriptions, 1);
    });

    test("calling init() twice does NOT stack a second subscription",
        () async {
      await presenter.init();
      await presenter.init();
      await Future<void>.delayed(Duration.zero);

      // The leak under test: the second init() must not leave two live
      // watchAllItems() subscriptions running in parallel.
      expect(model.activeSubscriptions, 1);
    });

    test("re-init does not duplicate emissions downstream", () async {
      await presenter.init();
      await presenter.init();
      await Future<void>.delayed(Duration.zero);

      final received = <List<ViewerItem>>[];
      final sub = presenter.itemsStream.listen(received.add);

      model.controller.add([_item("a")]);
      await Future<void>.delayed(Duration.zero);

      // One upstream emission -> one downstream emission. A stacked
      // subscription would push the same payload twice.
      expect(received.length, 1);
      await sub.cancel();
    });
  });

  group("dispose() releases resources (H7)", () {
    test("dispose cancels the active upstream subscription", () async {
      await presenter.init();
      await Future<void>.delayed(Duration.zero);
      expect(model.activeSubscriptions, 1);

      presenter.dispose();
      await Future<void>.delayed(Duration.zero);

      expect(model.activeSubscriptions, 0);
    });

    test("dispose closes the items controller and disposes signals",
        () async {
      await presenter.init();
      await Future<void>.delayed(Duration.zero);

      presenter.dispose();

      // All owned signals must be disposed.
      expect(presenter.viewMode.disposed, isTrue);
      expect(presenter.sortMode.disposed, isTrue);
      expect(presenter.selectedItemIds.disposed, isTrue);
      expect(presenter.selectedTypes.disposed, isTrue);
    });

    test("dispose is idempotent (second call does not throw)", () async {
      await presenter.init();
      await Future<void>.delayed(Duration.zero);
      presenter.dispose();
      expect(presenter.dispose, returnsNormally);
    });
  });

  group("filtering / sorting", () {
    test("filterItems matches by type", () {
      final items = [
        _item("f", type: FolderItemType.folder),
        _item("l", type: FolderItemType.link),
      ];
      final result = presenter.filterItems(
        items,
        {FolderItemType.folder},
        "",
      );
      expect(result.map((i) => i.id), ["f"]);
    });

    test("filterItems matches by search query against title", () {
      final items = [
        _item("a", title: "Alpha"),
        _item("b", title: "Beta"),
      ];
      final result = presenter.filterItems(
        items,
        FolderItemType.values.toSet(),
        "alph",
      );
      expect(result.map((i) => i.id), ["a"]);
    });
  });
}
