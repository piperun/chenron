import "dart:async";

import "package:chenron/utils/safe_async.dart";
import "package:chenron_mockups/chenron_mockups.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  setUpAll(installTestLogger);

  group("safeWatch", () {
    test("delivers data via onData while a healthy stream is running",
        () async {
      final controller = StreamController<int>();
      final received = <int>[];
      Object? capturedError;

      final sub = safeWatch<int>(
        controller.stream,
        tag: "Test",
        onData: received.add,
        onUiError: (e) => capturedError = e,
      );

      controller.add(1);
      controller.add(2);
      await Future<void>.delayed(Duration.zero);

      expect(received, [1, 2]);
      expect(capturedError, isNull);

      await sub.cancel();
      await controller.close();
    });

    test("logs and forwards stream errors via onUiError", () async {
      final controller = StreamController<int>();
      Object? capturedError;

      final sub = safeWatch<int>(
        controller.stream,
        tag: "Test",
        onData: (_) {},
        onUiError: (e) => capturedError = e,
      );

      final boom = StateError("boom");
      controller.addError(boom);
      await Future<void>.delayed(Duration.zero);

      expect(capturedError, same(boom));

      await sub.cancel();
      await controller.close();
    });

    test("omitting onUiError still consumes the error (no zone crash)",
        () async {
      final controller = StreamController<int>();

      final sub = safeWatch<int>(
        controller.stream,
        tag: "Test",
        onData: (_) {},
      );

      controller.addError(StateError("boom"));
      await Future<void>.delayed(Duration.zero);

      // If the error escaped into the zone, the runZonedGuarded inside
      // the test framework would have flagged it by now.

      await sub.cancel();
      await controller.close();
    });
  });

  group("State.safeAwait", () {
    testWidgets("returns the action result on success and skips snackbar",
        (tester) async {
      int? captured;
      await tester.pumpWidget(
        MaterialApp(
          home: _ProbeWidget(
            onMount: (state) async {
              captured = await state.safeAwait<int>(
                tag: "Test",
                operation: "load int",
                action: () async => 42,
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(captured, 42);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets(
        "returns null on failure and surfaces a user-friendly snackbar",
        (tester) async {
      Object? returned = "sentinel";
      await tester.pumpWidget(
        MaterialApp(
          home: _ProbeWidget(
            onMount: (state) async {
              returned = await state.safeAwait<int>(
                tag: "Test",
                operation: "explode",
                action: () async => throw StateError("kaboom"),
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(returned, isNull);
      expect(find.byType(SnackBar), findsOneWidget);
      // The user-facing text is generic; the raw exception string is in
      // the log, not the UI.
      expect(find.textContaining("kaboom"), findsNothing);
    });

    testWidgets(
        "showSnackBarOnError: false logs but does not display a snackbar",
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _ProbeWidget(
            onMount: (state) async {
              await state.safeAwait<int>(
                tag: "Test",
                operation: "silent failure",
                action: () async => throw StateError("nope"),
                showSnackBarOnError: false,
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets("skips snackbar when the State has been unmounted",
        (tester) async {
      final completer = Completer<int>();
      Future<int?>? pending;

      await tester.pumpWidget(
        MaterialApp(
          home: _ProbeWidget(
            onMount: (state) {
              pending = state.safeAwait<int>(
                tag: "Test",
                operation: "slow",
                action: () => completer.future,
              );
            },
          ),
        ),
      );

      // Replace the probe — its State is now unmounted.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Complete the future with an error AFTER unmount.
      completer.completeError(StateError("after unmount"));
      final result = await pending;

      expect(result, isNull);
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}

/// Stateful probe that runs an arbitrary [onMount] callback against its
/// own State exactly once, in `initState`.
class _ProbeWidget extends StatefulWidget {
  final void Function(State<_ProbeWidget> state) onMount;

  const _ProbeWidget({required this.onMount});

  @override
  State<_ProbeWidget> createState() => _ProbeWidgetState();
}

class _ProbeWidgetState extends State<_ProbeWidget> {
  @override
  void initState() {
    super.initState();
    unawaited(Future<void>.microtask(() => widget.onMount(this)));
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("probe")));
}
