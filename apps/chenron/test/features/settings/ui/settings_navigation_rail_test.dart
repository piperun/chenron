import "package:chenron/features/settings/models/settings_category.dart";
import "package:chenron/features/settings/ui/settings_navigation_rail.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:forrest/forrest.dart";

Future<void> _pumpRail(
  WidgetTester tester, {
  SettingsCategory selectedCategory = SettingsCategory.theme,
  bool isExtended = true,
  required ValueChanged<SettingsCategory> onCategorySelected,
  required VoidCallback onToggleExtended,
  required VoidCallback onBack,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SettingsNavigationRail(
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
          isExtended: isExtended,
          onToggleExtended: onToggleExtended,
          onBack: onBack,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets("reveals the selected child and uses its selected icon",
      (tester) async {
    await _pumpRail(
      tester,
      onCategorySelected: (_) {},
      onToggleExtended: () {},
      onBack: () {},
    );

    expect(
      find.byKey(Tree.rowKey(SettingsCategory.appearance)),
      findsOneWidget,
    );
    final Finder selectedRow = find.byKey(Tree.rowKey(SettingsCategory.theme));
    expect(selectedRow, findsOneWidget);
    expect(
      find.descendant(
        of: selectedRow,
        matching: find.byIcon(Icons.color_lens),
      ),
      findsOneWidget,
    );
  });

  testWidgets("branch activation expands without selecting a child",
      (tester) async {
    final List<SettingsCategory> selections = <SettingsCategory>[];
    await _pumpRail(
      tester,
      onCategorySelected: selections.add,
      onToggleExtended: () {},
      onBack: () {},
    );

    expect(
      find.byKey(Tree.rowKey(SettingsCategory.database)),
      findsNothing,
    );
    await tester.tap(find.byKey(Tree.rowKey(SettingsCategory.storage)));
    await tester.pump();

    expect(selections, isEmpty);
    expect(
      find.byKey(Tree.rowKey(SettingsCategory.database)),
      findsOneWidget,
    );
  });

  testWidgets("leaf activation forwards the selected category", (tester) async {
    final List<SettingsCategory> selections = <SettingsCategory>[];
    await _pumpRail(
      tester,
      onCategorySelected: selections.add,
      onToggleExtended: () {},
      onBack: () {},
    );

    await tester.tap(find.byKey(Tree.rowKey(SettingsCategory.archive)));
    await tester.pump();

    expect(selections, <SettingsCategory>[SettingsCategory.archive]);
  });

  testWidgets("compact toggle delegates to the owning shell", (tester) async {
    int toggleCalls = 0;
    await _pumpRail(
      tester,
      onCategorySelected: (_) {},
      onToggleExtended: () => toggleCalls++,
      onBack: () {},
    );

    await tester.tap(find.byKey(Tree.compactToggleKey));
    await tester.pump();

    expect(toggleCalls, 1);
  });

  testWidgets("Back footer delegates to the owning shell", (tester) async {
    int backCalls = 0;
    await _pumpRail(
      tester,
      onCategorySelected: (_) {},
      onToggleExtended: () {},
      onBack: () => backCalls++,
    );

    await tester.tap(
      find.byKey(
        const ValueKey<String>("settings-navigation-back"),
      ),
    );
    await tester.pump();

    expect(backCalls, 1);
  });
}
