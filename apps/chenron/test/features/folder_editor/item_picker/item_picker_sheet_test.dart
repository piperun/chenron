import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/folder_editor/item_picker/item_picker_sheet.dart";

/// Simple item type for testing the generic picker.
class _TestItem {
  final String id;
  final String title;
  final String? subtitle;

  const _TestItem(this.id, this.title, {this.subtitle});
}

void main() {
  final testItems = [
    const _TestItem("1", "Alpha"),
    const _TestItem("2", "Beta", subtitle: "Second item"),
    const _TestItem("3", "Gamma"),
    const _TestItem("4", "Delta"),
  ];

  Widget buildPicker({
    Future<List<_TestItem>> Function()? loadItems,
    String headerTitle = "Pick Items",
    IconData headerIcon = Icons.list,
    IconData itemIcon = Icons.circle,
    String? createNewLabel,
    VoidCallback? onCreateNew,
    String emptyMessage = "No items available",
    String searchHint = "Search items...",
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showModalBottomSheet<List<_TestItem>>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ItemPickerSheet<_TestItem, _TestItem>(
                loadItems: loadItems ?? () async => testItems,
                itemId: (item) => item.id,
                itemTitle: (item) => item.title,
                itemSubtitle: (item) => item.subtitle,
                toResults: (selected) => selected,
                headerIcon: headerIcon,
                headerTitle: headerTitle,
                itemIcon: itemIcon,
                searchHint: searchHint,
                emptyIcon: Icons.inbox,
                emptyMessage: emptyMessage,
                createNewLabel: createNewLabel,
                onCreateNew: onCreateNew,
              ),
            ),
            child: const Text("Open"),
          ),
        ),
      ),
    );
  }

  group("ItemPickerSheet rendering", () {
    testWidgets("shows header with icon and title", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Pick Items"), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets("shows loading indicator while loading", (tester) async {
      final completer = Completer<List<_TestItem>>();
      await tester.pumpWidget(buildPicker(
        loadItems: () => completer.future,
      ));
      await tester.tap(find.text("Open"));
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete to avoid pending timer issues
      completer.complete(testItems);
      await tester.pumpAndSettle();
    });

    testWidgets("shows items after loading", (tester) async {
      // Taller viewport so all items fit inside the
      // DraggableScrollableSheet (initialChildSize: 0.6).
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Alpha"), findsOneWidget);
      expect(find.text("Beta"), findsOneWidget);
      expect(find.text("Gamma"), findsOneWidget);
      expect(find.text("Delta"), findsOneWidget);
    });

    testWidgets("shows subtitle when available", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Second item"), findsOneWidget);
    });

    testWidgets("shows search bar with hint", (tester) async {
      await tester.pumpWidget(buildPicker(searchHint: "Find items..."));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Find items..."), findsOneWidget);
    });

    testWidgets("shows Cancel and Add buttons", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Cancel"), findsOneWidget);
      expect(find.textContaining("Add"), findsOneWidget);
    });

    testWidgets("Add button is disabled with no selection", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Add (0)"), findsOneWidget);
      // FilledButton.icon creates a private subclass, so use
      // byWidgetPredicate to match via `is`.
      final addButton = tester.widget<FilledButton>(
        find.byWidgetPredicate(
            (w) => w is FilledButton && w.onPressed == null),
      );
      expect(addButton.onPressed, isNull);
    });

    testWidgets("shows empty state when no items", (tester) async {
      await tester.pumpWidget(buildPicker(
        loadItems: () async => [],
        emptyMessage: "Nothing here",
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Nothing here"), findsOneWidget);
    });

    testWidgets("shows Create New button when configured", (tester) async {
      await tester.pumpWidget(buildPicker(
        createNewLabel: "Create Link",
        onCreateNew: () {},
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Create New"), findsOneWidget);
    });

    testWidgets("hides Create New button when not configured", (tester) async {
      await tester.pumpWidget(buildPicker(
        createNewLabel: null,
        onCreateNew: null,
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Create New"), findsNothing);
    });
  });

  group("ItemPickerSheet search", () {
    testWidgets("filters items by search query", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Type in search
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, "alp");
      await tester.pumpAndSettle();

      expect(find.text("Alpha"), findsOneWidget);
      expect(find.text("Beta"), findsNothing);
      expect(find.text("Gamma"), findsNothing);
    });

    testWidgets("shows empty search message when no matches", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, "zzzzz");
      await tester.pumpAndSettle();

      expect(find.text("No items match your search"), findsOneWidget);
    });

    testWidgets("search is case-insensitive", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, "BETA");
      await tester.pumpAndSettle();

      expect(find.text("Beta"), findsOneWidget);
    });

    testWidgets("clearing search shows all items", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, "Alpha");
      await tester.pumpAndSettle();
      expect(find.text("Beta"), findsNothing);

      await tester.enterText(searchField, "");
      await tester.pumpAndSettle();

      expect(find.text("Alpha"), findsOneWidget);
      expect(find.text("Beta"), findsOneWidget);
    });
  });

  group("ItemPickerSheet selection", () {
    testWidgets("tapping item toggles selection", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Select Alpha
      await tester.tap(find.text("Alpha"));
      await tester.pumpAndSettle();

      expect(find.text("Add (1)"), findsOneWidget);
    });

    testWidgets("selecting multiple items updates count", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Alpha"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Beta"));
      await tester.pumpAndSettle();

      expect(find.text("Add (2)"), findsOneWidget);
    });

    testWidgets("deselecting item decreases count", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Select two
      await tester.tap(find.text("Alpha"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Beta"));
      await tester.pumpAndSettle();
      expect(find.text("Add (2)"), findsOneWidget);

      // Deselect one
      await tester.tap(find.text("Alpha"));
      await tester.pumpAndSettle();
      expect(find.text("Add (1)"), findsOneWidget);
    });

    testWidgets("Add button enables when items selected", (tester) async {
      await tester.pumpWidget(buildPicker());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Initially disabled
      expect(find.text("Add (0)"), findsOneWidget);
      final disabledFinder = find.byWidgetPredicate(
          (w) => w is FilledButton && w.onPressed == null);
      expect(disabledFinder, findsOneWidget);

      // Select item
      await tester.tap(find.text("Alpha"));
      await tester.pumpAndSettle();

      // Now enabled
      expect(find.text("Add (1)"), findsOneWidget);
      final enabledFinder = find.byWidgetPredicate(
          (w) => w is FilledButton && w.onPressed != null);
      expect(enabledFinder, findsOneWidget);
    });
  });

  group("ItemPickerSheet interaction", () {
    testWidgets("Create New button calls onCreateNew", (tester) async {
      var createCalled = false;
      await tester.pumpWidget(buildPicker(
        createNewLabel: "Create Link",
        onCreateNew: () => createCalled = true,
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Create New"));
      expect(createCalled, true);
    });
  });
}
