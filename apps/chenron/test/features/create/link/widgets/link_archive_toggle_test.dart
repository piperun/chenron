import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/create/link/widgets/link_archive_toggle.dart";

void main() {
  Widget buildToggle({
    bool value = false,
    ValueChanged<bool>? onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: LinkArchiveToggle(
          value: value,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    );
  }

  group("LinkArchiveToggle rendering", () {
    testWidgets("displays title text", (tester) async {
      await tester.pumpWidget(buildToggle());
      await tester.pumpAndSettle();

      expect(find.text("Archive new links"), findsOneWidget);
    });

    testWidgets("displays subtitle text", (tester) async {
      await tester.pumpWidget(buildToggle());
      await tester.pumpAndSettle();

      expect(find.text("Automatically archive links when added"),
          findsOneWidget);
    });

    testWidgets("switch is off when value is false", (tester) async {
      await tester.pumpWidget(buildToggle(value: false));
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, false);
    });

    testWidgets("switch is on when value is true", (tester) async {
      await tester.pumpWidget(buildToggle(value: true));
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);
    });

    testWidgets("is wrapped in a Card", (tester) async {
      await tester.pumpWidget(buildToggle());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });
  });

  group("LinkArchiveToggle interaction", () {
    testWidgets("calls onChanged when tapped", (tester) async {
      bool? newValue;
      await tester.pumpWidget(buildToggle(
        value: false,
        onChanged: (value) => newValue = value,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(newValue, true);
    });

    testWidgets("calls onChanged with false when toggling off",
        (tester) async {
      bool? newValue;
      await tester.pumpWidget(buildToggle(
        value: true,
        onChanged: (value) => newValue = value,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(newValue, false);
    });

    testWidgets("has correct key for testing", (tester) async {
      await tester.pumpWidget(buildToggle());
      await tester.pumpAndSettle();

      expect(
          find.byKey(const Key("archive_toggle_switch")), findsOneWidget);
    });
  });
}
