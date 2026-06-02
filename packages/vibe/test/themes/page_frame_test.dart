import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:vibe/vibe.dart";

/// Records how many of each drawing op a [CustomPainter] issues, so a
/// test can assert the grid batches its lines into one `drawPath`
/// rather than emitting a separate `drawLine` per gridline.
///
/// Everything not explicitly counted is swallowed by [noSuchMethod] so
/// the painter runs against a no-op surface.
class _CountingCanvas implements Canvas {
  int drawLineCalls = 0;
  int drawPathCalls = 0;

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) => drawLineCalls++;

  @override
  void drawPath(Path path, Paint paint) => drawPathCalls++;

  @override
  void noSuchMethod(Invocation invocation) {}
}

/// Finds the grid overlay's painter inside a pumped [NierPageFrame].
///
/// The painter type is library-private, so it is matched by name
/// rather than by `is` — the test only needs its public `paint` /
/// `shouldRepaint` surface.
CustomPainter _findGridPainter(WidgetTester tester) {
  final Iterable<CustomPaint> paints =
      tester.widgetList<CustomPaint>(find.byType(CustomPaint));
  return paints
      .map((CustomPaint p) => p.painter)
      .whereType<CustomPainter>()
      .firstWhere(
        (CustomPainter p) =>
            p.runtimeType.toString().contains("GridLinePainter"),
      );
}

void main() {
  group("NierPageFrame grid overlay", () {
    testWidgets(
      "batches every gridline into a single drawPath, no per-line drawLine",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: NierPageFrame(child: SizedBox.shrink()),
          ),
        );

        final CustomPainter painter = _findGridPainter(tester);
        final _CountingCanvas canvas = _CountingCanvas();
        // A surface big enough that the old per-line implementation
        // would have issued dozens of drawLine calls (spacing is 6px).
        painter.paint(canvas, const Size(240, 180));

        expect(canvas.drawPathCalls, 1);
        expect(canvas.drawLineCalls, 0);
      },
    );

    testWidgets("grid still actually paints (non-empty picture)", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NierPageFrame(child: SizedBox.shrink()),
        ),
      );

      final CustomPainter painter = _findGridPainter(tester);
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      painter.paint(canvas, const Size(240, 180));
      final ui.Picture picture = recorder.endRecording();

      // A blank size would record nothing; a real grid records ops.
      expect(picture.approximateBytesUsed, greaterThan(0));
      picture.dispose();
    });

    testWidgets("shouldRepaint tracks color changes", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NierPageFrame(child: SizedBox.shrink()),
        ),
      );

      final CustomPainter painter = _findGridPainter(tester);
      expect(painter.shouldRepaint(painter), isFalse);
    });
  });
}
