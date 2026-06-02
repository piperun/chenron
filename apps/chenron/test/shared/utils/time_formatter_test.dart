import "package:flutter_test/flutter_test.dart";

import "package:chenron/shared/utils/time_formatter.dart";

void main() {
  DateTime ago(Duration d) => DateTime.now().subtract(d);

  group("formatRelative", () {
    test("null is Unknown", () {
      expect(TimeFormatter.formatRelative(null), "Unknown");
    });

    test("under a minute is Just now", () {
      expect(TimeFormatter.formatRelative(ago(const Duration(seconds: 10))),
          "Just now");
    });

    test("minutes / hours / days buckets", () {
      expect(TimeFormatter.formatRelative(ago(const Duration(minutes: 5))),
          "5m ago");
      expect(
          TimeFormatter.formatRelative(ago(const Duration(hours: 3))), "3h ago");
      expect(
          TimeFormatter.formatRelative(ago(const Duration(days: 2))), "2d ago");
    });

    test("months and years are floored", () {
      // 45 days -> 1 month; 400 days -> 1 year.
      expect(TimeFormatter.formatRelative(ago(const Duration(days: 45))),
          "1mo ago");
      expect(TimeFormatter.formatRelative(ago(const Duration(days: 400))),
          "1y ago");
    });

    test("rolls from minutes to hours across the hour boundary", () {
      expect(TimeFormatter.formatRelative(ago(const Duration(minutes: 59))),
          "59m ago");
      expect(TimeFormatter.formatRelative(ago(const Duration(minutes: 61))),
          "1h ago");
    });

    test("a future timestamp reads as Just now (negative difference)", () {
      // now.difference(future) is negative, so every '> 0' branch is false
      // and it falls through to "Just now".
      expect(
        TimeFormatter.formatRelative(
            DateTime.now().add(const Duration(hours: 2))),
        "Just now",
      );
    });
  });

  group("absolute formats", () {
    final d = DateTime(2025, 1, 2, 14, 30, 45);

    test("formatAbsolute is minute precision", () {
      expect(TimeFormatter.formatAbsolute(d), "2025-01-02 14:30");
    });

    test("formatFull includes seconds", () {
      expect(TimeFormatter.formatFull(d), "2025-01-02 14:30:45");
    });

    test("null is Unknown", () {
      expect(TimeFormatter.formatAbsolute(null), "Unknown");
      expect(TimeFormatter.formatFull(null), "Unknown");
    });
  });

  group("format dispatch", () {
    test("dispatches by TimeDisplayFormat", () {
      final d = DateTime(2025, 1, 2, 14, 30);
      expect(TimeFormatter.format(d, TimeDisplayFormat.absolute),
          "2025-01-02 14:30");
      expect(TimeFormatter.format(null, TimeDisplayFormat.relative), "Unknown");
    });
  });
}
