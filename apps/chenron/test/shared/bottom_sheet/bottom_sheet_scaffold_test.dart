import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/shared/bottom_sheet/bottom_sheet_scaffold.dart";

void main() {
  Widget buildScaffold({
    IconData headerIcon = Icons.edit,
    String title = "Test Sheet",
    VoidCallback? onClose,
    SheetBodyBuilder? bodyBuilder,
    Widget? actions,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => BottomSheetScaffold(
                headerIcon: headerIcon,
                title: title,
                onClose: onClose ?? () => Navigator.pop(context),
                bodyBuilder: bodyBuilder ??
                    (scrollController) => ListView(
                          controller: scrollController,
                          children: const [Text("Body content")],
                        ),
                actions: actions ?? const SizedBox(height: 48),
              ),
            ),
            child: const Text("Open"),
          ),
        ),
      ),
    );
  }

  group("BottomSheetScaffold rendering", () {
    testWidgets("shows header icon and title", (tester) async {
      await tester.pumpWidget(buildScaffold());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text("Test Sheet"), findsOneWidget);
    });

    testWidgets("shows custom header icon", (tester) async {
      await tester.pumpWidget(buildScaffold(headerIcon: Icons.link));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets("shows close button", (tester) async {
      await tester.pumpWidget(buildScaffold());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets("shows body content", (tester) async {
      await tester.pumpWidget(buildScaffold());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Body content"), findsOneWidget);
    });

    testWidgets("shows actions widget", (tester) async {
      await tester.pumpWidget(buildScaffold(
        actions: const Padding(
          padding: EdgeInsets.all(16),
          child: Text("Action Bar"),
        ),
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.text("Action Bar"), findsOneWidget);
    });

    testWidgets("shows divider between header and body", (tester) async {
      await tester.pumpWidget(buildScaffold());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets("uses DraggableScrollableSheet", (tester) async {
      await tester.pumpWidget(buildScaffold());
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets("passes ScrollController to bodyBuilder", (tester) async {
      ScrollController? receivedController;
      await tester.pumpWidget(buildScaffold(
        bodyBuilder: (scrollController) {
          receivedController = scrollController;
          return ListView(
            controller: scrollController,
            children: const [Text("Scrollable")],
          );
        },
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      expect(receivedController, isNotNull);
      expect(find.text("Scrollable"), findsOneWidget);
    });
  });

  group("BottomSheetScaffold interaction", () {
    testWidgets("close button calls onClose", (tester) async {
      var closed = false;
      await tester.pumpWidget(buildScaffold(
        onClose: () {
          closed = true;
        },
      ));
      await tester.tap(find.text("Open"));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closed, true);
    });
  });
}
