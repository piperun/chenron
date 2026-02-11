import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron/features/shell/widgets/add_item_modal.dart";

void main() {
  Widget buildModal({
    ValueChanged<ItemType>? onTypeSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => AddItemModal(
                onTypeSelected: onTypeSelected,
              ),
            ),
            child: const Text("Open"),
          ),
        ),
      ),
    );
  }

  /// Opens the AddItemModal with a viewport large enough to avoid overflow.
  /// Uses a narrow width so the modal gets height-proportional sizing (60%
  /// of viewport) instead of the fixed 480px that overflows by 2px.
  Future<void> openModal(WidgetTester tester,
      {ValueChanged<ItemType>? onTypeSelected}) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester
        .pumpWidget(buildModal(onTypeSelected: onTypeSelected));
    await tester.tap(find.text("Open"));
    await tester.pumpAndSettle();
  }

  group("AddItemModal type selector rendering", () {
    testWidgets("shows Create New header", (tester) async {
      await openModal(tester);

      expect(find.text("Create New"), findsOneWidget);
      expect(find.text("Choose what you'd like to add"), findsOneWidget);
    });

    testWidgets("shows Link type card", (tester) async {
      await openModal(tester);

      expect(find.text("Link"), findsOneWidget);
      expect(find.text("Add a link or bookmark"), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets("shows Folder type card", (tester) async {
      await openModal(tester);

      expect(find.text("Folder"), findsOneWidget);
      expect(find.text("Create a new folder"), findsOneWidget);
      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });

    testWidgets("shows Document type card", (tester) async {
      await openModal(tester);

      expect(find.text("Document"), findsOneWidget);
      expect(find.text("Upload a document"), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets("shows Cancel button", (tester) async {
      await openModal(tester);

      expect(find.text("Cancel"), findsOneWidget);
    });

    testWidgets("shows arrow icons on type cards", (tester) async {
      await openModal(tester);

      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(3));
    });
  });

  group("AddItemModal type selector with callback", () {
    testWidgets("calls onTypeSelected with link when Link tapped",
        (tester) async {
      ItemType? selectedType;
      await openModal(tester,
          onTypeSelected: (type) => selectedType = type);

      await tester.tap(find.text("Link"));
      await tester.pumpAndSettle();

      expect(selectedType, ItemType.link);
    });

    testWidgets("calls onTypeSelected with folder when Folder tapped",
        (tester) async {
      ItemType? selectedType;
      await openModal(tester,
          onTypeSelected: (type) => selectedType = type);

      await tester.tap(find.text("Folder"));
      await tester.pumpAndSettle();

      expect(selectedType, ItemType.folder);
    });

    testWidgets("calls onTypeSelected with document when Document tapped",
        (tester) async {
      ItemType? selectedType;
      await openModal(tester,
          onTypeSelected: (type) => selectedType = type);

      await tester.tap(find.text("Document"));
      await tester.pumpAndSettle();

      expect(selectedType, ItemType.document);
    });

    testWidgets("closes modal after type selection with callback",
        (tester) async {
      await openModal(tester, onTypeSelected: (_) {});

      expect(find.text("Create New"), findsOneWidget);

      await tester.tap(find.text("Link"));
      await tester.pumpAndSettle();

      // Modal should be closed
      expect(find.text("Create New"), findsNothing);
    });
  });

  group("AddItemModal type selector without callback (form mode)", () {
    testWidgets("shows type selector view initially", (tester) async {
      await openModal(tester);

      expect(find.text("Create New"), findsOneWidget);
      expect(find.text("Link"), findsOneWidget);
      expect(find.text("Folder"), findsOneWidget);
      expect(find.text("Document"), findsOneWidget);
    });
  });

  group("AddItemModal Cancel", () {
    testWidgets("Cancel button closes the modal", (tester) async {
      await openModal(tester);

      expect(find.text("Create New"), findsOneWidget);

      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      expect(find.text("Create New"), findsNothing);
    });
  });
}
