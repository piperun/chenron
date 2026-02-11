import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/shared/empty_state/empty_state.dart";

void main() {
  Widget buildEmptyState({
    IconData icon = Icons.inbox,
    String message = "No items",
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: EmptyState(
          icon: icon,
          message: message,
          subtitle: subtitle,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }

  group("EmptyState rendering", () {
    testWidgets("shows icon and message", (tester) async {
      await tester.pumpWidget(buildEmptyState());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text("No items"), findsOneWidget);
    });

    testWidgets("shows custom icon", (tester) async {
      await tester.pumpWidget(buildEmptyState(icon: Icons.search_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets("shows subtitle when provided", (tester) async {
      await tester.pumpWidget(buildEmptyState(
        subtitle: "Try adding something",
      ));
      await tester.pumpAndSettle();

      expect(find.text("Try adding something"), findsOneWidget);
    });

    testWidgets("hides subtitle when null", (tester) async {
      await tester.pumpWidget(buildEmptyState(subtitle: null));
      await tester.pumpAndSettle();

      // Only the message text should be present
      expect(find.text("No items"), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets("shows action button when both label and callback provided",
        (tester) async {
      await tester.pumpWidget(buildEmptyState(
        actionLabel: "Create New",
        onAction: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.text("Create New"), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets("hides action button when actionLabel is null",
        (tester) async {
      await tester.pumpWidget(buildEmptyState(
        actionLabel: null,
        onAction: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets("hides action button when onAction is null", (tester) async {
      await tester.pumpWidget(buildEmptyState(
        actionLabel: "Create New",
        onAction: null,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets("wraps content in SingleChildScrollView", (tester) async {
      await tester.pumpWidget(buildEmptyState());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets("centers content", (tester) async {
      await tester.pumpWidget(buildEmptyState());
      await tester.pumpAndSettle();

      // EmptyState's root is a Center wrapping SingleChildScrollView.
      expect(
        find.ancestor(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
    });

    testWidgets("icon is wrapped in circular container", (tester) async {
      await tester.pumpWidget(buildEmptyState());
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.inbox));
      expect(icon.size, 48);
    });

    testWidgets("shows all elements together", (tester) async {
      await tester.pumpWidget(buildEmptyState(
        icon: Icons.folder_open,
        message: "No folders found",
        subtitle: "Create a folder to get started",
        actionLabel: "New Folder",
        onAction: () {},
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
      expect(find.text("No folders found"), findsOneWidget);
      expect(find.text("Create a folder to get started"), findsOneWidget);
      expect(find.text("New Folder"), findsOneWidget);
    });
  });

  group("EmptyState interaction", () {
    testWidgets("action button calls onAction", (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildEmptyState(
        actionLabel: "Add Item",
        onAction: () => tapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Add Item"));
      expect(tapped, true);
    });
  });
}
