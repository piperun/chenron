import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/shared/bottom_sheet/sheet_action_bar.dart";

void main() {
  Widget buildBar({
    Widget? leading,
    List<Widget> trailing = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SheetActionBar(
          leading: leading,
          trailing: trailing,
        ),
      ),
    );
  }

  group("SheetActionBar rendering", () {
    testWidgets("renders empty bar without leading or trailing",
        (tester) async {
      await tester.pumpWidget(buildBar());
      await tester.pumpAndSettle();

      expect(find.byType(SheetActionBar), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets("renders leading widget", (tester) async {
      await tester.pumpWidget(buildBar(
        leading: const Text("Create New"),
      ));
      await tester.pumpAndSettle();

      expect(find.text("Create New"), findsOneWidget);
    });

    testWidgets("renders trailing widgets", (tester) async {
      await tester.pumpWidget(buildBar(
        trailing: [
          const Text("Cancel"),
          const Text("Save"),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text("Cancel"), findsOneWidget);
      expect(find.text("Save"), findsOneWidget);
    });

    testWidgets("renders both leading and trailing", (tester) async {
      await tester.pumpWidget(buildBar(
        leading: TextButton(
          onPressed: () {},
          child: const Text("New"),
        ),
        trailing: [
          TextButton(onPressed: () {}, child: const Text("Cancel")),
          FilledButton(onPressed: () {}, child: const Text("Done")),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text("New"), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
      expect(find.text("Done"), findsOneWidget);
    });

    testWidgets("has Spacer between leading and trailing", (tester) async {
      await tester.pumpWidget(buildBar(
        leading: const Text("Left"),
        trailing: [const Text("Right")],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Spacer), findsOneWidget);
    });

    testWidgets("hides leading when null", (tester) async {
      await tester.pumpWidget(buildBar(
        leading: null,
        trailing: [const Text("Only Trailing")],
      ));
      await tester.pumpAndSettle();

      expect(find.text("Only Trailing"), findsOneWidget);
    });

    testWidgets("has top border decoration", (tester) async {
      await tester.pumpWidget(buildBar());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SheetActionBar),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets("adds spacing between trailing widgets", (tester) async {
      await tester.pumpWidget(buildBar(
        trailing: [
          const Text("A"),
          const Text("B"),
          const Text("C"),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text("A"), findsOneWidget);
      expect(find.text("B"), findsOneWidget);
      expect(find.text("C"), findsOneWidget);
      // 2 SizedBox(width: 12) spacers between 3 trailing items
      final spacers = tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .where((s) => s.width == 12);
      expect(spacers.length, 2);
    });
  });

  group("SheetActionBar interaction", () {
    testWidgets("trailing buttons are tappable", (tester) async {
      var cancelTapped = false;
      var saveTapped = false;
      await tester.pumpWidget(buildBar(
        trailing: [
          TextButton(
            onPressed: () => cancelTapped = true,
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => saveTapped = true,
            child: const Text("Save"),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Cancel"));
      expect(cancelTapped, true);

      await tester.tap(find.text("Save"));
      expect(saveTapped, true);
    });
  });
}
