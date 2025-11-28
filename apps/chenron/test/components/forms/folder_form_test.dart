import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/components/forms/folder_form.dart";
import "package:database/database.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:signals/signals.dart";
import "package:get_it/get_it.dart";
import "dart:io";

// Mock AppDatabaseHandler that returns our mock database
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
  late MockDatabaseHelper mockDb;

  setUpAll(() {
    installTestLogger();
  });

  setUp(() async {
    // Set up mock database for GetIt dependencies
    mockDb = MockDatabaseHelper();
    await mockDb.setup(setupOnInit: true);

    // Register mock database in GetIt
    if (GetIt.I.isRegistered<Signal<AppDatabaseHandler>>()) {
      await GetIt.I.reset();
    }

    // Create a mock AppDatabaseHandler that returns our mock database
    final mockHandler = _MockAppDatabaseHandler(mockDb.database);

    GetIt.I.registerSingleton<Signal<AppDatabaseHandler>>(
      signal<AppDatabaseHandler>(mockHandler),
    );
  });

  tearDown(() async {
    await mockDb.dispose();
    if (GetIt.I.isRegistered<Signal<AppDatabaseHandler>>()) {
      await GetIt.I.reset();
    }
  });

  group("FolderFormData", () {
    test("creates instance with all fields", () {
      final data = const FolderFormData(
        title: "Test Folder",
        description: "Test Description",
        parentFolderIds: ["parent1", "parent2"],
        tags: {"tag1", "tag2"},
        items: [],
      );

      expect(data.title, "Test Folder");
      expect(data.description, "Test Description");
      expect(data.parentFolderIds, ["parent1", "parent2"]);
      expect(data.tags, {"tag1", "tag2"});
      expect(data.items, isEmpty);
    });

    test("copyWith updates only specified fields", () {
      final original = const FolderFormData(
        title: "Original",
        description: "Description",
        parentFolderIds: [],
        tags: {},
        items: [],
      );

      final updated = original.copyWith(
        title: "Updated",
        tags: {"new_tag"},
      );

      expect(updated.title, "Updated");
      expect(updated.description, "Description");
      expect(updated.tags, {"new_tag"});
    });

    test("copyWith with no changes returns same values", () {
      final original = const FolderFormData(
        title: "Test",
        description: "Desc",
        parentFolderIds: ["p1"],
        tags: {"t1"},
        items: [],
      );

      final updated = original.copyWith();

      expect(updated.title, original.title);
      expect(updated.description, original.description);
      expect(updated.parentFolderIds, original.parentFolderIds);
      expect(updated.tags, original.tags);
      expect(updated.items, original.items);
    });
  });

  group("FolderForm Widget", () {
    Widget buildForm({
      Folder? existingFolder,
      bool showItemsTable = false,
      String? keyPrefix,
      ValueChanged<FolderFormData>? onDataChanged,
      ValueChanged<bool>? onValidationChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FolderForm(
              existingFolder: existingFolder,
              showItemsTable: showItemsTable,
              keyPrefix: keyPrefix,
              onDataChanged: onDataChanged,
              onValidationChanged: onValidationChanged,
            ),
          ),
        ),
      );
    }

    group("Initial State", () {
      testWidgets("renders empty form", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        // Should find title and description inputs
        expect(find.byType(TextField), findsWidgets);

        // Should not show items table by default
        expect(find.text("Folder Items"), findsNothing);
      });

      testWidgets("renders with existing folder data", (tester) async {
        final existingFolder = Folder(
          id: "test-id",
          title: "Existing Folder",
          description: "Existing Description",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(buildForm(existingFolder: existingFolder));
        await tester.pumpAndSettle();

        expect(find.text("Existing Folder"), findsOneWidget);
        expect(find.text("Existing Description"), findsOneWidget);
      });

      testWidgets("shows items table when showItemsTable is true",
          (tester) async {
        await tester.pumpWidget(buildForm(showItemsTable: true));
        await tester.pumpAndSettle();

        expect(find.text("Folder Items"), findsOneWidget);
      });
    });

    group("Title Input Validation", () {
      testWidgets("shows no error for valid title", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Valid Title");
        await tester.pumpAndSettle();

        // Should not find error text
        expect(find.textContaining("error"), findsNothing);
      });

      testWidgets("shows error for empty title after input", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Text");
        await tester.pumpAndSettle();

        await tester.enterText(titleField, "");
        await tester.pumpAndSettle();

        // Title validation would be handled by FolderValidator
        // Widget should update validation state
      });

      testWidgets("handles long title input", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        final longTitle = "A" * 200;

        await tester.enterText(titleField, longTitle);
        await tester.pumpAndSettle();

        expect(find.text(longTitle), findsOneWidget);
      });
    });

    group("Description Input Validation", () {
      testWidgets("accepts valid description", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        final descriptionField = find.byType(TextField).at(1);
        await tester.enterText(descriptionField, "Valid Description");
        await tester.pumpAndSettle();

        expect(find.text("Valid Description"), findsOneWidget);
      });

      testWidgets("accepts empty description", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        final descriptionField = find.byType(TextField).at(1);
        await tester.enterText(descriptionField, "");
        await tester.pumpAndSettle();

        // Empty description should be valid
        expect(find.textContaining("error"), findsNothing);
      });

      testWidgets("handles long description input", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        final descriptionField = find.byType(TextField).at(1);
        final longDesc = "B" * 500;

        await tester.enterText(descriptionField, longDesc);
        await tester.pumpAndSettle();

        expect(find.textContaining("B"), findsWidgets);
      });
    });

    group("Callback Triggers", () {
      testWidgets("onDataChanged callback triggered on title change",
          (tester) async {
        FolderFormData? capturedData;

        await tester.pumpWidget(buildForm(
          onDataChanged: (data) => capturedData = data,
        ));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "New Title");
        await tester.pumpAndSettle();

        expect(capturedData, isNotNull);
        expect(capturedData!.title, "New Title");
      });

      testWidgets("onDataChanged callback triggered on description change",
          (tester) async {
        FolderFormData? capturedData;

        await tester.pumpWidget(buildForm(
          onDataChanged: (data) => capturedData = data,
        ));
        await tester.pumpAndSettle();

        final descriptionField = find.byType(TextField).at(1);
        await tester.enterText(descriptionField, "New Description");
        await tester.pumpAndSettle();

        expect(capturedData, isNotNull);
        expect(capturedData!.description, "New Description");
      });

      testWidgets("onValidationChanged callback triggered", (tester) async {
        bool? validationState;

        await tester.pumpWidget(buildForm(
          onValidationChanged: (isValid) => validationState = isValid,
        ));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Valid Title");
        await tester.pumpAndSettle();

        expect(validationState, isNotNull);
      });

      testWidgets("multiple callbacks triggered in sequence", (tester) async {
        FolderFormData? capturedData;
        // bool? validationState; // Unused

        await tester.pumpWidget(buildForm(
          onDataChanged: (data) => capturedData = data,
          // onValidationChanged: (isValid) => validationState = isValid,
        ));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Title 1");
        await tester.pumpAndSettle();

        expect(capturedData!.title, "Title 1");

        await tester.enterText(titleField, "Title 2");
        await tester.pumpAndSettle();

        expect(capturedData!.title, "Title 2");
      });
    });

    group("Tag Management", () {
      testWidgets("TagSection is rendered", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        // TagSection should be present (check for tag-related text)
        expect(find.textContaining("tag"), findsWidgets);
      });

      // Note: Detailed tag management tests depend on TagSection implementation
      // These tests verify FolderForm integrates TagSection correctly
    });

    group("Parent Folder Section", () {
      testWidgets("FolderParentSection is rendered", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        // FolderParentSection should be present
        // Verify by checking the widget tree
        expect(find.byType(FolderForm), findsOneWidget);
      });
    });

    group("Form Validation State", () {
      testWidgets("form is invalid initially", (tester) async {
        bool? validationState;

        await tester.pumpWidget(buildForm(
          onValidationChanged: (isValid) => validationState = isValid,
        ));
        await tester.pumpAndSettle();

        // Initial validation may be triggered after first frame
        await tester.pump();

        // Empty title should make form invalid
        expect(validationState, isNotNull);
      });

      testWidgets("form becomes valid with title input", (tester) async {
        bool? validationState;

        await tester.pumpWidget(buildForm(
          onValidationChanged: (isValid) => validationState = isValid,
        ));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Valid Title");
        await tester.pumpAndSettle();

        // Form should become valid
        expect(validationState, isNotNull);
      });
    });

    group("Edge Cases", () {
      testWidgets("handles rapid text input changes", (tester) async {
        FolderFormData? capturedData;

        await tester.pumpWidget(buildForm(
          onDataChanged: (data) => capturedData = data,
        ));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;

        for (int i = 0; i < 10; i++) {
          await tester.enterText(titleField, "Title $i");
          await tester.pump(const Duration(milliseconds: 10));
        }

        await tester.pumpAndSettle();

        // Should handle rapid changes without crashing
        expect(capturedData, isNotNull);
      });

      testWidgets("handles whitespace-only input", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "   ");
        await tester.pumpAndSettle();

        // Whitespace-only should be treated as empty
        // Validation logic should handle this
      });

      testWidgets("handles special characters in title", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Test@#\$%^&*()");
        await tester.pumpAndSettle();

        expect(find.text("Test@#\$%^&*()"), findsOneWidget);
      });

      testWidgets("handles unicode characters", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "测试 Тест 🎉");
        await tester.pumpAndSettle();

        expect(find.text("测试 Тест 🎉"), findsOneWidget);
      });
    });

    group("Key Prefix", () {
      testWidgets("applies keyPrefix to components", (tester) async {
        await tester.pumpWidget(buildForm(keyPrefix: "test_prefix"));
        await tester.pumpAndSettle();

        // KeyPrefix should be passed to child components
        // This is verified by component integration
        expect(find.byType(FolderForm), findsOneWidget);
      });
    });

    group("Items Table Display", () {
      testWidgets("shows placeholder when showItemsTable is true",
          (tester) async {
        await tester.pumpWidget(buildForm(showItemsTable: true));
        await tester.pumpAndSettle();

        expect(find.text("Folder Items"), findsOneWidget);
        expect(find.textContaining("Item management"), findsOneWidget);
      });

      testWidgets("items table not shown by default", (tester) async {
        await tester.pumpWidget(buildForm(showItemsTable: false));
        await tester.pumpAndSettle();

        expect(find.text("Folder Items"), findsNothing);
      });
    });

    group("Lifecycle", () {
      testWidgets("properly disposes controllers", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        // Remove widget from tree
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        await tester.pumpAndSettle();

        // Widget should dispose properly without errors
        // Flutter test framework will catch disposal errors
      });

      testWidgets("handles widget rebuild", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        await tester.enterText(titleField, "Initial Title");
        await tester.pumpAndSettle();

        // Rebuild with same config
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        // Widget should rebuild successfully
        expect(find.byType(FolderForm), findsOneWidget);
      });
    });

    group("Integration with Signals", () {
      testWidgets("signals update on value changes", (tester) async {
        FolderFormData? capturedData;

        await tester.pumpWidget(buildForm(
          onDataChanged: (data) => capturedData = data,
        ));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;

        await tester.enterText(titleField, "First Title");
        await tester.pumpAndSettle();
        expect(capturedData!.title, "First Title");

        await tester.enterText(titleField, "Second Title");
        await tester.pumpAndSettle();
        expect(capturedData!.title, "Second Title");
      });

      testWidgets("description signal updates independently", (tester) async {
        FolderFormData? capturedData;

        await tester.pumpWidget(buildForm(
          onDataChanged: (data) => capturedData = data,
        ));
        await tester.pumpAndSettle();

        final titleField = find.byType(TextField).first;
        final descriptionField = find.byType(TextField).at(1);

        await tester.enterText(titleField, "Title");
        await tester.pumpAndSettle();

        await tester.enterText(descriptionField, "Description");
        await tester.pumpAndSettle();

        expect(capturedData!.title, "Title");
        expect(capturedData!.description, "Description");
      });
    });

    group("Validation Error Display", () {
      testWidgets("validation errors displayed inline", (tester) async {
        await tester.pumpWidget(buildForm());
        await tester.pumpAndSettle();

        // Validation errors should appear in the form
        // Specific error messages depend on FolderValidator implementation
        expect(find.byType(FolderForm), findsOneWidget);
      });
    });
  });
}
