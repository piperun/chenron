// ignore_for_file: avoid_print

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/components/TextBase/editable_code_field.dart";
import "package:chenron/features/create/link/models/validation_result.dart";

void main() {
  group("EditableCodeField", () {
    testWidgets("should allow text input", (WidgetTester tester) async {
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableCodeField(
              initialText: "Hello World",
              onChanged: (text) => changedText = text,
            ),
          ),
        ),
      );

      // Find the editable text
      final editableText = find.byType(EditableText);
      expect(editableText, findsOneWidget);

      // Tap to focus
      await tester.tap(editableText);
      await tester.pump();

      // Type some text
      await tester.enterText(editableText, "New text");
      await tester.pump();

      expect(changedText, "New text");
    });

    testWidgets("should allow mouse text selection",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EditableCodeField(
              initialText: "Hello World",
            ),
          ),
        ),
      );

      // Find the editable text
      final editableText = find.byType(EditableText);
      expect(editableText, findsOneWidget);

      // Get the EditableText widget
      final EditableText widget = tester.widget(editableText);

      // Long press at start position to begin selection
      final topLeft = tester.getTopLeft(editableText);
      final startPoint = topLeft + const Offset(10, 5);
      final endPoint = topLeft + const Offset(50, 5);

      // Use longPress and drag to select text (this is how text selection works in Flutter)
      final TestGesture gesture = await tester.startGesture(startPoint);
      await tester
          .pump(const Duration(milliseconds: 500)); // Long press duration

      await gesture.moveTo(endPoint);
      await tester.pumpAndSettle();

      await gesture.up();
      await tester.pumpAndSettle();

      // Check if text is selected
      // After long press and drag, we should have a selection
      expect(widget.controller.selection.isValid, isTrue);
      // The selection should not be collapsed (base != extent)
      expect(widget.controller.selection.isCollapsed, isFalse);
    });

    testWidgets("should display error highlights", (WidgetTester tester) async {
      final validationResult = BulkValidationResult(
        lines: [
          const LineValidationResult(
            lineNumber: 1,
            rawLine: "invalid url",
            isValid: false,
            errors: [
              ValidationError(
                type: ValidationErrorType.urlInvalidFormat,
                message: "Invalid URL",
                startIndex: 0,
                endIndex: 7,
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableCodeField(
              initialText: "invalid url",
              validationResult: validationResult,
            ),
          ),
        ),
      );

      // Should render without error
      expect(find.byType(EditableCodeField), findsOneWidget);

      // Should have CustomPaint for error highlighting
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets("should sync scroll between line numbers and text",
        (WidgetTester tester) async {
      final longText = List.generate(20, (i) => "Line ${i + 1}").join("\n");

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 200,
              child: EditableCodeField(
                initialText: longText,
                maxLines: 5,
              ),
            ),
          ),
        ),
      );

      // Should render
      expect(find.byType(EditableCodeField), findsOneWidget);

      // Find scroll views
      final scrollViews = find.byType(SingleChildScrollView);
      expect(scrollViews, findsWidgets);
    });
  });
}
