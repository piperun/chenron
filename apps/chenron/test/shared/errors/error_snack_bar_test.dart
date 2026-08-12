import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:chenron/shared/navigation/activity_log_request.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  Widget host(void Function(BuildContext context) onPressed) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => onPressed(context),
            child: const Text("trigger"),
          ),
        ),
      ),
    );
  }

  testWidgets("plain error toast has no View Log action", (tester) async {
    await tester
        .pumpWidget(host((context) => showErrorSnackBar(context, "boom")));
    await tester.tap(find.text("trigger"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("View Log"), findsNothing);
  });

  testWidgets("opt-in action is shown and fires the open request",
      (tester) async {
    final requestsBefore = activityLogOpenRequest.peek();

    await tester.pumpWidget(host((context) =>
        showErrorSnackBar(context, "boom", showActivityLogAction: true)));
    await tester.tap(find.text("trigger"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.text("View Log"), findsOneWidget);

    await tester.tap(find.text("View Log"));
    await tester.pump();

    expect(activityLogOpenRequest.peek(), requestsBefore + 1);
  });
}
