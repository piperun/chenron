import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";

import "package:chenron/responsible_design/breakpoints.dart";

void main() {
  group("WindowSizeClass.fromWidth — Material 3 window size classes", () {
    test("classifies each band at its boundary", () {
      expect(WindowSizeClass.fromWidth(0), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(599.9), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(839.9), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(840), WindowSizeClass.expanded);
      expect(WindowSizeClass.fromWidth(1199.9), WindowSizeClass.expanded);
      expect(WindowSizeClass.fromWidth(1200), WindowSizeClass.large);
      expect(WindowSizeClass.fromWidth(1599.9), WindowSizeClass.large);
      expect(WindowSizeClass.fromWidth(1600), WindowSizeClass.extraLarge);
    });
  });

  group("WindowSizeClass.isAtLeast", () {
    test("orders the classes from compact to extraLarge", () {
      expect(
          WindowSizeClass.expanded.isAtLeast(WindowSizeClass.medium), isTrue);
      expect(WindowSizeClass.large.isAtLeast(WindowSizeClass.large), isTrue);
      expect(
          WindowSizeClass.compact.isAtLeast(WindowSizeClass.medium), isFalse);
    });
  });

  group("responsiveValue", () {
    test("returns the value for the exact class when provided", () {
      expect(
        responsiveValue(WindowSizeClass.expanded,
            compact: "c", medium: "m", expanded: "e"),
        "e",
      );
    });

    test("falls back to the nearest smaller provided class", () {
      // large/extraLarge omitted -> fall back down the chain.
      expect(
        responsiveValue(WindowSizeClass.large, compact: "c", medium: "m"),
        "m",
      );
      expect(responsiveValue(WindowSizeClass.extraLarge, compact: "c"), "c");
      expect(responsiveValue(WindowSizeClass.medium, compact: "c"), "c");
    });
  });

  group("BuildContext.windowSizeClass", () {
    testWidgets("derives the class from the window width", (tester) async {
      late WindowSizeClass sizeClass;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(900, 600)),
          child: Builder(
            builder: (context) {
              sizeClass = context.windowSizeClass;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // 900px wide window -> expanded (840..1200).
      expect(sizeClass, WindowSizeClass.expanded);
    });
  });
}
