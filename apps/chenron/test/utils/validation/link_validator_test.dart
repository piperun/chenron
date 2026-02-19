import "package:flutter_test/flutter_test.dart";

import "package:chenron/utils/validation/link_validator.dart";

void main() {
  group("LinkValidator.validateContent()", () {
    test("returns error for null", () {
      expect(LinkValidator.validateContent(null), isNotNull);
    });

    test("returns error for empty string", () {
      expect(LinkValidator.validateContent(""), isNotNull);
    });

    test("returns error for too-short URL", () {
      // SchemaRules.url.min is 11
      final result = LinkValidator.validateContent("http://a.b");
      expect(result, isNotNull);
      expect(result, contains("between"));
    });

    test("returns error for invalid URL format", () {
      final result =
          LinkValidator.validateContent("not a url at all but long enough");
      expect(result, isNotNull);
      expect(result, contains("valid URL"));
    });

    test("returns null for valid http URL", () {
      expect(
          LinkValidator.validateContent("https://example.com"), isNull);
    });

    test("returns null for valid URL with path", () {
      expect(
          LinkValidator.validateContent("https://example.com/some/path"),
          isNull);
    });

    test("returns null for valid URL with query params", () {
      expect(
          LinkValidator.validateContent("https://example.com?q=test&p=1"),
          isNull);
    });

    test("rejects localhost URLs", () {
      // validator_dart's isURL rejects localhost
      expect(
          LinkValidator.validateContent("http://localhost:8080/api"),
          isNotNull);
    });
  });
}
