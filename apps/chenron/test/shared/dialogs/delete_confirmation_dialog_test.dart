import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";

void main() {
  Widget buildApp({required Widget child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  List<DeletableItem> singleItem() => [
        const DeletableItem(id: "1", title: "Test Item"),
      ];

  List<DeletableItem> multipleItems() => [
        const DeletableItem(id: "1", title: "Item One"),
        const DeletableItem(id: "2", title: "Item Two", subtitle: "URL Two"),
        const DeletableItem(id: "3", title: "Item Three"),
      ];

  List<DeletableItem> items(int count) => List<DeletableItem>.generate(
        count,
        (index) => DeletableItem(
          id: "$index",
          title: "Item $index",
        ),
      );

  group("DeletableItem", () {
    test("stores id and title", () {
      const item = DeletableItem(id: "abc", title: "My Item");
      expect(item.id, "abc");
      expect(item.title, "My Item");
      expect(item.subtitle, isNull);
    });

    test("stores optional subtitle", () {
      const item =
          DeletableItem(id: "abc", title: "My Item", subtitle: "Details");
      expect(item.subtitle, "Details");
    });
  });

  group("DeleteConfirmationDialog rendering", () {
    testWidgets("shows single item title", (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: singleItem()),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Delete Item?"), findsOneWidget);
      expect(find.text("Test Item"), findsOneWidget);
    });

    testWidgets("shows multiple items count in title", (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: multipleItems()),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Delete 3 Items?"), findsOneWidget);
      expect(find.text("Item One"), findsOneWidget);
      expect(find.text("Item Two"), findsOneWidget);
      expect(find.text("Item Three"), findsOneWidget);
    });

    testWidgets("shows subtitle when provided", (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: multipleItems()),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("URL Two"), findsOneWidget);
    });

    testWidgets("shows custom message when provided", (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(
                items: singleItem(),
                customMessage: "Custom warning message!",
              ),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Custom warning message!"), findsOneWidget);
    });

    testWidgets("shows default warning message", (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: singleItem()),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.textContaining("cannot be undone"), findsOneWidget);
    });

    testWidgets("shows DELETE confirmation field for four items",
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: items(4)),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Type DELETE to confirm:"), findsOneWidget);
    });

    testWidgets("count-only deletion shows count and no materialized item list",
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(
                itemCount: 100000,
              ),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Delete 100000 Items?"), findsOneWidget);
      expect(find.textContaining("cannot be undone"), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      expect(find.text("Type DELETE to confirm:"), findsOneWidget);
      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Delete All"),
      );
      expect(deleteButton.onPressed, isNull);

      await tester.enterText(find.byType(TextField), "DELETE");
      await tester.pumpAndSettle();
      final enabledDeleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Delete All"),
      );
      expect(enabledDeleteButton.onPressed, isNotNull);
    });

    test("items and itemCount are mutually exclusive", () {
      expect(
        () => DeleteConfirmationDialog(
          items: singleItem(),
          itemCount: 1,
        ),
        throwsArgumentError,
      );
    });

    testWidgets("list mode requires no typed confirmation at three",
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: DeleteConfirmationDialog(items: items(3)),
      ));

      expect(find.byType(TextField), findsNothing);
      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Delete All"),
      );
      expect(deleteButton.onPressed, isNotNull);
    });

    testWidgets("list mode requires typed confirmation at four",
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: DeleteConfirmationDialog(items: items(4)),
      ));

      expect(find.byType(TextField), findsOneWidget);
      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Delete All"),
      );
      expect(deleteButton.onPressed, isNull);
    });

    testWidgets("count-only mode requires no typed confirmation at three",
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: DeleteConfirmationDialog(itemCount: 3),
      ));

      expect(find.byType(TextField), findsNothing);
      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Delete All"),
      );
      expect(deleteButton.onPressed, isNotNull);
    });

    testWidgets("count-only mode requires typed confirmation at four",
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: DeleteConfirmationDialog(itemCount: 4),
      ));

      expect(find.byType(TextField), findsOneWidget);
      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Delete All"),
      );
      expect(deleteButton.onPressed, isNull);
    });
  });

  group("DeleteConfirmationDialog interaction", () {
    testWidgets("delete button disabled initially for four items",
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: items(4)),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Bulk delete should be disabled until the typed confirmation matches.
      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Delete All"),
      );
      expect(deleteButton.onPressed, isNull);
    });

    testWidgets("delete button enabled after typing DELETE for four items",
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: items(4)),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Type "DELETE" in the confirmation field
      final confirmField = find.byType(TextField);
      await tester.enterText(confirmField, "DELETE");
      await tester.pumpAndSettle();

      // Delete button should now be enabled
      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Delete All"),
      );
      expect(deleteButton.onPressed, isNotNull);
    });

    testWidgets("delete button stays disabled for partial input",
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: items(4)),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      final confirmField = find.byType(TextField);
      await tester.enterText(confirmField, "DEL");
      await tester.pumpAndSettle();

      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Delete All"),
      );
      expect(deleteButton.onPressed, isNull);
    });

    testWidgets("cancel returns false", (tester) async {
      bool? result;
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (_) => DeleteConfirmationDialog(items: singleItem()),
              );
            },
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets("confirm returns true after typing DELETE for four items",
        (tester) async {
      bool? result;
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (_) => DeleteConfirmationDialog(items: items(4)),
              );
            },
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // Type DELETE
      await tester.enterText(find.byType(TextField), "DELETE");
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.widgetWithText(FilledButton, "Delete All"));
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets("shows Delete All for multiple items", (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: multipleItems()),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Delete All"), findsOneWidget);
    });

    testWidgets("shows check icon when DELETE typed for four items",
        (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: items(4)),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      // No check icon initially
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // Type DELETE
      await tester.enterText(find.byType(TextField), "DELETE");
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group("showDeleteConfirmationDialog helper", () {
    testWidgets("returns false when cancelled", (tester) async {
      bool? result;
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDeleteConfirmationDialog(
                context: context,
                items: singleItem(),
              );
            },
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      expect(result, false);
    });
  });

  group("DeleteConfirmationDialog lifecycle", () {
    testWidgets("disposes controller on close", (tester) async {
      await tester.pumpWidget(buildApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => DeleteConfirmationDialog(items: singleItem()),
            ),
            child: const Text("Open"),
          ),
        ),
      ));

      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      // No errors = disposal worked
    });
  });
}
