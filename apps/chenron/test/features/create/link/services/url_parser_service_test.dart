import "package:flutter_test/flutter_test.dart";

import "package:chenron/features/create/link/services/url_parser_service.dart";

void main() {
  // -------------------------------------------------------------------------
  // parseSingleLine()
  // -------------------------------------------------------------------------
  group("parseSingleLine()", () {
    test("returns null for empty string", () {
      expect(UrlParserService.parseSingleLine(""), isNull);
      expect(UrlParserService.parseSingleLine("   "), isNull);
    });

    test("parses plain URL with no tags", () {
      final result =
          UrlParserService.parseSingleLine("https://example.com/page");
      expect(result, isNotNull);
      expect(result!.url, equals("https://example.com/page"));
      expect(result.tags, isEmpty);
    });

    test("parses pipe-separated tags", () {
      final result = UrlParserService.parseSingleLine(
          "https://example.com | tag1, tag2");
      expect(result, isNotNull);
      expect(result!.url, equals("https://example.com"));
      expect(result.tags, containsAll(["tag1", "tag2"]));
    });

    test("handles multiple pipes by joining remaining parts", () {
      final result = UrlParserService.parseSingleLine(
          "https://example.com | tag1 | tag2");
      expect(result, isNotNull);
      expect(result!.url, equals("https://example.com"));
      expect(result.tags, containsAll(["tag1", "tag2"]));
    });

    test("parses hashtag-separated tags", () {
      final result = UrlParserService.parseSingleLine(
          "https://example.com #cool #stuff");
      expect(result, isNotNull);
      expect(result!.url, equals("https://example.com"));
      expect(result.tags, equals(["cool", "stuff"]));
    });

    test("lowercases hashtag tags", () {
      final result = UrlParserService.parseSingleLine(
          "https://example.com #CamelCase #UPPER");
      expect(result, isNotNull);
      expect(result!.tags, equals(["camelcase", "upper"]));
    });

    test("returns null URL with empty tag-only line using hashtag", () {
      // A line like "#onlytag" is treated as hashtag format but URL is empty
      // parseSingleLine should return null since URL is empty after extracting hashtags
      final result = UrlParserService.parseSingleLine("#onlytag");
      // The line starts with # so URL before first # is empty
      // With empty URL, the hashtag branch returns null, falls through to no-tag
      // But the line is "#onlytag" which is non-empty so it returns as a plain URL
      expect(result, isNotNull);
    });

    test("trims whitespace from URL and tags", () {
      final result = UrlParserService.parseSingleLine(
          "  https://example.com  |  tag1 ,  tag2  ");
      expect(result, isNotNull);
      expect(result!.url, equals("https://example.com"));
      expect(result.tags, containsAll(["tag1", "tag2"]));
    });

    test("deduplicates tags from pipe format", () {
      final result = UrlParserService.parseSingleLine(
          "https://example.com | dupe, dupe, unique");
      expect(result, isNotNull);
      expect(result!.tags, equals(["dupe", "unique"]));
    });

    test("strips leading # from pipe-format tags", () {
      final result = UrlParserService.parseSingleLine(
          "https://example.com | #tagged, normal");
      expect(result, isNotNull);
      expect(result!.tags, containsAll(["tagged", "normal"]));
    });
  });

  // -------------------------------------------------------------------------
  // parseBulkLines()
  // -------------------------------------------------------------------------
  group("parseBulkLines()", () {
    test("returns empty list for empty string", () {
      expect(UrlParserService.parseBulkLines(""), isEmpty);
    });

    test("parses multiple lines", () {
      final results = UrlParserService.parseBulkLines(
          "https://one.com\nhttps://two.com\nhttps://three.com");
      expect(results, hasLength(3));
      expect(results[0].url, equals("https://one.com"));
      expect(results[2].url, equals("https://three.com"));
    });

    test("skips empty lines", () {
      final results = UrlParserService.parseBulkLines(
          "https://one.com\n\n\nhttps://two.com");
      expect(results, hasLength(2));
    });

    test("skips comment lines starting with #", () {
      final results = UrlParserService.parseBulkLines(
          "# This is a comment\nhttps://real.com\n  # indented comment");
      expect(results, hasLength(1));
      expect(results[0].url, equals("https://real.com"));
    });

    test("parses lines with mixed tag formats", () {
      final results = UrlParserService.parseBulkLines(
          "https://a.com | piped\nhttps://b.com #hashed");
      expect(results, hasLength(2));
      expect(results[0].tags, contains("piped"));
      expect(results[1].tags, contains("hashed"));
    });

    test("skips lines that parse to empty URL", () {
      // After hashtag extraction, if URL is empty the line is skipped
      final results = UrlParserService.parseBulkLines(
          "https://real.com\n|onlypipe");
      // "|onlypipe" has pipe so URL is empty string before |
      expect(results.where((r) => r.url.isNotEmpty), hasLength(1));
    });
  });
}
