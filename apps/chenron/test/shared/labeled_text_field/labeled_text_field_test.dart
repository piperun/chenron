import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/shared/labeled_text_field/labeled_text_field.dart";

void main() {
  Widget buildField({
    String labelText = "Label",
    String? hintText,
    Icon? icon,
    String? errorText,
    TextInputAction? textInputAction,
    int? maxLines = 1,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    TextEditingController? controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: LabeledTextField(
          labelText: labelText,
          hintText: hintText,
          controller: controller ?? TextEditingController(),
          icon: icon,
          errorText: errorText,
          textInputAction: textInputAction,
          maxLines: maxLines,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }

  group("LabeledTextField rendering", () {
    testWidgets("displays label text", (tester) async {
      await tester.pumpWidget(buildField(labelText: "URL"));
      await tester.pumpAndSettle();

      expect(find.text("URL"), findsOneWidget);
    });

    testWidgets("displays hint text", (tester) async {
      await tester.pumpWidget(
          buildField(hintText: "https://example.com"));
      await tester.pumpAndSettle();

      // Hint text is shown in InputDecoration
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration!.hintText, "https://example.com");
    });

    testWidgets("displays prefix icon when provided", (tester) async {
      await tester
          .pumpWidget(buildField(icon: const Icon(Icons.link)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets("does not display prefix icon when null", (tester) async {
      await tester.pumpWidget(buildField(icon: null));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration!.prefixIcon, isNull);
    });

    testWidgets("displays error text when provided", (tester) async {
      await tester
          .pumpWidget(buildField(errorText: "Invalid URL"));
      await tester.pumpAndSettle();

      expect(find.text("Invalid URL"), findsOneWidget);
    });

    testWidgets("does not display error when null", (tester) async {
      await tester.pumpWidget(buildField(errorText: null));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration!.errorText, isNull);
    });

    testWidgets("uses OutlineInputBorder", (tester) async {
      await tester.pumpWidget(buildField());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration!.border, isA<OutlineInputBorder>());
    });
  });

  group("LabeledTextField interaction", () {
    testWidgets("calls onChanged when text changes", (tester) async {
      String? changedValue;
      await tester.pumpWidget(buildField(
        onChanged: (value) => changedValue = value,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "hello");
      expect(changedValue, "hello");
    });

    testWidgets("calls onSubmitted when submitted", (tester) async {
      String? submittedValue;
      await tester.pumpWidget(buildField(
        onSubmitted: (value) => submittedValue = value,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "test");
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submittedValue, "test");
    });

    testWidgets("respects maxLines parameter", (tester) async {
      await tester.pumpWidget(buildField(maxLines: 5));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 5);
    });

    testWidgets("controller reflects typed text", (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(buildField(controller: controller));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), "typed text");
      expect(controller.text, "typed text");
    });
  });
}
