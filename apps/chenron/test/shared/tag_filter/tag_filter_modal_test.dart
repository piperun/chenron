import "dart:async";
import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/folder_viewer/ui/components/tag_filter_modal.dart";

void main() {
  group("TagFilterModal", () {
    late List<Tag> mockTags;

    setUp(() {
      mockTags = [
        Tag(id: "1", name: "flutter", createdAt: DateTime.now()),
        Tag(id: "2", name: "dart", createdAt: DateTime.now()),
        Tag(id: "3", name: "mobile", createdAt: DateTime.now()),
        Tag(id: "4", name: "desktop", createdAt: DateTime.now()),
        Tag(id: "5", name: "web", createdAt: DateTime.now()),
      ];
    });

    Widget buildModal({
      Set<String>? initialIncluded,
      Set<String>? initialExcluded,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  unawaited(TagFilterModal.show(
                    context: context,
                    availableTags: mockTags,
                    initialIncludedTags: initialIncluded ?? {},
                    initialExcludedTags: initialExcluded ?? {},
                  ));
                },
                child: const Text("Open Modal"),
              );
            },
          ),
        ),
      );
    }

    testWidgets("opens and displays tag filter modal", (tester) async {
      await tester.pumpWidget(buildModal());
      await tester.tap(find.text("Open Modal"));
      await tester.pumpAndSettle();

      expect(find.text("Tag Filters"), findsOneWidget);
      expect(find.text("Active Filters"), findsOneWidget);
      expect(find.text("Available Tags"), findsOneWidget);
    });

    testWidgets("displays initial included and excluded tags", (tester) async {
      await tester.pumpWidget(buildModal(
        initialIncluded: {"flutter", "dart"},
        initialExcluded: {"mobile"},
      ));
      await tester.tap(find.text("Open Modal"));
      await tester.pumpAndSettle();

      // Should show active filters count
      expect(find.text("3 active filters"), findsOneWidget);
    });

    testWidgets("switches between tabs", (tester) async {
      await tester.pumpWidget(buildModal());
      await tester.tap(find.text("Open Modal"));
      await tester.pumpAndSettle();

      // Start on Active Filters
      expect(find.text("No active filters"), findsOneWidget);

      // Switch to Available Tags
      await tester.tap(find.text("Available Tags"));
      await tester.pumpAndSettle();

      // Should see tags
      expect(find.text("flutter"), findsOneWidget);
      expect(find.text("dart"), findsOneWidget);
    });

    group("Normal Mode", () {
      testWidgets("adds tag to included via + button", (tester) async {
        await tester.pumpWidget(buildModal());
        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Available Tags"));
        await tester.pumpAndSettle();

        // Find and tap the include button for 'flutter'
        final includeButton = find.descendant(
          of: find.ancestor(
            of: find.text("flutter"),
            matching: find.byType(Container),
          ),
          matching: find.byTooltip("Include"),
        );
        await tester.tap(includeButton.first);
        await tester.pumpAndSettle();

        // Check Active Filters
        await tester.tap(find.text("Active Filters"));
        await tester.pumpAndSettle();

        expect(find.text("1 active filter"), findsOneWidget);
        expect(find.text("flutter"), findsOneWidget);
      });

      testWidgets("adds tag to excluded via - button", (tester) async {
        await tester.pumpWidget(buildModal());
        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Available Tags"));
        await tester.pumpAndSettle();

        // Find and tap the exclude button for 'dart'
        final excludeButton = find.descendant(
          of: find.ancestor(
            of: find.text("dart"),
            matching: find.byType(Container),
          ),
          matching: find.byTooltip("Exclude"),
        );
        await tester.tap(excludeButton.first);
        await tester.pumpAndSettle();

        // Check Active Filters
        await tester.tap(find.text("Active Filters"));
        await tester.pumpAndSettle();

        expect(find.text("1 active filter"), findsOneWidget);
        expect(find.text("dart"), findsOneWidget);
      });

      testWidgets("removes tag from filter", (tester) async {
        await tester.pumpWidget(buildModal(initialIncluded: {"flutter"}));
        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Available Tags"));
        await tester.pumpAndSettle();

        // Find and tap the remove button
        final removeButton = find.descendant(
          of: find.ancestor(
            of: find.text("flutter"),
            matching: find.byType(Container),
          ),
          matching: find.byTooltip("Remove filter"),
        );
        await tester.tap(removeButton.first);
        await tester.pumpAndSettle();

        // Check Active Filters
        await tester.tap(find.text("Active Filters"));
        await tester.pumpAndSettle();

        expect(find.text("No active filters"), findsOneWidget);
      });

      testWidgets("searches tags in available tab", (tester) async {
        await tester.pumpWidget(buildModal());
        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Available Tags"));
        await tester.pumpAndSettle();

        // Type in search (second TextField is in Available Tags tab)
        final textFields = find.byType(TextField);
        await tester.enterText(
          textFields.last,
          "flutter",
        );
        await tester.pumpAndSettle();

        // Should see fewer tags
        expect(find.text("dart"), findsNothing);
        expect(find.text("mobile"), findsNothing);
      });
    });

    group("Active Filters Tab", () {
      testWidgets("collapses and expands included section", (tester) async {
        await tester
            .pumpWidget(buildModal(initialIncluded: {"flutter", "dart"}));
        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        // Should see included tags
        expect(find.text("flutter"), findsOneWidget);
        expect(find.text("dart"), findsOneWidget);

        // Collapse
        await tester.tap(find.byTooltip("Collapse").first);
        await tester.pumpAndSettle();

        // Tags should be hidden
        expect(find.text("flutter"), findsNothing);
        expect(find.text("dart"), findsNothing);
        expect(find.text("Included Tags (2)"), findsOneWidget);

        // Expand
        await tester.tap(find.byTooltip("Expand").first);
        await tester.pumpAndSettle();

        // Tags should be visible again
        expect(find.text("flutter"), findsOneWidget);
        expect(find.text("dart"), findsOneWidget);
      });

      testWidgets("searches active tags", (tester) async {
        await tester.pumpWidget(buildModal(
          initialIncluded: {"flutter", "dart", "mobile"},
          initialExcluded: {"desktop", "web"},
        ));
        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        // Type in search (Active Filters tab search)
        final textFields = find.byType(TextField);
        await tester.enterText(
          textFields.first,
          "flutter",
        );
        await tester.pumpAndSettle();

        // Should filter tags
        expect(find.text("dart"), findsNothing);
        expect(find.text("Included Tags (1)"), findsOneWidget);
      });

      testWidgets("clears all included tags", (tester) async {
        await tester
            .pumpWidget(buildModal(initialIncluded: {"flutter", "dart"}));
        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        // Find and tap clear button
        final clearButtons = find.text("Clear");
        await tester.tap(clearButtons.first);
        await tester.pumpAndSettle();

        expect(find.text("No active filters"), findsOneWidget);
      });

      testWidgets("removes individual tag from chip", (tester) async {
        await tester
            .pumpWidget(buildModal(initialIncluded: {"flutter", "dart"}));
        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        // Find delete icon on chip
        final chips = find.byType(Chip);
        expect(chips, findsNWidgets(2));

        // Tap delete on first chip
        final deleteIcon = find.descendant(
          of: chips.first,
          matching: find.byIcon(Icons.close),
        );
        await tester.tap(deleteIcon);
        await tester.pumpAndSettle();

        // Should have one less
        expect(find.text("1 active filter"), findsOneWidget);
      });
    });

    group("Apply and Close", () {
      testWidgets("applies filters and returns result", (tester) async {
        await tester.pumpWidget(buildModal());

        ({Set<String> included, Set<String> excluded})? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      result = await TagFilterModal.show(
                        context: context,
                        availableTags: mockTags,
                        initialIncludedTags: {},
                        initialExcludedTags: {},
                      );
                    },
                    child: const Text("Open Modal"),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Available Tags"));
        await tester.pumpAndSettle();

        // Add some filters
        final includeButton = find.byTooltip("Include").first;
        await tester.tap(includeButton);
        await tester.pumpAndSettle();

        // Apply
        await tester.tap(find.text("Apply Filters"));
        await tester.pumpAndSettle();

        expect(result, isNotNull);
        expect(result!.included.length, 1);
        expect(result!.excluded.length, 0);
      });

      testWidgets("closes modal without applying", (tester) async {
        await tester.pumpWidget(buildModal(initialIncluded: {"flutter"}));
        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        // Close button (in header)
        await tester.tap(find.byTooltip("Close"));
        await tester.pumpAndSettle();

        // Modal should be closed
        expect(find.text("Tag Filters"), findsNothing);
      });
    });

    group("Edge Cases", () {
      testWidgets("handles empty tag list", (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      unawaited(TagFilterModal.show(
                        context: context,
                        availableTags: [],
                        initialIncludedTags: {},
                        initialExcludedTags: {},
                      ));
                    },
                    child: const Text("Open Modal"),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Available Tags"));
        await tester.pumpAndSettle();

        expect(find.text("No tags available"), findsOneWidget);
      });

      testWidgets("handles search with no results", (tester) async {
        await tester.pumpWidget(buildModal());
        await tester.tap(find.text("Open Modal"));
        await tester.pumpAndSettle();

        await tester.tap(find.text("Available Tags"));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).first,
          "nonexistent",
        );
        await tester.pumpAndSettle();

        expect(find.text("No matching tags"), findsOneWidget);
      });
    });
  });
}
