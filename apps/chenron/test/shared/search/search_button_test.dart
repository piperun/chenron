import "package:chenron/shared/search/search_button.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("search icon renders faded (alpha ~0.7), not full opacity",
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SearchButton()),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.search));

    expect(icon.color, isNotNull);
    // The faded color must actually be applied — a cascade would discard the
    // withValues() result and leave the icon at full opacity.
    expect(icon.color!.a, lessThan(1.0));
    expect(icon.color!.a, closeTo(0.7, 0.01));
  });
}
