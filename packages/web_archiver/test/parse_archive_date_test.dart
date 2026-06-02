import "package:flutter_test/flutter_test.dart";
import "package:web_archiver/src/parse_archive_date.dart";

void main() {
  group("parseArchiveDate", () {
    test("parses a Wayback timestamp as a UTC instant", () {
      final result = parseArchiveDate(
          "https://web.archive.org/web/20231027120000/https://example.com");

      expect(result, isNotNull);
      // Wayback timestamps are UTC; the parsed instant must match exactly
      // regardless of the host machine's local timezone.
      expect(result, equals(DateTime.utc(2023, 10, 27, 12, 0, 0)));
    });

    test("returns a DateTime flagged as UTC", () {
      final result = parseArchiveDate(
          "https://web.archive.org/web/20231027120000/https://example.com");

      expect(result, isNotNull);
      expect(result!.isUtc, isTrue);
    });

    test("yields the same instant independent of local time interpretation",
        () {
      // A timestamp parsed as local time would differ from the UTC instant
      // by the local offset; this asserts we are not doing that.
      final result = parseArchiveDate(
          "https://web.archive.org/web/20000101000000/https://example.com");

      expect(result, equals(DateTime.utc(2000, 1, 1, 0, 0, 0)));
      expect(result!.millisecondsSinceEpoch,
          equals(DateTime.utc(2000, 1, 1).millisecondsSinceEpoch));
    });

    test("returns null when the URL has no 14-digit timestamp", () {
      expect(parseArchiveDate("https://example.com/no/timestamp/here"), isNull);
    });

    test("returns null for a too-short (non-14-digit) timestamp", () {
      // 12 digits — the regex requires exactly 14 between /web/ and /.
      expect(
          parseArchiveDate(
              "https://web.archive.org/web/202310271200/https://example.com"),
          isNull);
    });

    test("returns null for an empty string", () {
      expect(parseArchiveDate(""), isNull);
    });
  });
}
