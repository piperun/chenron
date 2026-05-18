import "package:chenron/shared/dialogs/confirm_dialog.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  Future<Future<bool>> openDialog(
    WidgetTester tester, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = "Cancel",
    bool destructive = false,
  }) async {
    late Future<bool> dialogFuture;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              dialogFuture = showConfirmDialog(
                context,
                title: title,
                message: message,
                confirmLabel: confirmLabel,
                cancelLabel: cancelLabel,
                destructive: destructive,
              );
            },
            child: const Text("open"),
          ),
        ),
      ),
    ));
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
    return dialogFuture;
  }

  testWidgets("renders title, message, and custom labels", (tester) async {
    final future = await openDialog(
      tester,
      title: "Confirm deletion",
      message: "Are you sure?",
      confirmLabel: "Yes, remove",
      cancelLabel: "Keep",
    );
    expect(find.text("Confirm deletion"), findsOneWidget);
    expect(find.text("Are you sure?"), findsOneWidget);
    expect(find.text("Yes, remove"), findsOneWidget);
    expect(find.text("Keep"), findsOneWidget);

    await tester.tap(find.text("Keep"));
    await tester.pumpAndSettle();
    expect(await future, isFalse);
  });

  testWidgets("returns true when confirm pressed", (tester) async {
    final future = await openDialog(
      tester,
      title: "Save changes",
      message: "Save your work?",
      confirmLabel: "Persist",
    );
    await tester.tap(find.widgetWithText(FilledButton, "Persist"));
    await tester.pumpAndSettle();
    expect(await future, isTrue);
  });

  testWidgets("returns false when cancel pressed", (tester) async {
    final future = await openDialog(
      tester,
      title: "Save changes",
      message: "Save your work?",
      confirmLabel: "Persist",
    );
    await tester.tap(find.widgetWithText(TextButton, "Cancel"));
    await tester.pumpAndSettle();
    expect(await future, isFalse);
  });

  testWidgets("returns false on barrier dismissal", (tester) async {
    final future = await openDialog(
      tester,
      title: "Save changes",
      message: "Save your work?",
      confirmLabel: "Persist",
    );
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(await future, isFalse);
  });

  testWidgets(
    "destructive=true paints confirm button with error background",
    (tester) async {
      final future = await openDialog(
        tester,
        title: "Confirm purge",
        message: "Permanent",
        confirmLabel: "Purge",
        destructive: true,
      );

      final BuildContext dialogContext =
          tester.element(find.widgetWithText(FilledButton, "Purge"));
      final expectedError = Theme.of(dialogContext).colorScheme.error;
      final filled = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, "Purge"),
      );
      final resolvedBg =
          filled.style?.backgroundColor?.resolve(<WidgetState>{});
      expect(resolvedBg, expectedError);

      await tester.tap(find.widgetWithText(TextButton, "Cancel"));
      await tester.pumpAndSettle();
      await future;
    },
  );

  testWidgets("destructive=false leaves confirm button default styling",
      (tester) async {
    final future = await openDialog(
      tester,
      title: "Import data",
      message: "Continue",
      confirmLabel: "Import",
    );
    final filled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, "Import"),
    );
    expect(filled.style, isNull);
    await tester.tap(find.widgetWithText(TextButton, "Cancel"));
    await tester.pumpAndSettle();
    await future;
  });
}
