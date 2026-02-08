import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/create/link/widgets/link_mode_switcher.dart";
import "package:chenron/features/create/link/notifiers/create_link_notifier.dart";

void main() {
  Widget buildSwitcher({
    InputMode mode = InputMode.single,
    ValueChanged<InputMode>? onModeChanged,
    String? hintText,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ModeSwitcher(
          mode: mode,
          onModeChanged: onModeChanged ?? (_) {},
          hintText: hintText,
        ),
      ),
    );
  }

  group("ModeSwitcher rendering", () {
    testWidgets("shows Single and Bulk buttons", (tester) async {
      await tester.pumpWidget(buildSwitcher());
      await tester.pumpAndSettle();

      expect(find.text("Single"), findsOneWidget);
      expect(find.text("Bulk"), findsOneWidget);
    });

    testWidgets("shows hint text when provided", (tester) async {
      await tester
          .pumpWidget(buildSwitcher(hintText: "Use pipe for tags"));
      await tester.pumpAndSettle();

      expect(find.text("Use pipe for tags"), findsOneWidget);
    });

    testWidgets("does not show hint text when null", (tester) async {
      await tester.pumpWidget(buildSwitcher(hintText: null));
      await tester.pumpAndSettle();

      // Only Single and Bulk text should exist
      expect(find.byType(Text), findsNWidgets(2));
    });

    testWidgets("highlights Single when mode is single", (tester) async {
      await tester.pumpWidget(buildSwitcher(mode: InputMode.single));
      await tester.pumpAndSettle();

      // Find the containers wrapping the mode buttons
      // Active button has primaryContainer background
      // We verify by checking the text styling
      final singleText = tester.widget<Text>(find.text("Single"));
      expect(singleText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets("highlights Bulk when mode is bulk", (tester) async {
      await tester.pumpWidget(buildSwitcher(mode: InputMode.bulk));
      await tester.pumpAndSettle();

      final bulkText = tester.widget<Text>(find.text("Bulk"));
      expect(bulkText.style?.fontWeight, FontWeight.w600);
    });
  });

  group("ModeSwitcher interaction", () {
    testWidgets("calls onModeChanged with single when Single tapped",
        (tester) async {
      InputMode? selectedMode;
      await tester.pumpWidget(buildSwitcher(
        mode: InputMode.bulk,
        onModeChanged: (mode) => selectedMode = mode,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Single"));
      await tester.pumpAndSettle();

      expect(selectedMode, InputMode.single);
    });

    testWidgets("calls onModeChanged with bulk when Bulk tapped",
        (tester) async {
      InputMode? selectedMode;
      await tester.pumpWidget(buildSwitcher(
        mode: InputMode.single,
        onModeChanged: (mode) => selectedMode = mode,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Bulk"));
      await tester.pumpAndSettle();

      expect(selectedMode, InputMode.bulk);
    });

    testWidgets("Bulk button has correct key", (tester) async {
      await tester.pumpWidget(buildSwitcher());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("bulk_mode_button")), findsOneWidget);
    });
  });
}
