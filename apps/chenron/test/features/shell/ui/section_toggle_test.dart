import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/shell/ui/section_toggle.dart";
import "package:chenron/features/shell/ui/sections/navigation_section.dart";

void main() {
  Widget buildToggle({
    NavigationSection currentSection = NavigationSection.statistics,
    void Function(NavigationSection)? onSectionSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SectionToggle(
            currentSection: currentSection,
            onSectionSelected: onSectionSelected ?? (_) {},
          ),
        ),
      ),
    );
  }

  group("SectionToggle rendering", () {
    testWidgets("shows all section labels", (tester) async {
      await tester.pumpWidget(buildToggle());
      await tester.pumpAndSettle();

      for (final section in NavigationSection.values) {
        expect(find.text(section.label), findsOneWidget);
      }
    });

    testWidgets("shows icons for all sections", (tester) async {
      await tester.pumpWidget(buildToggle(
        currentSection: NavigationSection.statistics,
      ));
      await tester.pumpAndSettle();

      // Statistics is selected, so it gets selectedIcon
      expect(find.byIcon(NavigationSection.statistics.selectedIcon),
          findsOneWidget);
      // Viewer is not selected, so it gets normal icon
      expect(find.byIcon(NavigationSection.viewer.icon), findsOneWidget);
    });

    testWidgets("highlights selected section", (tester) async {
      await tester.pumpWidget(buildToggle(
        currentSection: NavigationSection.viewer,
      ));
      await tester.pumpAndSettle();

      // Viewer is selected - uses selectedIcon
      expect(
          find.byIcon(NavigationSection.viewer.selectedIcon), findsOneWidget);
      // Statistics is not selected - uses normal icon
      expect(find.byIcon(NavigationSection.statistics.icon), findsOneWidget);
    });

    testWidgets("renders SectionButton for each section", (tester) async {
      await tester.pumpWidget(buildToggle());
      await tester.pumpAndSettle();

      expect(
        find.byType(SectionButton),
        findsNWidgets(NavigationSection.values.length),
      );
    });
  });

  group("SectionToggle interaction", () {
    testWidgets("calls onSectionSelected when section tapped",
        (tester) async {
      NavigationSection? selected;
      await tester.pumpWidget(buildToggle(
        currentSection: NavigationSection.statistics,
        onSectionSelected: (section) => selected = section,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(NavigationSection.viewer.label));
      expect(selected, NavigationSection.viewer);
    });

    testWidgets("can select already-selected section", (tester) async {
      NavigationSection? selected;
      await tester.pumpWidget(buildToggle(
        currentSection: NavigationSection.statistics,
        onSectionSelected: (section) => selected = section,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(NavigationSection.statistics.label));
      expect(selected, NavigationSection.statistics);
    });
  });

  group("SectionButton rendering", () {
    testWidgets("selected button has bold text", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SectionButton(
            section: NavigationSection.statistics,
            isSelected: true,
            onPressed: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(
        find.text(NavigationSection.statistics.label),
      );
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets("unselected button has normal text weight", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SectionButton(
            section: NavigationSection.statistics,
            isSelected: false,
            onPressed: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(
        find.text(NavigationSection.statistics.label),
      );
      expect(text.style?.fontWeight, FontWeight.w500);
    });
  });
}
