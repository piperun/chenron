import "package:database/main.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/create/link/widgets/link_edit_bottom_sheet.dart";
import "package:chenron/features/create/link/models/link_entry.dart";

void main() {
  LinkEntry makeEntry({
    String url = "https://example.com",
    List<String> tags = const [],
    List<String> folderIds = const ["folder-1"],
    bool isArchived = false,
  }) {
    return LinkEntry(
      key: UniqueKey(),
      url: url,
      tags: tags,
      folderIds: folderIds,
      isArchived: isArchived,
    );
  }

  Folder makeFolder(String id, String title) {
    return Folder(
      id: id,
      title: title,
      description: "",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Widget buildSheet({
    LinkEntry? entry,
    ValueChanged<LinkEntry>? onSave,
    VoidCallback? onCancel,
    List<Folder>? availableFolders,
  }) {
    final testEntry = entry ?? makeEntry();
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => LinkEditBottomSheet(
                entry: testEntry,
                onSave: onSave ?? (_) {},
                onCancel: onCancel ?? () => Navigator.pop(context),
                availableFolders: availableFolders,
              ),
            ),
            child: const Text("Open"),
          ),
        ),
      ),
    );
  }

  group("LinkEditBottomSheet rendering", () {
    testWidgets("shows Edit Link header", (tester) async {
      await tester.pumpWidget(buildSheet());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Edit Link"), findsOneWidget);
    });

    testWidgets("shows URL field with entry URL", (tester) async {
      await tester.pumpWidget(buildSheet(
        entry: makeEntry(url: "https://flutter.dev"),
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("https://flutter.dev"), findsOneWidget);
    });

    testWidgets("shows Tags section", (tester) async {
      await tester.pumpWidget(buildSheet());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Tags"), findsOneWidget);
      expect(find.text("Add tag"), findsOneWidget);
    });

    testWidgets("shows existing tags as chips", (tester) async {
      await tester.pumpWidget(buildSheet(
        entry: makeEntry(tags: ["flutter", "dart"]),
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("#flutter"), findsOneWidget);
      expect(find.text("#dart"), findsOneWidget);
    });

    testWidgets("shows Archive toggle", (tester) async {
      await tester.pumpWidget(buildSheet());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Archive"), findsOneWidget);
    });

    testWidgets("shows Cancel and Update buttons", (tester) async {
      await tester.pumpWidget(buildSheet());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Cancel"), findsWidgets); // header close + action
      expect(find.text("Update"), findsOneWidget);
    });

    testWidgets("shows Folders section when availableFolders provided",
        (tester) async {
      await tester.pumpWidget(buildSheet(
        availableFolders: [
          makeFolder("f1", "Work"),
          makeFolder("f2", "Personal"),
        ],
        entry: makeEntry(folderIds: ["f1"]),
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Folders"), findsOneWidget);
      expect(find.text("Work"), findsOneWidget);
      expect(find.text("Personal"), findsOneWidget);
    });

    testWidgets("hides Folders section when no availableFolders",
        (tester) async {
      await tester.pumpWidget(buildSheet(availableFolders: null));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Folders"), findsNothing);
    });
  });

  group("LinkEditBottomSheet interaction", () {
    testWidgets("calls onSave with updated URL", (tester) async {
      LinkEntry? savedEntry;
      await tester.pumpWidget(buildSheet(
        entry: makeEntry(url: "https://old.com"),
        onSave: (entry) => savedEntry = entry,
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Clear and type new URL
      final urlField = find.byType(TextField).first;
      await tester.enterText(urlField, "https://new.com");
      await tester.pumpAndSettle();

      // Tap Update
      await tester.tap(find.text("Update"));
      await tester.pumpAndSettle();

      expect(savedEntry, isNotNull);
      expect(savedEntry!.url, "https://new.com");
    });

    testWidgets("adds tag via Add button", (tester) async {
      await tester.pumpWidget(buildSheet(
        entry: makeEntry(tags: []),
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Scroll the tag input into view inside the DraggableScrollableSheet
      final tagInput = find.byType(TextField).at(1);
      await tester.ensureVisible(tagInput);
      await tester.pumpAndSettle();
      await tester.enterText(tagInput, "newtag");
      await tester.pumpAndSettle();

      // Scroll to and tap the "Add" button
      final addButton = find.text("Add");
      await tester.ensureVisible(addButton);
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text("#newtag"), findsOneWidget);
    });

    testWidgets("removes tag when chip delete tapped", (tester) async {
      await tester.pumpWidget(buildSheet(
        entry: makeEntry(tags: ["flutter", "dart"]),
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Scroll the chip into view and tap its delete button
      final chip = find.widgetWithText(InputChip, "#flutter");
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();

      final deleteIcon = find.descendant(
        of: chip,
        matching: find.byTooltip("Delete"),
      );
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      expect(find.text("#flutter"), findsNothing);
      expect(find.text("#dart"), findsOneWidget);
    });

    testWidgets("toggles archive", (tester) async {
      LinkEntry? savedEntry;
      await tester.pumpWidget(buildSheet(
        entry: makeEntry(isArchived: false),
        onSave: (entry) => savedEntry = entry,
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Scroll archive toggle into view inside the DraggableScrollableSheet
      final archiveToggle = find.byType(SwitchListTile);
      await tester.ensureVisible(archiveToggle);
      await tester.pumpAndSettle();

      // Toggle archive via the list tile
      await tester.tap(archiveToggle);
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text("Update"));
      await tester.pumpAndSettle();

      expect(savedEntry!.isArchived, true);
    });

    testWidgets("shows snackbar for empty URL on save", (tester) async {
      await tester.pumpWidget(buildSheet(
        entry: makeEntry(url: "https://example.com"),
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Clear the URL
      final urlField = find.byType(TextField).first;
      await tester.enterText(urlField, "");
      await tester.pumpAndSettle();

      // Tap Update
      await tester.tap(find.text("Update"));
      await tester.pumpAndSettle();

      expect(find.text("URL cannot be empty"), findsOneWidget);
    });

    testWidgets("calls onCancel when close icon tapped", (tester) async {
      bool wasCancelled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => LinkEditBottomSheet(
                  entry: makeEntry(),
                  onSave: (_) {},
                  onCancel: () {
                    wasCancelled = true;
                    Navigator.pop(context);
                  },
                ),
              ),
              child: const Text("Open"),
            ),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Tap the close icon in header
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(wasCancelled, true);
    });

    testWidgets("shows snackbar for duplicate tag", (tester) async {
      await tester.pumpWidget(buildSheet(
        entry: makeEntry(tags: ["existing"]),
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      final tagInput = find.byType(TextField).at(1);
      await tester.enterText(tagInput, "existing");
      await tester.pumpAndSettle();

      final addButtons = find.text("Add");
      await tester.tap(addButtons.last);
      await tester.pumpAndSettle();

      expect(find.textContaining("already exists"), findsOneWidget);
    });
  });

  group("LinkEditBottomSheet lifecycle", () {
    testWidgets("disposes controllers without errors", (tester) async {
      await tester.pumpWidget(buildSheet());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Close via cancel
      await tester.tap(find.text("Cancel").first);
      await tester.pumpAndSettle();
    });
  });
}
