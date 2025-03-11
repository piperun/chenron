import "package:chenron/features/folder/create/ui/steps/info_step.dart";
import "package:chenron/utils/test_lib/test_text.dart";
import "package:easy_sidemenu/easy_sidemenu.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/main.dart" as app;
import "package:chenron/features/folder/create/ui/forms/folder_form.dart";
import "package:pluto_grid/pluto_grid.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("CreateFolderStepper Integration Tests", () {
    testWidgets("Ensure we can navigate the Side Menu",
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      // Verify Side Menu is visible
      expect(find.byType(SideMenu), findsOneWidget);
      // Verify Side Menu items are clickable
      // Folder
      expect(
          find.descendant(
              of: find.byType(SideMenu), matching: find.text("Folder")),
          findsOneWidget);
      await tester.tap(find.descendant(
          of: find.byType(SideMenu), matching: find.text("Folder")));
      await tester.pumpAndSettle();
      // Child item 1: Create
      expect(
          find.descendant(
              of: find.byType(SideMenu), matching: find.text("Create")),
          findsOneWidget);
      await tester.tap(find.descendant(
          of: find.byType(SideMenu), matching: find.text("Create")));
      await tester.pumpAndSettle();
      // Child item 2: Viewer
      expect(
          find.descendant(
              of: find.byType(SideMenu), matching: find.text("Viewer")),
          findsOneWidget);
      await tester.tap(find.descendant(
          of: find.byType(SideMenu), matching: find.text("Viewer")));
      await tester.pumpAndSettle();
      // Dashboard
      expect(
          find.descendant(
              of: find.byType(SideMenu), matching: find.text("Dashboard")),
          findsOneWidget);
      await tester.tap(find.descendant(
          of: find.byType(SideMenu), matching: find.text("Dashboard")));
      await tester.pumpAndSettle();
    });
    testWidgets("Stepper selects Link type and navigates through all steps",
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      tester.testTextInput.register();
      Future<void> addLink(String url) async {
        await tester.enterText(
            find.widgetWithText(TextFormField, "Enter Link"), url);
        await tester.pumpAndSettle();
        await tester.tap(find.text("Add Link"));
        await tester.pumpAndSettle();
      }

      // Verify initial step
      expect(find.text("Folder"), findsOneWidget);
      final nextButton = find.text("Next");

      await tester.tap(find.text("Folder"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Create"));
      await tester.pumpAndSettle();

      expect(find.byType(FolderDraftStep), findsOneWidget);

      Future<void> enterAndVerifyText(String label, String text) async {
        expect(find.widgetWithText(TextFormField, label), findsOneWidget);
        await tester.enterText(find.widgetWithText(TextFormField, label), text);
        await tester.pump();
      }

      await enterAndVerifyText("Title", "testTitle");
      await enterAndVerifyText("Description", TestData.smallText);
      await enterAndVerifyText("Tags", "testTag");

      // Verify and interact with FolderTypeDropDown
      expect(find.widgetWithText(FolderTypeDropDown, "Folder type"),
          findsOneWidget);
      await tester.tap(find.widgetWithText(FolderTypeDropDown, "Folder type"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Link").last);
      await tester.pumpAndSettle();
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      // Step 2
      expect(find.text("Data"), findsOneWidget);
      expect(find.widgetWithText(TextFormField, "Enter Link"), findsOneWidget);
      expect(find.text("Add Link"), findsOneWidget);
      for (final url in TestData.urls) {
        await addLink(url);
      }
      final checkboxes = tester.widgetList(find.descendant(
        of: find.byType(PlutoGrid),
        matching: find.byType(Checkbox),
      ));
      for (int i = 0; i <= 5; i++) {
        await tester.tap(find.byWidget(checkboxes.elementAt(i)));
        await tester.pumpAndSettle();
      }
      expect(find.text("Remove selected"), findsOneWidget);
      await tester.tap(find.text("Remove selected"));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
          nextButton, find.byType(PageView), const Offset(0, -100));
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Save"));
      await tester.pumpAndSettle();
      //expect(find.text('Folder created successfully'), findsOneWidget);
    });

    testWidgets("FolderForm allows folder selection",
        (WidgetTester tester) async {
      await tester
          .pumpWidget(MaterialApp(home: FolderForm(addItem: (item) {})));

      // Test search functionality
      await tester.enterText(find.byType(TextField), "Folder 1");
      await tester.pump();
      expect(find.text("Folder 1"), findsOneWidget);
      expect(find.text("Folder 2"), findsNothing);

      // Test folder selection
      await tester.tap(find.text("Folder 1"));
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Test view toggle
      await tester.tap(find.byIcon(Icons.list));
      await tester.pump();
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
