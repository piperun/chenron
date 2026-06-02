import "package:chenron/features/folder_editor/pages/folder_editor.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get_it/get_it.dart";
import "package:signals/signals.dart";

class _MockAppDatabaseLifecycle extends AppDatabaseLifecycle {
  final AppDatabase _injected;

  _MockAppDatabaseLifecycle(this._injected);

  @override
  AppDatabase get database => _injected;

  @override
  AppDatabase get appDatabase => _injected;

  @override
  AppDatabase buildDatabase({
    required String databaseName,
    required String customPath,
    required bool setupOnInit,
  }) =>
      throw UnimplementedError("Mock does not build databases");
}

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  group("FolderItemsSection async navigation safety", () {
    late MockDatabaseHelper mockDb;
    late String folderId;

    setUp(() async {
      mockDb = MockDatabaseHelper();
      await mockDb.setup(setupOnInit: true);

      if (GetIt.I.isRegistered<Signal<AppDatabaseLifecycle>>()) {
        await GetIt.I.reset();
      }
      GetIt.I.registerSingleton<Signal<AppDatabaseLifecycle>>(
        signal(_MockAppDatabaseLifecycle(mockDb.database)),
      );

      folderId = await mockDb.createTestFolder(title: "Items Folder");
    });

    tearDown(() async {
      await mockDb.dispose();
      if (GetIt.I.isRegistered<Signal<AppDatabaseLifecycle>>()) {
        await GetIt.I.reset();
      }
    });

    Widget buildEditor() => MaterialApp(
          home: FolderEditor(folderId: folderId),
        );

    testWidgets(
        "opening the add-link sheet then disposing the editor does not throw",
        (tester) async {
      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      // Open the add-link picker sheet.
      final addLinkButton = find.widgetWithIcon(IconButton, Icons.link);
      await tester.ensureVisible(addLinkButton);
      await tester.pumpAndSettle();
      await tester.tap(addLinkButton);
      await tester.pumpAndSettle();

      expect(find.text("Create New"), findsOneWidget);

      // Dispose the entire editor while the sheet (and its onCreateNew
      // closure capturing the section's context) is still live.
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        "disposing the editor mid-create-link navigation does not throw "
        "a use-after-dispose error",
        (tester) async {
      // Large surface so CreateLinkPage lays out without cosmetic overflow
      // noise polluting takeException().
      tester.view.physicalSize = const Size(2400, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildEditor());
      await tester.pumpAndSettle();

      final addLinkButton = find.widgetWithIcon(IconButton, Icons.link);
      await tester.ensureVisible(addLinkButton);
      await tester.pumpAndSettle();
      await tester.tap(addLinkButton);
      await tester.pumpAndSettle();

      // Tap "Create New": pops the sheet and pushes CreateLinkPage while
      // _navigateToCreateLink is awaiting Navigator.push.
      await tester.tap(find.text("Create New"));
      await tester.pump();

      // Tear the whole editor (and the awaiting _navigateToCreateLink's
      // origin State) out of the tree before the push resolves. Any
      // post-await BuildContext use that isn't mounted-guarded surfaces
      // here as a "deactivated widget's ancestor" / "used after dispose".
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      final Object? error = tester.takeException();
      expect(
        error,
        isNot(isA<FlutterError>().having(
          (e) => e.message,
          "message",
          anyOf(
            contains("deactivated widget"),
            contains("after dispose"),
            contains("unmounted"),
          ),
        )),
        reason: "BuildContext used across an async gap after disposal.",
      );
    });
  });
}
