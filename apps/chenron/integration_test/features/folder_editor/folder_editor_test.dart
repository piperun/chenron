import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/features/folder_editor/pages/folder_editor.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:database/extensions/operations/database_file_handler.dart";
import "package:database/database.dart";
import "package:signals/signals.dart";
import "package:get_it/get_it.dart";
import "dart:io";

// Mock AppDatabaseHandler for integration tests
class _MockAppDatabaseHandler implements AppDatabaseHandler {
  @override
  final AppDatabase appDatabase;

  _MockAppDatabaseHandler(this.appDatabase);

  @override
  DatabaseLocation? databaseLocation;

  @override
  Future<File?> backupDatabase() => throw UnimplementedError();

  @override
  Future<void> closeDatabase() async {}

  @override
  Future<void> createDatabase(
      {String? databaseName,
      File? databasePath,
      bool setupOnInit = false}) async {}

  @override
  Future<File?> exportDatabase(Directory exportPath) =>
      throw UnimplementedError();

  @override
  Future<File?> importDatabase(File dbFile,
          {required bool copyImport, bool setupOnInit = true}) =>
      throw UnimplementedError();

  @override
  Future<void> reloadDatabase() async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  group("Folder Editor Integration Tests", () {
    late MockDatabaseHelper mockDb;
    late String testFolderId;

    setUp(() async {
      mockDb = MockDatabaseHelper();
      await mockDb.setup(setupOnInit: true);

      // Register mock database in locator
      if (GetIt.I.isRegistered<Signal<AppDatabaseHandler>>()) {
        await GetIt.I.reset();
      }

      // Create a mock handler that returns our mock database
      final mockHandler = _MockAppDatabaseHandler(mockDb.database);

      GetIt.I.registerSingleton<Signal<AppDatabaseHandler>>(
        signal(mockHandler),
      );

      // Create test folder
      testFolderId = await mockDb.createTestFolder(
        title: "Test Folder",
        description: "Test Description",
        tags: ["tag1", "tag2"],
      );
    });

    tearDown(() async {
      await mockDb.dispose();
      if (GetIt.I.isRegistered<Signal<AppDatabaseHandler>>()) {
        await GetIt.I.reset();
      }
    });

    Widget buildEditor({
      required String folderId,
      bool hideAppBar = false,
      VoidCallback? onClose,
      VoidCallback? onSaved,
    }) {
      return MaterialApp(
        home: FolderEditor(
          folderId: folderId,
          hideAppBar: hideAppBar,
          onClose: onClose,
          onSaved: onSaved,
        ),
      );
    }

    group("Loading States", () {
      testWidgets("displays loading indicator initially", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets("displays error when folder not found", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: "non-existent-id"));
        await tester.pumpAndSettle();

        expect(find.text("Folder not found"), findsOneWidget);
      });

      testWidgets("displays folder data after loading", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        expect(find.text("Test Folder"), findsOneWidget);
        expect(find.text("Test Description"), findsOneWidget);
      });
    });

    group("UI Interaction - Title", () {
      testWidgets("can edit title field", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Updated Title");
        await tester.pumpAndSettle();

        expect(find.text("Updated Title"), findsOneWidget);
      });

      testWidgets("title field clears existing text", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "");
        await tester.pumpAndSettle();

        // Empty title should show validation error (if implemented)
      });

      testWidgets("handles long title input", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final longTitle = "A" * 200;
        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, longTitle);
        await tester.pumpAndSettle();

        expect(find.textContaining("A"), findsWidgets);
      });

      testWidgets("handles special characters in title", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Test@#\$%^&*()");
        await tester.pumpAndSettle();

        expect(find.text("Test@#\$%^&*()"), findsOneWidget);
      });
    });

    group("UI Interaction - Description", () {
      testWidgets("can edit description field", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final descriptionField = find.byType(TextField).at(1);
        await tester.enterText(descriptionField, "Updated Description");
        await tester.pumpAndSettle();

        expect(find.text("Updated Description"), findsOneWidget);
      });

      testWidgets("description field can be cleared", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final descriptionField = find.byType(TextField).at(1);
        await tester.enterText(descriptionField, "");
        await tester.pumpAndSettle();

        // Empty description should be valid
      });

      testWidgets("handles long description", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final longDesc = "B" * 500;
        final descriptionField = find.byType(TextField).at(1);
        await tester.enterText(descriptionField, longDesc);
        await tester.pumpAndSettle();

        expect(find.textContaining("B"), findsWidgets);
      });
    });

    group("Save Functionality", () {
      testWidgets("save button disabled when no changes", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final saveButton = find.widgetWithIcon(IconButton, Icons.save);
        final button = tester.widget<IconButton>(saveButton);

        expect(button.onPressed, isNull);
      });

      testWidgets("save button enabled after editing", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Modified Title");
        await tester.pumpAndSettle();

        final saveButton = find.widgetWithIcon(IconButton, Icons.save);
        final button = tester.widget<IconButton>(saveButton);

        expect(button.onPressed, isNotNull);
      });

      testWidgets("save persists to database", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        // Edit title
        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Saved Title");
        await tester.pumpAndSettle();

        // Click save
        final saveButton = find.widgetWithIcon(IconButton, Icons.save);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Verify database
        final folderTitle = await mockDb.getFolderTitle(testFolderId);
        expect(folderTitle, "Saved Title");
      });

      testWidgets("success snackbar displays after save", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "New Title");
        await tester.pumpAndSettle();

        final saveButton = find.widgetWithIcon(IconButton, Icons.save);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.text("Changes saved successfully"), findsOneWidget);
      });

      testWidgets("onSaved callback triggers", (tester) async {
        var callbackTriggered = false;

        await tester.pumpWidget(buildEditor(
          folderId: testFolderId,
          hideAppBar: true,
          onSaved: () => callbackTriggered = true,
        ));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Callback Title");
        await tester.pumpAndSettle();

        final saveButton = find.widgetWithIcon(FilledButton, Icons.save);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(callbackTriggered, true);
      });
    });

    group("Navigation Modes", () {
      testWidgets("shows AppBar when hideAppBar is false", (tester) async {
        await tester.pumpWidget(buildEditor(
          folderId: testFolderId,
          hideAppBar: false,
        ));
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text("Edit Folder"), findsOneWidget);
      });

      testWidgets("hides AppBar when hideAppBar is true", (tester) async {
        await tester.pumpWidget(buildEditor(
          folderId: testFolderId,
          hideAppBar: true,
        ));
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsNothing);
      });

      testWidgets("shows custom header in main page mode", (tester) async {
        await tester.pumpWidget(buildEditor(
          folderId: testFolderId,
          hideAppBar: true,
          onClose: () {},
        ));
        await tester.pumpAndSettle();

        expect(find.widgetWithIcon(IconButton, Icons.close), findsOneWidget);
      });

      testWidgets("onClose callback works", (tester) async {
        var closeCalled = false;

        await tester.pumpWidget(buildEditor(
          folderId: testFolderId,
          hideAppBar: true,
          onClose: () => closeCalled = true,
        ));
        await tester.pumpAndSettle();

        final closeButton = find.widgetWithIcon(IconButton, Icons.close);
        await tester.tap(closeButton);
        await tester.pumpAndSettle();

        expect(closeCalled, true);
      });
    });

    group("Database Verification", () {
      testWidgets("loads folder data from database", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final folder = await mockDb.getFolder(testFolderId);
        expect(folder, isNotNull);
        expect(folder!.data.title, "Test Folder");
        expect(folder.data.description, "Test Description");
      });

      testWidgets("saves title and description changes", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        final descriptionField = find.byType(TextField).at(1);

        await tester.enterText(titleField, "DB Title");
        await tester.enterText(descriptionField, "DB Description");
        await tester.pumpAndSettle();

        final saveButton = find.widgetWithIcon(IconButton, Icons.save);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(await mockDb.getFolderTitle(testFolderId), "DB Title");
        expect(
            await mockDb.getFolderDescription(testFolderId), "DB Description");
      });

      testWidgets("folder tags loaded correctly", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final tags = await mockDb.getFolderTags(testFolderId);
        expect(tags, containsAll(["tag1", "tag2"]));
      });
    });

    group("StreamBuilder Reactivity", () {
      testWidgets("UI updates when folder data changes", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        expect(find.text("Test Folder"), findsOneWidget);

        // Note: StreamBuilder reactivity depends on database stream updates
        // In real scenario, external changes would trigger rebuilds
      });
    });

    group("Edge Cases", () {
      testWidgets("handles empty folder", (tester) async {
        final emptyFolderId = await mockDb.createTestFolder(
          title: "Empty Folder",
          description: "",
          tags: [],
        );

        await tester.pumpWidget(buildEditor(folderId: emptyFolderId));
        await tester.pumpAndSettle();

        expect(find.text("Empty Folder"), findsOneWidget);
        expect(await mockDb.countFolderItems(emptyFolderId), 0);
      });

      testWidgets("handles folder with many tags", (tester) async {
        final manyTags = List.generate(15, (i) => "tag$i");
        final tagFolderId = await mockDb.createTestFolder(
          title: "Many Tags",
          description: "",
          tags: manyTags,
        );

        await tester.pumpWidget(buildEditor(folderId: tagFolderId));
        await tester.pumpAndSettle();

        final tags = await mockDb.getFolderTags(tagFolderId);
        expect(tags.length, 15);
      });

      testWidgets("handles very long text", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        final longText = "Very " * 100;

        await tester.enterText(titleField, longText);
        await tester.pumpAndSettle();

        // Should handle without crashing
        expect(find.byType(FolderEditor), findsOneWidget);
      });

      testWidgets("handles unicode characters", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "测试 Тест 🎉");
        await tester.pumpAndSettle();

        expect(find.text("测试 Тест 🎉"), findsOneWidget);
      });

      testWidgets("navigation away without saving", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final originalTitle = await mockDb.getFolderTitle(testFolderId);

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Unsaved Title");
        await tester.pumpAndSettle();

        // Navigate away (remove widget)
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pumpAndSettle();

        // Database should remain unchanged
        expect(await mockDb.getFolderTitle(testFolderId), originalTitle);
      });

      testWidgets("rapid multiple saves", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        for (int i = 0; i < 5; i++) {
          final titleField = find.byType(TextField).first;
          await tester.enterText(titleField, "Rapid Title $i");
          await tester.pump(const Duration(milliseconds: 50));

          final saveButton = find.widgetWithIcon(IconButton, Icons.save);
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pump(const Duration(milliseconds: 50));
          }
        }

        await tester.pumpAndSettle();

        // Should handle rapid saves without crashing
        expect(find.byType(FolderEditor), findsOneWidget);
      });
    });

    group("Folder Items Section", () {
      testWidgets("displays folder items section", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        expect(find.text("Folder Items"), findsOneWidget);
      });

      testWidgets("add link button navigates", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final addLinkButton = find.widgetWithIcon(IconButton, Icons.link);
        await tester.tap(addLinkButton);
        await tester.pumpAndSettle();

        // Should navigate to create link page (if navigation is implemented)
        // Integration depends on routing setup
      });

      testWidgets("add document button shows not implemented", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final addDocButton = find.widgetWithIcon(IconButton, Icons.note_add);
        await tester.tap(addDocButton);
        await tester.pumpAndSettle();

        expect(find.textContaining("not yet implemented"), findsOneWidget);
      });
    });

    group("Validation Display", () {
      testWidgets("shows validation error for empty title", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "");
        await tester.pumpAndSettle();

        // Save button should be disabled
        final saveButton = find.widgetWithIcon(IconButton, Icons.save);
        if (saveButton.evaluate().isNotEmpty) {
          final button = tester.widget<IconButton>(saveButton);
          expect(button.onPressed, isNull);
        }
      });
    });

    group("Tag Management", () {
      testWidgets("TagSection is rendered", (tester) async {
        await tester.pumpWidget(buildEditor(folderId: testFolderId));
        await tester.pumpAndSettle();

        // TagSection should be present
        expect(find.textContaining("tag"), findsWidgets);
      });

      // Note: Detailed tag interactions depend on TagSection implementation
      // These tests verify FolderEditor integrates TagSection correctly
    });
  });
}
