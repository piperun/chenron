import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/features/theme/state/theme_options_store.dart";
import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/mvc/viewer_presenter.dart";
import "package:chenron/features/viewer/ui/paged_viewer_display.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/item_display/widgets/viewer_item/viewer_item.dart";
import "package:database/database.dart";
import "package:drift/native.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

import "viewer_test.mocks.dart";

void main() {
  testWidgets(
      "real viewer filters by tag name through the modal and hash query",
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await locator.reset();
    locator.registerSingleton<SettingsCoordinator>(SettingsCoordinator(
      configService: MockConfigService(),
      dataService: MockDataSettingsService(),
      themeApplier: MockThemeNotifier(),
      optionsStore: ThemeOptionsStore(),
    ));
    final database = AppDatabase(queryExecutor: NativeDatabase.memory());
    const taggedId = "folder-0000000000000000000000001";
    const untaggedId = "folder-0000000000000000000000002";
    const tagId = "tag-opaque-00000000000000000001";
    const tagName = "topic";
    await database.into(database.folders).insert(
          FoldersCompanion.insert(
            id: taggedId,
            title: "Tagged folder",
            description: "Generic tagged folder",
          ),
        );
    await database.into(database.folders).insert(
          FoldersCompanion.insert(
            id: untaggedId,
            title: "Untagged folder",
            description: "Generic untagged folder",
          ),
        );
    await database.into(database.tags).insert(
          TagsCompanion.insert(id: tagId, name: tagName),
        );
    await database.into(database.metadataRecords).insert(
          MetadataRecordsCompanion.insert(
            id: "metadata-000000000000000000001",
            typeId: MetadataTypeEnum.tag,
            itemId: taggedId,
            metadataId: tagId,
          ),
        );
    final presenter = ViewerPresenter(
      model: ViewerModel(database: database),
    );
    addTearDown(() async {
      presenter.dispose();
      await presenter.pageSource.invalidationCancellation;
      await database.close();
      await locator.reset();
    });
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(1600, 900));
    await presenter.init();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagedViewerDisplay(
            presenter: presenter,
            showSearch: false,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(presenter.pageSource.totalCount.value, 2);

    await tester.tap(find.text("Tags"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Available Tags"));
    await tester.pumpAndSettle();
    expect(find.text(tagName), findsOneWidget);
    await tester.tap(find.byTooltip("Include"));
    await tester.tap(find.text("Apply Filters"));
    await tester.pumpAndSettle();

    expect(presenter.query.value.includedTags, const <String>{tagName});
    expect(presenter.pageSource.totalCount.value, 1);
    await _expectOnlyTaggedRow(tester, presenter, taggedId);

    presenter.tagFilterState.clear();
    presenter.tagFilterState.addExcluded(tagName);
    await tester.pumpAndSettle();
    expect(presenter.pageSource.totalCount.value, 1);
    presenter.searchFilter.controller.value = "#TOPIC";
    await tester.pumpAndSettle();

    expect(presenter.pageSource.totalCount.value, 1);
    await _expectOnlyTaggedRow(tester, presenter, taggedId);
    expect(presenter.query.value.includedTags, const <String>{tagName});
    expect(presenter.query.value.excludedTags, isEmpty);
  });
}

Future<void> _expectOnlyTaggedRow(
  WidgetTester tester,
  ViewerPresenter presenter,
  String taggedId,
) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    final item = presenter.pageSource.itemAt(0);
    if (item != null) {
      expect(item.id, taggedId);
      expect(find.byType(ViewerItem), findsOneWidget);
      return;
    }
    await tester.pump();
  }
  fail("tagged row did not materialize");
}
