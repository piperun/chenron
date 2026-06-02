import "package:chenron/components/tags/tag_body.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("tag chips use the theme's secondaryContainer, not a hardcoded "
      "color", (tester) async {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.dark,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: const Scaffold(body: TagBody(tags: {"alpha"})),
      ),
    );

    final chip = tester.widget<Chip>(find.byType(Chip));
    expect(chip.backgroundColor, scheme.secondaryContainer);
    expect(chip.backgroundColor, isNot(Colors.blue.shade100));
  });

  testWidgets("renders one chip per tag", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TagBody(tags: {"a", "b", "c"})),
      ),
    );

    expect(find.byType(Chip), findsNWidgets(3));
  });
}
