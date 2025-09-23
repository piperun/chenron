import "package:flutter_test/flutter_test.dart";
import "package:web_archiver/web_archiver.dart";

void main() {
  group("parseArchiveDate", () {
    test("parses valid archive.org URL correctly", () {
      const url =
          "https://web.archive.org/web/20240430005208/https://example.org/";
      final result = parseArchiveDate(url);
      expect(result, isNotNull);
      expect(result, DateTime(2024, 4, 30, 0, 52, 8));
    });

    test("returns null for invalid archive.org URL", () {
      const url = "https://web.archive.org/web/invalid/https://example.org/";
      final result = parseArchiveDate(url);
      expect(result, isNull);
    });

    test("returns null for non-archive.org URL", () {
      const url = "https://example.org/";
      final result = parseArchiveDate(url);
      expect(result, isNull);
    });

    test("handles URL with additional path components", () {
      const url =
          "https://web.archive.org/web/20240430005208/https://example.org/path/to/page";
      final result = parseArchiveDate(url);
      expect(result, isNotNull);
      expect(result, DateTime(2024, 4, 30, 0, 52, 8));
    });

    test("handles URL with query parameters", () {
      const url =
          "https://web.archive.org/web/20240430005208/https://example.org/?param=value";
      final result = parseArchiveDate(url);
      expect(result, isNotNull);
      expect(result, DateTime(2024, 4, 30, 0, 52, 8));
    });

    test("handles URL with fragments", () {
      const url =
          "https://web.archive.org/web/20240430005208/https://example.org/#section";
      final result = parseArchiveDate(url);
      expect(result, isNotNull);
      expect(result, DateTime(2024, 4, 30, 0, 52, 8));
    });

    test("handles different date values", () {
      final urls = [
        "https://web.archive.org/web/19960101000000/https://example.org/",
        "https://web.archive.org/web/20991231235959/https://example.org/",
      ];
      final expectedDates = [
        DateTime(1996, 1, 1, 0, 0, 0),
        DateTime(2099, 12, 31, 23, 59, 59),
      ];
      for (var i = 0; i < urls.length; i++) {
        final result = parseArchiveDate(urls[i]);
        expect(result, isNotNull);
        expect(result, expectedDates[i]);
      }
    });
  });
}
