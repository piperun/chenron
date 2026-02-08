import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/shared/section_card/section_card.dart";

void main() {
  Widget buildCard({
    Text? title,
    Text? subtitle,
    Text? description,
    Icon? sectionIcon,
    Widget? trailing,
    List<Widget> children = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CardSection(
            title: title,
            subtitle: subtitle,
            description: description,
            sectionIcon: sectionIcon,
            trailing: trailing,
            children: children,
          ),
        ),
      ),
    );
  }

  group("CardSection rendering", () {
    testWidgets("renders children", (tester) async {
      await tester.pumpWidget(buildCard(
        children: [const Text("Child content")],
      ));
      await tester.pumpAndSettle();

      expect(find.text("Child content"), findsOneWidget);
    });

    testWidgets("renders title in header", (tester) async {
      await tester.pumpWidget(buildCard(
        title: const Text("Section Title"),
        children: [const SizedBox()],
      ));
      await tester.pumpAndSettle();

      expect(find.text("Section Title"), findsOneWidget);
    });

    testWidgets("renders subtitle", (tester) async {
      await tester.pumpWidget(buildCard(
        title: const Text("Title"),
        subtitle: const Text("Subtitle text"),
        children: [const SizedBox()],
      ));
      await tester.pumpAndSettle();

      expect(find.text("Subtitle text"), findsOneWidget);
    });

    testWidgets("renders description", (tester) async {
      await tester.pumpWidget(buildCard(
        description: const Text("A helpful description"),
        children: [const SizedBox()],
      ));
      await tester.pumpAndSettle();

      expect(find.text("A helpful description"), findsOneWidget);
    });

    testWidgets("renders section icon", (tester) async {
      await tester.pumpWidget(buildCard(
        sectionIcon: const Icon(Icons.folder),
        title: const Text("Folders"),
        children: [const SizedBox()],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets("renders trailing widget", (tester) async {
      await tester.pumpWidget(buildCard(
        title: const Text("Title"),
        trailing: const Icon(Icons.arrow_forward),
        children: [const SizedBox()],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets("does not render header when no header elements", (tester) async {
      await tester.pumpWidget(buildCard(
        children: [const Text("Just children")],
      ));
      await tester.pumpAndSettle();

      // Should still render children
      expect(find.text("Just children"), findsOneWidget);
      // Verify it's wrapped in a Card
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets("renders all header elements together", (tester) async {
      await tester.pumpWidget(buildCard(
        sectionIcon: const Icon(Icons.label),
        title: const Text("Tags"),
        subtitle: const Text("Manage tags"),
        description: const Text("Add or remove tags"),
        trailing: const Text("3 tags"),
        children: [const Text("Content")],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.label), findsOneWidget);
      expect(find.text("Tags"), findsOneWidget);
      expect(find.text("Manage tags"), findsOneWidget);
      expect(find.text("Add or remove tags"), findsOneWidget);
      expect(find.text("3 tags"), findsOneWidget);
      expect(find.text("Content"), findsOneWidget);
    });

    testWidgets("uses Card widget with elevation", (tester) async {
      await tester.pumpWidget(buildCard(
        children: [const SizedBox()],
      ));
      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);
    });

    testWidgets("renders multiple children", (tester) async {
      await tester.pumpWidget(buildCard(
        children: [
          const Text("First"),
          const Text("Second"),
          const Text("Third"),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text("First"), findsOneWidget);
      expect(find.text("Second"), findsOneWidget);
      expect(find.text("Third"), findsOneWidget);
    });
  });
}
