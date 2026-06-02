import "package:chenron/components/TextBase/expandable_field.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  Widget host(String description, {double width = 300}) => MaterialApp(
        home: Scaffold(
          // Scrollable so a fully-expanded long description can lay out
          // without overflowing the finite test viewport.
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: width,
                child: ExpandableField(description: description),
              ),
            ),
          ),
        ),
      );

  testWidgets("renders short (non-overflowing) text without throwing",
      (tester) async {
    await tester.pumpWidget(host("short"));
    // AnimatedCrossFade keeps both children mounted, so the text appears twice.
    expect(find.text("short"), findsWidgets);
    // A short string never exceeds two lines, so no expand toggle is shown.
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets("renders long (overflowing) text with an expand toggle",
      (tester) async {
    final long = "word " * 200;
    await tester.pumpWidget(host(long, width: 120));
    await tester.pumpAndSettle();
    // Overflowing text shows the keyboard_arrow_down expand affordance.
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
  });

  testWidgets("expand toggle flips the arrow direction", (tester) async {
    final long = "word " * 200;
    await tester.pumpWidget(host(long, width: 120));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
  });
}
