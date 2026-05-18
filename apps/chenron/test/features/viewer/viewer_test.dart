import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/settings/service/config_service.dart";
import "package:chenron/features/settings/service/data_settings_service.dart";
import "package:chenron/features/theme/state/theme_notifier.dart";
import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/viewer/state/viewer_state.dart";
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
  late ViewerPresenter presenter;

  setUp(() async {
    fakeViewerModel = FakeViewerModel();

    await locator.reset();

    locator.registerSingleton<SettingsCoordinator>(SettingsCoordinator(
      configService: MockConfigService(),
      dataService: MockDataSettingsService(),
      themeApplier: MockThemeNotifier(),
    ));

    presenter = ViewerPresenter(model: fakeViewerModel);
    viewerViewModelSignal.value = presenter;
  });

  testWidgets("Viewer widget builds successfully", (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Viewer(),
      ),
    );

    expect(find.byType(Viewer), findsOneWidget);
  });
}

class FakeViewerModel extends Fake implements ViewerModel {
  @override
  Stream<List<ViewerItem>> watchAllItems() {
    return Stream.value([]);
  }

  @override
  Future<bool> removeFolder(String? folder) async => true;

  @override
  Future<bool> removeLink(String? linkId) async => true;

  @override
  Stream<List<FolderResult>> watchAllFolders() {
    return Stream.value([]);
  }
}
