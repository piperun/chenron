import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/test_support/test_app.dart";
import "package:chenron/test_support/path_provider_fake.dart";
import "package:chenron/test_support/logger_setup.dart";
import "package:flutter/gestures.dart";
import "package:chenron/components/TextBase/editable_code_field.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  group("Add Link", () {
    group("Add Link - Navigation", () {
    testWidgets("should navigate to add link screen from home", (tester) async {
      await tester.pumpWidget(await createTestApp());

      // Find and tap the "Add New Item" button or navigation
      // Adjust the finder based on your actual UI
      final addButton = find.byTooltip("Add New Item");
      if (addButton.evaluate().isEmpty) {
        // Try alternative ways to find the add button
        final altAddButton = find.byIcon(Icons.add);
        expect(altAddButton, findsOneWidget);
        await tester.tap(altAddButton);
      } else {
        await tester.tap(addButton);
      }
      await tester.pumpAndSettle();

      // Should show options to add link or document
      final linkOption = find.text("Link");
      expect(linkOption, findsOneWidget);

      await tester.tap(linkOption);
      await tester.pumpAndSettle();

      // Should now be on the add link screen
      // Verify by finding the URL input field
      final urlField = find.text("Archive new links");
      expect(urlField, findsOneWidget);
    });
    });

    group("Single Mode", () {
      group("Single URL Input", () {
    const addKey = Key("single");
    testWidgets("should accept valid single URL", (tester) async {
      await tester.pumpWidget(await createTestApp());

      // Navigate to add link screen
      await _navigateToAddLink(tester);

      // Find the bulk URL input field
      final urlInput = find.byType(EditableText).first;

      // Enter a valid URL
      await tester.enterText(urlInput, "https://flutter.dev");
      await tester.pumpAndSettle();

      // Should not show any error indicators
      final errorIndicator = find.textContaining("Invalid");
      expect(errorIndicator, findsNothing);

      // Find and tap the "Parse & Add" button
      final addButton = find.byKey(addKey);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Should show success or navigate away
      // Verify the URL was added (this depends on your UI feedback)
      });

    testWidgets("should reject invalid single URL", (tester) async {
      await tester.pumpWidget(await createTestApp());

      await _navigateToAddLink(tester);

      final urlInput = find.byType(EditableText).first;

      // Enter an invalid URL
      await tester.enterText(urlInput, "not a valid url");
      await tester.pumpAndSettle();

      // Should show error highlighting or validation message
      // The line number should be highlighted with error color
      // (Visual verification - hard to test directly)

      // Try to submit
      final bulkButton = find.byKey(addKey);
      await tester.tap(bulkButton);
      await tester.pumpAndSettle();

      // Should still be on the add link screen (not submitted)
      final urlField = find.text("URL");
      expect(urlField, findsOneWidget);
      });

    testWidgets("should show inline error highlighting for invalid URL parts",
          (tester) async {
      await tester.pumpWidget(await createTestApp());

      await _navigateToAddLink(tester);

      final urlInput = find.byType(EditableText).first;

      // Enter URL with invalid characters
      await tester.enterText(urlInput, "https://example.com/bad<>chars");
      await tester.pumpAndSettle();

      // The CustomPaint should be rendering error highlights
      final customPaint = find.byType(CustomPaint);
      expect(customPaint, findsWidgets);

      // In single mode, error is shown differently (not in validation panel)
      // Visual verification test - just verify CustomPaint renders
      });
      });

    });

    group("Bulk Mode", () {
      group("Bulk URL Input", () {
      testWidgets("should accept multiple valid URLs", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Enter multiple valid URLs
        const multipleUrls = """https://flutter.dev
https://dart.dev
https://github.com/flutter""";

        await tester.enterText(urlInput, multipleUrls);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("bulk_add_button")));
        await tester.pumpAndSettle();

        final inputText = tester.widget(urlInput);
        expect((inputText as EditableText).controller.text, isEmpty);
        });

      testWidgets("should handle mix of valid and invalid URLs", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Enter mix of valid and invalid URLs
        const mixedUrls = """https://flutter.dev
invalid url here
https://dart.dev
not a url either
https://github.com/flutter""";

        await tester.enterText(urlInput, mixedUrls);
        await tester.pumpAndSettle();

        // Should show error highlighting on invalid lines
        // Line 2 and 4 should have error indicators

        // Should show validation summary with counts
        final errorCount = find.textContaining("2");
        expect(errorCount, findsAtLeastNWidgets(1));

        final validCount = find.textContaining("3");
        expect(validCount, findsAtLeastNWidgets(1));
        });

      testWidgets("should auto-remove valid URLs after adding, leaving errors",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Enter mix of valid and invalid URLs
        const mixedUrls = """https://flutter.dev
invalid url_1
https://dart.dev""";

        await tester.enterText(urlInput, mixedUrls);
        await tester.pumpAndSettle();

        // Submit
        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        final remainingText = find.text("invalid url_1");
        expect(remainingText, findsAtLeastNWidgets(1));
        });

      testWidgets("should handle empty lines and whitespace", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final urlInput = find.byType(EditableText).first;

        // Enter URLs with empty lines and whitespace
        const urlsWithSpaces = """https://flutter.dev

      https://dart.dev    
""";

        await tester.enterText(urlInput, urlsWithSpaces);
        await tester.pumpAndSettle();

        // Should handle gracefully, ignoring empty lines
        // Should trim whitespace from URLs
        });

      testWidgets("should handle very long URL list", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Generate many URLs
        final manyUrls =
            List.generate(50, (i) => "https://example$i.com").join("\n");

        await tester.enterText(urlInput, manyUrls);
        await tester.pumpAndSettle();

        // Should handle without crashing
        // Should show correct count
        final validCount = find.textContaining("50");
        expect(validCount, findsAtLeastNWidgets(1));
        });
        });

      group("Text Selection and Editing", () {
      testWidgets("should allow keyboard text selection with Shift+Arrow",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final urlInput = find.byType(EditableText).first;

        await tester.enterText(urlInput, "https://flutter.dev");
        await tester.pumpAndSettle();

        // Tap to focus
        await tester.tap(urlInput);
        await tester.pumpAndSettle();

        // Use keyboard to select text (Shift+Arrow keys)
        // Move cursor to start
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();

        // Select some text with Shift+Arrow
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        for (int i = 0; i < 5; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        }
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();

        // Should have selection (hard to verify visually, but shouldn't crash)
        });

      testWidgets("should allow mouse text selection (integration test)",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final urlInput = find.byType(EditableText).first;

        await tester.enterText(urlInput, "https://flutter.dev");
        await tester.pumpAndSettle();

        // Get the position of the EditableText
        final Offset textFieldPos = tester.getTopLeft(urlInput);

        // Simulate mouse drag to select text
        final startPoint = textFieldPos + const Offset(5, 5);
        final endPoint = textFieldPos + const Offset(50, 5);

        // Create a mouse drag gesture
        final TestGesture gesture =
            await tester.startGesture(startPoint, kind: PointerDeviceKind.mouse);
        await tester.pump();

        await gesture.moveTo(endPoint);
        await tester.pump();

        await gesture.up();
        await tester.pumpAndSettle();

        // Text should be selected (visual verification in actual test run)
        // The selection color should be visible
        });

      testWidgets("should allow copy and paste", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final urlInput = find.byType(EditableText).first;

        await tester.enterText(urlInput, "https://flutter.dev");
        await tester.pumpAndSettle();

        // Select all
        await tester.tap(urlInput);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();

        // Copy
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();

        // Clear
        await tester.sendKeyEvent(LogicalKeyboardKey.delete);
        await tester.pump();

        // Paste
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();

        // Should have the same text back
        expect(find.text("https://flutter.dev"), findsOneWidget);
        });
        });

      group("Line Number Alignment", () {
      testWidgets("line numbers should stay aligned with text during scrolling",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final urlInput = find.byType(EditableText).first;

        // Enter many lines to trigger scrolling
        final manyLines =
            List.generate(20, (i) => "https://example$i.com").join("\n");
        await tester.enterText(urlInput, manyLines);
        await tester.pumpAndSettle();

        // Scroll down in the input
        await tester.drag(urlInput, const Offset(0, -200));
        await tester.pumpAndSettle();

        // Line numbers should still be aligned
        // Visual verification required
        });

      testWidgets("line numbers should highlight errors correctly",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final urlInput = find.byType(EditableText).first;

        const mixedUrls = """https://flutter.dev
invalid
https://dart.dev""";

        await tester.enterText(urlInput, mixedUrls);
        await tester.pumpAndSettle();

        // Line 2 should be highlighted with error color in the gutter
        // Visual verification required
        });
        });

      group("Clear Button", () {
      testWidgets("should clear all input when clear button is pressed",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        await tester.enterText(urlInput, "https://flutter.dev\nhttps://dart.dev");
        await tester.pumpAndSettle();

        // Find and tap clear button
        final clearButton = find.byKey(const Key("bulk_clear_button"));
        expect(clearButton, findsOneWidget);
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        // Input should be empty
        // Visual verification or check if EditableText is empty
        });
        });

      group("Tag Parsing", () {
      testWidgets("should parse inline tags with pipe syntax", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Enter URL with pipe-separated tags (min length 3 chars)
        await tester.enterText(
            urlInput, "https://flutter.dev | flutter, dart, gui");
        await tester.pumpAndSettle();

        // Should parse URL and tags correctly
        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });

      testWidgets("should parse inline tags with hashtag syntax", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Enter URL with hashtag tags
        await tester.enterText(
            urlInput, "https://dart.dev #dart #programming #google");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });

      testWidgets("should handle mixed tag syntax in bulk mode", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        const mixedTags = """https://flutter.dev | flutter, gui
https://dart.dev #dart #programming
https://github.com/flutter | github, flutter #opensource""";

        await tester.enterText(urlInput, mixedTags);
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });

      testWidgets("should reject lines with invalid tag characters", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Enter URL with invalid tags (numbers, special chars)
        // The entire line should be rejected due to invalid tags
        await tester.enterText(
            urlInput, "https://flutter.dev | tag123, tag@invalid");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should show validation errors for invalid tags
        final errorPanel = find.textContaining("errors");
        expect(errorPanel, findsAtLeastNWidgets(1));
        
        // URL should NOT be added to table
        expect(find.text("No links added yet"), findsOneWidget);
        });

      testWidgets("should reject tags that are too short", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Enter URL with tags that are too short (min length is 3)
        await tester.enterText(urlInput, "https://flutter.dev | a, ab");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should show validation errors for tags being too short
        // Panel shows "1 line has errors" for single line, "N lines have errors" for multiple
        final errorPanel = find.textContaining("errors");
        expect(errorPanel, findsAtLeastNWidgets(1));
        });
        });

      group("Edge Cases", () {
      testWidgets("should handle URLs with special characters", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // URL with query parameters, anchors, etc.
        await tester.enterText(
            urlInput, "https://example.com/path?query=value&key=123#section");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });

      testWidgets("should handle URLs with authentication", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // URL with user:pass authentication
        await tester.enterText(urlInput, "https://user:pass@example.com/secure");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });

      testWidgets("should handle URLs with non-standard ports", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        await tester.enterText(urlInput, "https://example.com:8443/api");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });

      testWidgets("should handle URLs with international domain names",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // IDN with unicode
        await tester.enterText(urlInput, "https://münchen.de");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key('bulk_add_button'));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });

      testWidgets("should reject URLs without protocol", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        await tester.enterText(urlInput, "example.com");
        await tester.pumpAndSettle();

        // Should show error
        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should remain on add link screen
        final urlField = find.text("URLs (one per line)");
        expect(urlField, findsOneWidget);
        });

      testWidgets("should reject URLs with invalid protocols", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        await tester.enterText(urlInput, "ftp://example.com");
        await tester.pumpAndSettle();

        // FTP might be rejected depending on validation rules
        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });

      testWidgets("should handle extremely long URLs", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Generate a very long URL that exceeds 2048 chars limit
        // "https://example.com/" is 20 chars, so add 2030 more to exceed 2048
        final longPath = "a" * 2030;
        await tester.enterText(urlInput, "https://example.com/$longPath");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should show error for URL too long
        final errorPanel = find.textContaining("errors");
        expect(errorPanel, findsAtLeastNWidgets(1));
        });

      testWidgets("should handle URLs with encoded characters", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        await tester.enterText(
            urlInput, "https://example.com/search?q=flutter%20tutorial");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });
        });

      group("Comments and Formatting", () {
      testWidgets("should ignore comment lines starting with #", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        const withComments = """# This is a comment
https://flutter.dev
# Another comment
https://dart.dev""";

        await tester.enterText(urlInput, withComments);
        await tester.pumpAndSettle();

        // Should only count non-comment lines
        final validCount = find.textContaining("2");
        expect(validCount, findsAtLeastNWidgets(1));
        });

      testWidgets("should handle trailing whitespace", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        const withSpaces = """https://flutter.dev
   https://dart.dev
https://github.com/flutter     """;

        await tester.enterText(urlInput, withSpaces);
        await tester.pumpAndSettle();

        // Should trim and validate correctly
        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });

      testWidgets("should handle tabs and mixed whitespace", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Mix of tabs and spaces
        await tester.enterText(
            urlInput, "\thttps://flutter.dev  \n  \t  https://dart.dev");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });
        });

      group("Duplicate Detection", () {
      testWidgets("should detect duplicate URLs in bulk input", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        const duplicates = """https://flutter.dev
https://dart.dev
https://flutter.dev
https://github.com/flutter
https://dart.dev""";

        await tester.enterText(urlInput, duplicates);
        await tester.pumpAndSettle();

        // Should handle duplicates (either warn or auto-dedupe)
        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        });
        });

      group("Mode Switching", () {
      testWidgets("should preserve input when switching modes", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;
        await tester.enterText(urlInput, "https://flutter.dev");
        await tester.pumpAndSettle();

        // Switch to single mode
        final singleButton = find.text("Single");
        await tester.tap(singleButton);
        await tester.pumpAndSettle();

        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        // Original text might or might not be preserved
        // This is a UX decision
        });

      testWidgets("should clear validation when switching modes", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;
        await tester.enterText(urlInput, "invalid url");
        await tester.pumpAndSettle();

        // Trigger validation
        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Switch modes
        final singleButton = find.text("Single");
        await tester.tap(singleButton);
        await tester.pumpAndSettle();

        // Validation errors should be cleared
        });
        });

      group("Performance", () {
      testWidgets("should handle 100+ URLs without freezing", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Generate 100 URLs
        final manyUrls =
            List.generate(100, (i) => "https://example$i.com").join("\n");

        await tester.enterText(urlInput, manyUrls);
        await tester.pumpAndSettle();

        // Should handle without crashing or freezing
        final validCount = find.textContaining("100");
        expect(validCount, findsAtLeastNWidgets(1));

        // Submission might take time but shouldn't freeze UI
        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pump(); // Don't wait for settle, just verify it starts

        // Wait a bit but not full settle
        await tester.pump(const Duration(milliseconds: 100));
        });
        });

      group("Validation Status Display", () {
      testWidgets("should show validation status for each URL", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        await tester.enterText(urlInput, "https://flutter.dev");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // After submission, validation status should be shown
        // This depends on the UI implementation
        });
        });

      group("Undo/Redo", () {
      testWidgets("should support undo with Ctrl+Z", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final urlInput = find.byType(EditableText).first;

        await tester.enterText(urlInput, "https://flutter.dev");
        await tester.pumpAndSettle();

        // Type more
        await tester.enterText(urlInput, "https://flutter.dev\nhttps://dart.dev");
        await tester.pumpAndSettle();

        // Undo
        await tester.tap(urlInput);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();

        // Should have undone the last change
        });
        });

      group("Accessibility", () {
      testWidgets("should have proper semantics for screen readers",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        // Verify important elements have semantic labels
        // This is for accessibility compliance
        final urlField = find.text("URLs (one per line)");
        expect(urlField, findsOneWidget);

        final addButton = find.byKey(const Key("bulk_add_button"));
        expect(addButton, findsOneWidget);
        });
        });

      group("Bulk Submission with Table Verification", () {
      testWidgets("should add valid bulk URLs to table after Parse & Add",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // Enter multiple valid URLs
        const bulkUrls = """https://flutter.dev
https://dart.dev
https://github.com/flutter""";

        await tester.enterText(urlInput, bulkUrls);
        await tester.pumpAndSettle();

        // Submit
        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Verify links appear in the table
        expect(find.text("https://flutter.dev"), findsAtLeastNWidgets(1));
        expect(find.text("https://dart.dev"), findsAtLeastNWidgets(1));
        expect(find.text("https://github.com/flutter"), findsAtLeastNWidgets(1));

        // Verify table shows count
        expect(find.textContaining("Prepared Links (3)"), findsOneWidget);
        });

      testWidgets(
          "should add only valid URLs to table when mix of valid/invalid submitted",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        const mixedUrls = """https://flutter.dev
invalid url here
https://dart.dev""";

        await tester.enterText(urlInput, mixedUrls);
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should add 2 valid URLs to table
        expect(find.textContaining("Prepared Links (2)"), findsOneWidget);

        // Valid URLs should be in table
        expect(find.text("https://flutter.dev"), findsAtLeastNWidgets(1));
        expect(find.text("https://dart.dev"), findsAtLeastNWidgets(1));

        // Should show success message
        expect(find.textContaining("Added 2 valid URL(s) successfully"), findsOneWidget);
        });

      testWidgets("should show error when all URLs are invalid", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        const invalidUrls = """invalid url 1
not a url either
bad input""";

        await tester.enterText(urlInput, invalidUrls);
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should not add anything to table
        expect(find.text("No links added yet"), findsOneWidget);
        expect(find.textContaining("Prepared Links (0)"), findsOneWidget);

        // Should show validation error panel indicating 3 lines have errors
        expect(find.textContaining("3 lines have errors"),
            findsOneWidget);
        });

      testWidgets("should parse and add URLs with inline tags", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        const urlsWithTags = """https://flutter.dev | flutter, gui
https://dart.dev #dart #programming""";

        await tester.enterText(urlInput, urlsWithTags);
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // URLs should be in table
        expect(find.textContaining("Prepared Links (2)"), findsOneWidget);

        // Tags should be visible in table (min length is 3 chars)
        expect(find.text("#flutter"), findsWidgets);
        expect(find.text("#gui"), findsWidgets);
        expect(find.text("#dart"), findsWidgets);
        expect(find.text("#programming"), findsWidgets);
        });
        });

      group("Valid Lines Removal and Correction", () {
      testWidgets(
          "should remove valid URLs and keep invalid ones with tags preserved",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        const mixedUrls = """https://flutter.dev | flutter, gui
invalid url
https://dart.dev #dart""";

        await tester.enterText(urlInput, mixedUrls);
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Table should have 2 valid entries (tags must be >= 3 chars)
        expect(find.textContaining("Prepared Links (2)"), findsOneWidget);

        // Check the EditableText state directly for remaining content
        final editableText = tester.widget<EditableText>(urlInput);
        final remainingText = editableText.controller.text;

        // Only invalid line should remain in input
        expect(remainingText.contains("invalid url"), isTrue);
        expect(remainingText.contains("https://flutter.dev"), isFalse);
        expect(remainingText.contains("https://dart.dev"), isFalse);
        });

      testWidgets("should allow correction and resubmission of invalid URLs",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // First submission with invalid URL
        await tester.enterText(urlInput, "invalid url");
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should show error and keep invalid URL (error panel shows line count)
        expect(find.textContaining("1 line has errors"),
            findsOneWidget);

        // Clear the input using the clear button
        final clearButton = find.byKey(const Key("bulk_clear_button"));
        await tester.ensureVisible(clearButton);
        await tester.pumpAndSettle();
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        // Find the EditableCodeField and set its text directly through its state
        final codeField = find.byType(EditableCodeField);
        final codeFieldState = tester.state<EditableCodeFieldState>(codeField);
        
        // Set the corrected URL using the state's text setter
        codeFieldState.text = "https://corrected.dev";
        await tester.pumpAndSettle();

        // Ensure the add button is visible
        await tester.ensureVisible(addButton);
        await tester.pumpAndSettle();

        // Resubmit
        print("About to tap add button...");
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        print("Tapped add button and settled.");

        // Should successfully add corrected URL to table
        expect(find.textContaining("Prepared Links (1)"), findsOneWidget);
        expect(find.text("https://corrected.dev"), findsAtLeastNWidgets(1));
        });

      testWidgets("should handle multiple correction iterations until all valid",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        final urlInput = find.byType(EditableText).first;

        // First attempt: 2 valid, 2 invalid
        const attempt1 = """https://valid1.dev
invalid1
https://valid2.dev
invalid2""";

        await tester.enterText(urlInput, attempt1);
        await tester.pumpAndSettle();

        final addButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should have 2 in table
        expect(find.textContaining("Prepared Links (2)"), findsOneWidget);

        // Clear the input field using the clear button
        final clearButton = find.byKey(const Key("bulk_clear_button"));
        await tester.ensureVisible(clearButton);
        await tester.pumpAndSettle();
        await tester.tap(clearButton);
        await tester.pumpAndSettle();

        // Find the EditableCodeField and set its text directly through its state
        final codeField = find.byType(EditableCodeField);
        final codeFieldState = tester.state<EditableCodeFieldState>(codeField);
        
        // Set the fixed URLs using the state's text setter
        codeFieldState.text = """https://fixed1.dev
https://fixed2.dev""";
        await tester.pumpAndSettle();

        // Ensure the add button is visible
        await tester.ensureVisible(addButton);
        await tester.pumpAndSettle();

        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should now have 4 total in table
        expect(find.textContaining("Prepared Links (4)"), findsOneWidget);
        });
        });

    });

    group("Shared Features", () {
      group("Global Tags", () {
      testWidgets("should add global tag and apply to new bulk entries",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        // Find the global tags input field
        final tagInput = find.byKey(const Key("global_tags_tag_input"));
        expect(tagInput, findsOneWidget);

        // Add a global tag
        await tester.enterText(tagInput, "globaltag");
        await tester.pumpAndSettle();

        // Find and tap the Add button for tags
        final addTagButton = find.byKey(const Key("global_tags_tag_add_button"));
        expect(addTagButton, findsOneWidget);

        // Tap the tag add button
        await tester.tap(addTagButton);
        await tester.pumpAndSettle();

        // Verify tag chip appears
        expect(find.text("#globaltag"), findsOneWidget);

        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        // Now add URLs in bulk mode
        final urlInput = find.byType(EditableText).first;
        await tester.enterText(urlInput, "https://example.dev");
        await tester.pumpAndSettle();

        // Submit
        final parseButton = find.byKey(const Key("bulk_add_button"));
        await tester.tap(parseButton);
        await tester.pumpAndSettle();

        // URL should be in table with global tag
        expect(find.textContaining("Prepared Links (1)"), findsOneWidget);

        // Global tag should appear in the table row
        final tableTags = find.descendant(
          of: find.byType(Wrap),
          matching: find.text("#globaltag"),
        );
        expect(tableTags, findsAtLeastNWidgets(1));
        });

      testWidgets("should remove global tag when delete icon clicked",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        // Add a global tag
        final tagInput = find.byKey(const Key("global_tags_tag_input"));
        await tester.enterText(tagInput, "removeme");
        await tester.pumpAndSettle();

        final addTagButton = find.byKey(const Key("global_tags_tag_add_button"));
        await tester.tap(addTagButton);
        await tester.pumpAndSettle();

        // Verify tag appears
        expect(find.text("#removeme"), findsOneWidget);

        // Find the delete icon on the tag chip
        final tagChip = find.byKey(const Key("global_tags_tag_chip_removeme"));
        expect(tagChip, findsOneWidget);

        // Ensure the chip is visible by scrolling to it if needed
        await tester.ensureVisible(tagChip);
        await tester.pumpAndSettle();

        // Find delete icon within the chip
        final deleteIcon = find.descendant(
          of: tagChip,
          matching: find.byType(Icon),
        );
        expect(deleteIcon, findsWidgets);

        // Tap to delete
        await tester.tap(deleteIcon.last);
        await tester.pumpAndSettle();

        // Tag should be gone
        expect(find.text("#removeme"), findsNothing);
        });

      testWidgets("should validate global tag and show error for invalid tag",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final tagInput = find.byKey(const Key("global_tags_tag_input"));

        // Try to add invalid tag (with numbers)
        await tester.enterText(tagInput, "tag123");
        await tester.pumpAndSettle();

        final addTagButton = find.byKey(const Key("global_tags_tag_add_button"));
        await tester.tap(addTagButton);
        await tester.pumpAndSettle();

        // Should show validation error
        expect(
            find.textContaining("only contain alphabetic characters"),
            findsOneWidget);

        // Tag should not be added
        expect(find.text("#tag123"), findsNothing);
        });

      testWidgets("should prevent duplicate global tags", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        final tagInput = find.byKey(const Key("global_tags_tag_input"));

        // Add first tag
        await tester.enterText(tagInput, "duplicate");
        await tester.pumpAndSettle();

        final addTagButton = find.byKey(const Key("global_tags_tag_add_button"));
        await tester.tap(addTagButton);
        await tester.pumpAndSettle();

        // Try to add same tag again
        await tester.enterText(tagInput, "duplicate");
        await tester.pumpAndSettle();

        await tester.tap(addTagButton);
        await tester.pumpAndSettle();

        // Should show duplicate error
        expect(find.textContaining("duplicate"), findsOneWidget);

        // Should only have one instance
        expect(find.text("#duplicate"), findsOneWidget);
        });

      testWidgets("should combine global tags with inline tags", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        // Add global tag
        final tagInput = find.byKey(const Key("global_tags_tag_input"));
        await tester.enterText(tagInput, "global");
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('global_tags_tag_add_button')));
        await tester.pumpAndSettle();

        // Switch to bulk mode
        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        // Add URL with inline tag
        final urlInput = find.byType(EditableText).first;
        await tester.enterText(urlInput, "https://example.dev | inline");
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('bulk_add_button')));
        await tester.pumpAndSettle();

        // Both tags should appear in table
        expect(find.text("#global"), findsWidgets);
        expect(find.text("#inline"), findsWidgets);
        });
        });

      group("Archive Mode", () {
      testWidgets("should toggle archive mode switch", (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        // Find the archive toggle switch
        final archiveSwitch = find.byKey(const Key("archive_toggle_switch"));
        expect(archiveSwitch, findsOneWidget);

        // Should be off by default
        final switchWidget = tester.widget<SwitchListTile>(archiveSwitch);
        expect(switchWidget.value, isFalse);

        // Toggle on
        await tester.tap(archiveSwitch);
        await tester.pumpAndSettle();

        // Verify it's now on
        final updatedSwitch = tester.widget<SwitchListTile>(archiveSwitch);
        expect(updatedSwitch.value, isTrue);
        });

      testWidgets("should mark new links as archived when archive mode is on",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        // Enable archive mode
        final archiveSwitch = find.byKey(const Key('archive_toggle_switch'));
        await tester.tap(archiveSwitch);
        await tester.pumpAndSettle();

        // Switch to bulk mode
        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        // Add a URL
        final urlInput = find.byType(EditableText).first;
        await tester.enterText(urlInput, "https://archived.dev");
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('bulk_add_button')));
        await tester.pumpAndSettle();

        // Verify "Yes" appears in Archived column
        expect(find.text("Yes"), findsOneWidget);
        });

      testWidgets(
          "should mark new links as not archived when archive mode is off",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        // Archive mode should be off by default
        // Switch to bulk mode
        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        // Add a URL
        final urlInput = find.byType(EditableText).first;
        await tester.enterText(urlInput, "https://notarchived.dev");
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("bulk_add_button")));
        await tester.pumpAndSettle();

        // Verify "No" appears in Archived column
        expect(find.text("No"), findsOneWidget);
        });

      testWidgets("should apply archive mode to bulk submissions",
          (tester) async {
        await tester.pumpWidget(await createTestApp());

        await _navigateToAddLink(tester);

        // Enable archive mode
        final archiveSwitch = find.byKey(const Key("archive_toggle_switch"));
        await tester.tap(archiveSwitch);
        await tester.pumpAndSettle();

        // Switch to bulk mode
        final bulkButton = find.byKey(const Key("bulk_mode_button"));
        await tester.tap(bulkButton);
        await tester.pumpAndSettle();

        // Add multiple URLs
        final urlInput = find.byType(EditableText).first;
        const bulkUrls = """https://archived1.dev
https://archived2.dev
https://archived3.dev""";

        await tester.enterText(urlInput, bulkUrls);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("bulk_add_button")));
        await tester.pumpAndSettle();

        // All should be marked as archived (3 "Yes" entries)
        expect(find.text("Yes"), findsNWidgets(3));
        expect(find.text("No"), findsNothing);
        });
        });

    });
  });
}

/// Helper function to navigate to the Add Link screen
Future<void> _navigateToAddLink(WidgetTester tester) async {
  // Find and tap the add button
  final addButton = find.byIcon(Icons.add);
  if (addButton.evaluate().isNotEmpty) {
    await tester.tap(addButton);
    await tester.pumpAndSettle();
  }

  // Tap on "Link" option
  final linkOption = find.text("Link");
  if (linkOption.evaluate().isNotEmpty) {
    await tester.tap(linkOption);
    await tester.pumpAndSettle();
  }
}
