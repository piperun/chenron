import "package:chenron/components/tables/renderers/shared/actions_renderer.dart";
import "package:chenron/components/tables/renderers/shared/folders_renderer.dart";
import "package:chenron/components/tables/renderers/shared/tags_renderer.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

Widget host(Widget child) => MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => child,
        ),
      ),
    );

void main() {
  group("TableTagsCell", () {
    testWidgets("renders each tag with a # prefix", (tester) async {
      await tester.pumpWidget(host(Builder(builder: (context) {
        return TableTagsCell(tags: const ["dart", "flutter"], theme: Theme.of(context));
      })));

      expect(find.text("#dart"), findsOneWidget);
      expect(find.text("#flutter"), findsOneWidget);
    });

    testWidgets("renders a dash placeholder when empty", (tester) async {
      await tester.pumpWidget(host(Builder(builder: (context) {
        return TableTagsCell(tags: const [], theme: Theme.of(context));
      })));

      expect(find.text("-"), findsOneWidget);
    });
  });

  group("TableFoldersCell", () {
    testWidgets("renders mapped folder names", (tester) async {
      await tester.pumpWidget(host(Builder(builder: (context) {
        return TableFoldersCell(
          folderIds: const ["f1"],
          folderNames: const {"f1": "Inbox"},
          theme: Theme.of(context),
        );
      })));

      expect(find.text("Inbox"), findsOneWidget);
    });

    testWidgets("falls back to the id when no name is mapped", (tester) async {
      await tester.pumpWidget(host(Builder(builder: (context) {
        return TableFoldersCell(
          folderIds: const ["unknown"],
          folderNames: const {},
          theme: Theme.of(context),
        );
      })));

      expect(find.text("unknown"), findsOneWidget);
    });

    testWidgets("renders the default label when empty", (tester) async {
      await tester.pumpWidget(host(Builder(builder: (context) {
        return TableFoldersCell(
          folderIds: const [],
          folderNames: const {},
          theme: Theme.of(context),
        );
      })));

      expect(find.text("default"), findsOneWidget);
    });
  });

  group("TableActionsCell", () {
    testWidgets("shows edit and delete and fires their callbacks",
        (tester) async {
      Key? edited;
      Key? deleted;
      const itemKey = ValueKey<String>("row-1");

      await tester.pumpWidget(host(Builder(builder: (context) {
        return TableActionsCell<String>(
          item: "payload",
          itemKey: itemKey,
          theme: Theme.of(context),
          onEdit: (k) => edited = k,
          onDelete: (k) => deleted = k,
        );
      })));

      await tester.tap(find.byIcon(Icons.edit));
      await tester.tap(find.byIcon(Icons.delete));

      expect(edited, itemKey);
      expect(deleted, itemKey);
    });

    testWidgets("omits buttons whose callbacks are null", (tester) async {
      await tester.pumpWidget(host(Builder(builder: (context) {
        return TableActionsCell<String>(
          item: "payload",
          itemKey: const ValueKey("row"),
          theme: Theme.of(context),
        );
      })));

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets("renders custom actions with the item payload", (tester) async {
      String? pressedItem;

      await tester.pumpWidget(host(Builder(builder: (context) {
        return TableActionsCell<String>(
          item: "payload",
          itemKey: const ValueKey("row"),
          theme: Theme.of(context),
          customActions: [
            ActionButton<String>(
              icon: Icons.star,
              tooltip: "Star",
              onPressed: (item) => pressedItem = item,
            ),
          ],
        );
      })));

      await tester.tap(find.byIcon(Icons.star));
      expect(pressedItem, "payload");
    });
  });
}
