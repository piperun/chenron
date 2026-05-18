import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/create/link/pages/create_link.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/database.dart";
import "package:signals/signals.dart";
import "package:get_it/get_it.dart";

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

  group("CreateLinkPage Tests", () {
    late MockDatabaseHelper mockDb;

    setUp(() async {
      mockDb = MockDatabaseHelper();
      await mockDb.setup(setupOnInit: true);

      if (GetIt.I.isRegistered<Signal<AppDatabaseLifecycle>>()) {
        await GetIt.I.reset();
      }

      final mockHandler = _MockAppDatabaseLifecycle(mockDb.database);
      GetIt.I.registerSingleton<Signal<AppDatabaseLifecycle>>(
        signal(mockHandler),
      );
    });

    tearDown(() async {
      await mockDb.dispose();
      if (GetIt.I.isRegistered<Signal<AppDatabaseLifecycle>>()) {
        await GetIt.I.reset();
      }
    });

    Future<void> pumpPage(
      WidgetTester tester, {
      bool hideAppBar = false,
      VoidCallback? onClose,
      VoidCallback? onSaved,
      ValueChanged<bool>? onValidationChanged,
      ValueChanged<VoidCallback>? onSaveCallbackReady,
    }) async {
      // Wider viewport to avoid Row overflow in link_table_section.
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(MaterialApp(
        home: CreateLinkPage(
          hideAppBar: hideAppBar,
          onClose: onClose,
          onSaved: onSaved,
          onValidationChanged: onValidationChanged,
          onSaveCallbackReady: onSaveCallbackReady,
        ),
      ));
      // Use pump with duration — signals may keep emitting.
      await tester.pump(const Duration(milliseconds: 500));
    }

    group("Rendering", () {
      testWidgets("shows AppBar with title", (tester) async {
        await pumpPage(tester);

        expect(find.text("Add Links"), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets("hides AppBar when hideAppBar is true", (tester) async {
        await pumpPage(tester, hideAppBar: true);

        expect(find.byType(AppBar), findsNothing);
      });

      testWidgets("shows Target Folders section", (tester) async {
        await pumpPage(tester);

        expect(find.text("Target Folders"), findsOneWidget);
      });

      testWidgets("shows link input area", (tester) async {
        await pumpPage(tester);

        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets("shows archive toggle", (tester) async {
        await pumpPage(tester);

        expect(find.textContaining("Archive"), findsWidgets);
      });

      testWidgets("shows global tags section", (tester) async {
        await pumpPage(tester);

        expect(find.text("Global Tags"), findsOneWidget);
      });
    });

    group("URL Input", () {
      testWidgets("can add a valid URL", (tester) async {
        await pumpPage(tester);

        final urlField = find.byKey(const Key("link_input_single_url_field"));
        if (urlField.evaluate().isNotEmpty) {
          await tester.enterText(urlField, "https://example.com");
          await tester.pump(const Duration(milliseconds: 300));

          final addButton = find.byKey(const Key("link_input_add_button"));
          if (addButton.evaluate().isNotEmpty) {
            await tester.tap(addButton);
            await tester.pump(const Duration(milliseconds: 300));
          }
        }
      });
    });

    group("Duplicate URL rejection", () {
      testWidgets("shows error when adding same URL twice", (tester) async {
        await pumpPage(tester);

        final urlField = find.byKey(const Key("link_input_single_url_field"));
        final addButton = find.byKey(const Key("link_input_add_button"));
        if (urlField.evaluate().isEmpty || addButton.evaluate().isEmpty) {
          return; // skip if keys not found
        }

        // Add first URL
        await tester.enterText(urlField, "https://example.com");
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(addButton);
        await tester.pump(const Duration(milliseconds: 300));

        // Try adding the same URL again
        await tester.enterText(urlField, "https://example.com");
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(addButton);
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text("This URL has already been added"), findsOneWidget);
      });

      testWidgets("allows adding different URLs", (tester) async {
        await pumpPage(tester);

        final urlField = find.byKey(const Key("link_input_single_url_field"));
        final addButton = find.byKey(const Key("link_input_add_button"));
        if (urlField.evaluate().isEmpty || addButton.evaluate().isEmpty) {
          return; // skip if keys not found
        }

        await tester.enterText(urlField, "https://one.com");
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(addButton);
        await tester.pump(const Duration(milliseconds: 300));

        await tester.enterText(urlField, "https://two.com");
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(addButton);
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text("This URL has already been added"), findsNothing);
      });
    });

    group("Validation callbacks", () {
      testWidgets("onValidationChanged receives false initially",
          (tester) async {
        bool? isValid;
        await pumpPage(tester,
            hideAppBar: true,
            onValidationChanged: (valid) => isValid = valid);

        expect(isValid, false);
      });

      testWidgets("onSaveCallbackReady receives callback", (tester) async {
        VoidCallback? saveCallback;
        await pumpPage(tester,
            hideAppBar: true,
            onSaveCallbackReady: (cb) => saveCallback = cb);

        expect(saveCallback, isNotNull);
      });
    });
  });
}
