import "dart:async";

import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/locator.dart";
import "package:database/models/db_result.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";

import "viewer_test.mocks.dart";

@GenerateMocks([ConfigService, DataSettingsService, ThemeNotifier])
void main() {
  late FakeViewerModel fakeViewerModel;

  setUp(() async {
    fakeViewerModel = FakeViewerModel();

    await locator.reset();

    locator.registerSingleton<SettingsCoordinator>(SettingsCoordinator(
      configService: MockConfigService(),
      dataService: MockDataSettingsService(),
      themeApplier: MockThemeNotifier(),
      optionsStore: ThemeOptionsStore(),
    ));
  });

  tearDown(() async {
    await fakeViewerModel.dispose();
  });

  testWidgets("Viewer widget builds successfully", (WidgetTester tester) async {
    final presenter = ViewerPresenter(model: fakeViewerModel);

    await tester.pumpWidget(
      MaterialApp(
        home: Viewer(presenterFactory: () => presenter),
      ),
    );

    expect(find.byType(Viewer), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
  });

  testWidgets("Viewer disposes each page-owned presenter across mounts",
      (WidgetTester tester) async {
    final presenters = <ViewerPresenter>[];

    for (var cycle = 0; cycle < 10; cycle++) {
      final model = FakeViewerModel();
      final presenter = ViewerPresenter(model: model);
      presenters.add(presenter);

      await tester.pumpWidget(MaterialApp(
        home: Viewer(presenterFactory: () => presenter),
      ));
      await tester.pump();
      expect(model.activeSubscriptions, 1, reason: "mount $cycle");

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(model.activeSubscriptions, 0, reason: "unmount $cycle");
      expect(presenter.retentionSnapshot.retainedRows, 0);
      expect(presenter.retentionSnapshot.activeSubscriptions, 0);

      await model.dispose();
    }

    expect(
      presenters.every((presenter) => presenter.retentionSnapshot.disposed),
      isTrue,
    );
  });
}

class FakeViewerModel extends Fake implements ViewerModel {
  final StreamController<List<ViewerItem>> _controller =
      StreamController<List<ViewerItem>>.broadcast();
  int _activeSubscriptions = 0;

  int get activeSubscriptions => _activeSubscriptions;

  @override
  Stream<List<ViewerItem>> watchAllItems() {
    return _controller.stream
        .transform(
          StreamTransformer<List<ViewerItem>, List<ViewerItem>>.fromHandlers(
            handleData: (data, sink) => sink.add(data),
          ),
        )
        .trackSubscriptions(
            () => _activeSubscriptions++, () => _activeSubscriptions--);
  }

  @override
  Future<bool> removeFolder(String? folder) async => true;

  @override
  Future<bool> removeLink(String? linkId) async => true;

  @override
  Stream<List<FolderResult>> watchAllFolders() {
    return Stream.value([]);
  }

  Future<void> dispose() => _controller.close();
}

extension _TrackSubscriptions<T> on Stream<T> {
  Stream<T> trackSubscriptions(
    void Function() onListen,
    void Function() onCancel,
  ) {
    late StreamController<T> wrapper;
    StreamSubscription<T>? subscription;
    wrapper = StreamController<T>(
      onListen: () {
        onListen();
        subscription = listen(
          wrapper.add,
          onError: wrapper.addError,
          onDone: wrapper.close,
        );
      },
      onCancel: () {
        onCancel();
        return subscription?.cancel();
      },
    );
    return wrapper.stream;
  }
}
