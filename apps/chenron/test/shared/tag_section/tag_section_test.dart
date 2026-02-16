import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/shared/tag_section/tag_section.dart";

void main() {
  Widget buildTagSection({
    String? title,
    String? description,
    Set<String> tags = const {},
    ValueChanged<String>? onTagAdded,
    ValueChanged<String>? onTagRemoved,
    String? keyPrefix,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TagSection(
            title: title,
            description: description,
            tags: tags,
            onTagAdded: onTagAdded ?? (_) {},
            onTagRemoved: onTagRemoved ?? (_) {},
            keyPrefix: keyPrefix,
          ),
        ),
      ),
    );
  }

  group("TagSection rendering", () {
    testWidgets("renders default title when none provided", (tester) async {
      await tester.pumpWidget(buildTagSection());
      await tester.pumpAndSettle();

      expect(find.text("Tags"), findsOneWidget);
    });

    testWidgets("renders custom title", (tester) async {
      await tester.pumpWidget(buildTagSection(title: "Global Tags"));
      await tester.pumpAndSettle();

      expect(find.text("Global Tags"), findsOneWidget);
    });

    testWidgets("renders description when provided", (tester) async {
      await tester.pumpWidget(
          buildTagSection(description: "Add tags to all links"));
      await tester.pumpAndSettle();

      expect(find.text("Add tags to all links"), findsOneWidget);
    });

    testWidgets("does not render description when null", (tester) async {
      await tester.pumpWidget(buildTagSection(description: null));
      await tester.pumpAndSettle();

      // Only the title text, no description
      expect(find.text("Tags"), findsOneWidget);
    });

    testWidgets("renders tag input field and add button", (tester) async {
      await tester.pumpWidget(buildTagSection());
      await tester.pumpAndSettle();

      expect(find.text("Add tag"), findsOneWidget);
      expect(find.text("Add"), findsOneWidget);
    });

    testWidgets("renders existing tags as chips", (tester) async {
      await tester
          .pumpWidget(buildTagSection(tags: {"flutter", "dart", "test"}));
      await tester.pumpAndSettle();

      expect(find.text("#flutter"), findsOneWidget);
      expect(find.text("#dart"), findsOneWidget);
      expect(find.text("#test"), findsOneWidget);
    });

    testWidgets("does not render chip area when tags empty", (tester) async {
      await tester.pumpWidget(buildTagSection(tags: {}));
      await tester.pumpAndSettle();

      expect(find.byType(InputChip), findsNothing);
    });

    testWidgets("applies keyPrefix to input field", (tester) async {
      await tester.pumpWidget(buildTagSection(keyPrefix: "test_prefix"));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("test_prefix_tag_input")), findsOneWidget);
      expect(
          find.byKey(const Key("test_prefix_tag_add_button")), findsOneWidget);
    });
  });

  group("TagSection tag addition", () {
    testWidgets("calls onTagAdded with valid tag via button", (tester) async {
      String? addedTag;
      await tester.pumpWidget(buildTagSection(
        onTagAdded: (tag) => addedTag = tag,
      ));
      await tester.pumpAndSettle();

      // Enter a valid tag
      final input = find.byType(TextField);
      await tester.enterText(input, "flutter");
      await tester.pumpAndSettle();

      // Tap add button
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(addedTag, "flutter");
    });

    testWidgets("calls onTagAdded with valid tag via submit", (tester) async {
      String? addedTag;
      await tester.pumpWidget(buildTagSection(
        onTagAdded: (tag) => addedTag = tag,
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "dart");
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(addedTag, "dart");
    });

    testWidgets("trims and lowercases tag input", (tester) async {
      String? addedTag;
      await tester.pumpWidget(buildTagSection(
        onTagAdded: (tag) => addedTag = tag,
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "  Flutter  ");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(addedTag, "flutter");
    });

    testWidgets("does not call onTagAdded for empty input", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildTagSection(
        onTagAdded: (_) => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(wasCalled, false);
    });

    testWidgets("shows error for duplicate tag", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildTagSection(
        tags: {"flutter"},
        onTagAdded: (_) => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "flutter");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(wasCalled, false);
      expect(find.textContaining("already exists"), findsOneWidget);
    });

    testWidgets("shows error for invalid tag (special characters)",
        (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildTagSection(
        onTagAdded: (_) => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "my-tag");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(wasCalled, false);
      expect(find.textContaining("letters and numbers"), findsOneWidget);
    });

    testWidgets("accepts alphanumeric tags", (tester) async {
      String? addedTag;
      await tester.pumpWidget(buildTagSection(
        onTagAdded: (tag) => addedTag = tag,
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "rule34");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(addedTag, "rule34");
    });

    testWidgets("rejects purely numeric tags", (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(buildTagSection(
        onTagAdded: (_) => wasCalled = true,
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "12345");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(wasCalled, false);
      expect(find.textContaining("at least one letter"), findsOneWidget);
    });

    testWidgets("clears input after successful add", (tester) async {
      await tester.pumpWidget(buildTagSection(
        onTagAdded: (_) {},
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "validtag");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      // Input should be cleared
      final textField = tester.widget<TextField>(input);
      expect(textField.controller!.text, isEmpty);
    });

    testWidgets("adds multiple tags from comma-separated input",
        (tester) async {
      final addedTags = <String>[];
      await tester.pumpWidget(buildTagSection(
        onTagAdded: addedTags.add,
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "flutter, dart, web");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(addedTags, ["flutter", "dart", "web"]);
    });

    testWidgets("rejects entire bulk input if one tag is invalid",
        (tester) async {
      final addedTags = <String>[];
      await tester.pumpWidget(buildTagSection(
        onTagAdded: addedTags.add,
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "flutter, ab, dart");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(addedTags, isEmpty);
      expect(find.textContaining("3-12 characters"), findsOneWidget);
    });

    testWidgets("rejects bulk input if one tag is duplicate", (tester) async {
      final addedTags = <String>[];
      await tester.pumpWidget(buildTagSection(
        tags: {"flutter"},
        onTagAdded: addedTags.add,
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "dart, flutter, web");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(addedTags, isEmpty);
      expect(find.textContaining("already exists"), findsOneWidget);
    });

    testWidgets("handles extra commas in bulk input", (tester) async {
      final addedTags = <String>[];
      await tester.pumpWidget(buildTagSection(
        onTagAdded: addedTags.add,
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);
      await tester.enterText(input, "flutter,,dart,  ,web");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();

      expect(addedTags, ["flutter", "dart", "web"]);
    });

    testWidgets("clears error when user types again", (tester) async {
      await tester.pumpWidget(buildTagSection(
        tags: {"flutter"},
        onTagAdded: (_) {},
      ));
      await tester.pumpAndSettle();

      final input = find.byType(TextField);

      // Trigger duplicate error
      await tester.enterText(input, "flutter");
      await tester.tap(find.text("Add"));
      await tester.pumpAndSettle();
      expect(find.textContaining("already exists"), findsOneWidget);

      // Start typing again - error should clear
      await tester.enterText(input, "d");
      await tester.pumpAndSettle();
      expect(find.textContaining("already exists"), findsNothing);
    });
  });

  group("TagSection tag removal", () {
    testWidgets("calls onTagRemoved when chip delete tapped", (tester) async {
      String? removedTag;
      await tester.pumpWidget(buildTagSection(
        tags: {"flutter", "dart"},
        onTagRemoved: (tag) => removedTag = tag,
      ));
      await tester.pumpAndSettle();

      // Find the "flutter" chip and tap its delete button
      final chip = find.widgetWithText(InputChip, "#flutter");
      expect(chip, findsOneWidget);

      // InputChip renders the delete button with a "Delete" tooltip
      final deleteButton = find.descendant(
        of: chip,
        matching: find.byTooltip("Delete"),
      );
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(removedTag, "flutter");
    });
  });

  group("TagSection lifecycle", () {
    testWidgets("disposes controllers without errors", (tester) async {
      await tester.pumpWidget(buildTagSection());
      await tester.pumpAndSettle();

      // Remove from tree
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // No errors = pass
    });
  });
}
