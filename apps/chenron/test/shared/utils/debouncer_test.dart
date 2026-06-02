import "dart:async";

import "package:flutter_test/flutter_test.dart";

import "package:chenron/shared/utils/debouncer.dart";

void main() {
  const window = Duration(milliseconds: 20);

  test("runs only the last action when called within the window", () async {
    final debouncer = Debouncer<String>(duration: window);
    var aRan = false;
    var bRan = false;

    final first = debouncer.call(() async {
      aRan = true;
      return "A";
    });
    final second = debouncer.call(() async {
      bRan = true;
      return "B";
    });

    // The superseded call resolves to null (cancellation, not an error);
    // only the most recent action actually runs.
    expect(await first, isNull);
    expect(await second, "B");
    expect(aRan, isFalse, reason: "the superseded action must not run");
    expect(bRan, isTrue);
  });

  test("a non-cancellation error from the action is rethrown", () async {
    final debouncer = Debouncer<int>(duration: window);

    await expectLater(
      debouncer.call(() async => throw StateError("boom")),
      throwsStateError,
    );
  });

  test("dispose before the window elapses prevents the action from running",
      () async {
    final debouncer = Debouncer<String>(duration: window);
    var ran = false;

    unawaited(debouncer.call(() async {
      ran = true;
      return "X";
    }));
    debouncer.dispose();

    await Future<void>.delayed(window * 3);
    expect(ran, isFalse);
  });
}
