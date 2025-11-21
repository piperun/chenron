import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/pages/viewer.dart";
import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/locator.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:signals/signals_flutter.dart";

import "viewer_test.mocks.dart";

@GenerateMocks([ConfigController])
void main() {
  late MockConfigController mockConfigController;
  late FakeViewerModel fakeViewerModel;
  late ViewerPresenter presenter;

  setUp(() async {
    mockConfigController = MockConfigController();
    fakeViewerModel = FakeViewerModel();

    // Reset locator
    await locator.reset();

    // Register ConfigController
    locator.registerSingleton<ConfigController>(mockConfigController);

    // Setup default stubs
    when(mockConfigController.itemClickAction).thenReturn(signal(0));

    // Initialize presenter with fake dependencies
    presenter = ViewerPresenter(model: fakeViewerModel);
    viewerViewModelSignal.value = presenter;
  });

  testWidgets("Viewer widget builds successfully", (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Viewer(),
      ),
    );

    // Just verify the widget built without throwing
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
