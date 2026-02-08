import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/create/link/widgets/link_inputs.dart";

void main() {
  group("SingleInput", () {
    Widget buildSingleInput({
      TextEditingController? controller,
      VoidCallback? onAdd,
      String? errorText,
      String? keyPrefix,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleInput(
            controller: controller ?? TextEditingController(),
            onAdd: onAdd ?? () {},
            errorText: errorText,
            keyPrefix: keyPrefix,
          ),
        ),
      );
    }

    testWidgets("renders URL input field and Add button", (tester) async {
      await tester.pumpWidget(buildSingleInput());
      await tester.pumpAndSettle();

      expect(find.text("URL"), findsOneWidget);
      expect(find.text("Add"), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets("displays hint text", (tester) async {
      await tester.pumpWidget(buildSingleInput());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration!.hintText,
          "https://example.com | tag1, tag2");
    });

    testWidgets("shows error text when provided", (tester) async {
      await tester.pumpWidget(buildSingleInput(errorText: "Invalid URL"));
      await tester.pumpAndSettle();

      expect(find.text("Invalid URL"), findsOneWidget);
    });

    testWidgets("calls onAdd when Add button pressed", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildSingleInput(
        onAdd: () => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(wasCalled, true);
    });

    testWidgets("calls onAdd on keyboard submit", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildSingleInput(
        onAdd: () => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "https://example.com");
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(wasCalled, true);
    });

    testWidgets("uses keyPrefix for add button key", (tester) async {
      await tester.pumpWidget(buildSingleInput(keyPrefix: "link_input"));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key("link_input_add_button")), findsOneWidget);
    });

    testWidgets("uses default key when no keyPrefix", (tester) async {
      await tester.pumpWidget(buildSingleInput());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("single_add_button")), findsOneWidget);
    });

    testWidgets("accepts text input", (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildSingleInput(controller: controller));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField), "https://example.com | tag1, tag2");
      expect(controller.text, "https://example.com | tag1, tag2");
    });
  });

  group("BulkInput", () {
    // BulkInput depends on EditableCodeField with GlobalKey,
    // which is complex to test in isolation. We test the structural elements.
    testWidgets("renders label and buttons", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BulkInput(
              fieldKey: GlobalKey(),
              onAdd: () {},
              onClear: () {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text("URLs (one per line)"), findsOneWidget);
      expect(find.text("Clear"), findsOneWidget);
      expect(find.text("Add"), findsOneWidget);
    });

    testWidgets("calls onClear when Clear pressed", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BulkInput(
              fieldKey: GlobalKey(),
              onAdd: () {},
              onClear: () => wasCalled = true,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Clear"));
      await tester.pumpAndSettle();

      expect(wasCalled, true);
    });

    testWidgets("calls onAdd when Add pressed", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BulkInput(
              fieldKey: GlobalKey(),
              onAdd: () => wasCalled = true,
              onClear: () {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("bulk_add_button")));
      await tester.pumpAndSettle();

      expect(wasCalled, true);
    });

    testWidgets("has correct button keys", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BulkInput(
              fieldKey: GlobalKey(),
              onAdd: () {},
              onClear: () {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("bulk_clear_button")), findsOneWidget);
      expect(find.byKey(const Key("bulk_add_button")), findsOneWidget);
    });
  });
}
