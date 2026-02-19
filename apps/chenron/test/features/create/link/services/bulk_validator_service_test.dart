import "package:flutter_test/flutter_test.dart";

import "package:chenron/features/create/link/models/validation_result.dart";
import "package:chenron/features/create/link/services/bulk_validator_service.dart";

void main() {
  // -------------------------------------------------------------------------
  // validateBulkInput()
  // -------------------------------------------------------------------------
  group("validateBulkInput()", () {
    test("returns empty results for empty input", () {
      final result = BulkValidatorService.validateBulkInput("");
      expect(result.totalLines, equals(0));
      expect(result.hasErrors, isFalse);
    });

    test("skips empty lines and comments", () {
      final result = BulkValidatorService.validateBulkInput(
          "# comment\n\nhttps://example.com/valid-url");
      expect(result.totalLines, equals(1));
      expect(result.validLines, equals(1));
    });

    test("validates a valid URL", () {
      final result = BulkValidatorService.validateBulkInput(
          "https://example.com/path");
      expect(result.totalLines, equals(1));
      expect(result.validLines, equals(1));
      expect(result.hasErrors, isFalse);
    });

    test("reports invalid URL format", () {
      final result =
          BulkValidatorService.validateBulkInput("not-a-valid-url-at-all");
      expect(result.hasErrors, isTrue);
      final errors = result.errorLines.first.errors;
      expect(
        errors.any((e) => e.type == ValidationErrorType.urlInvalidFormat),
        isTrue,
      );
    });

    test("reports URL too short", () {
      // SchemaRules.url.min is 11
      final result = BulkValidatorService.validateBulkInput("http://a.b");
      expect(result.hasErrors, isTrue);
      final errors = result.errorLines.first.errors;
      expect(
        errors.any((e) => e.type == ValidationErrorType.urlTooShort),
        isTrue,
      );
    });

    test("validates multiple lines independently", () {
      final result = BulkValidatorService.validateBulkInput(
          "https://good-example.com\nshort\nhttps://also-good.com/page");
      expect(result.totalLines, equals(3));
      expect(result.validLines, equals(2));
      expect(result.invalidLines, equals(1));
    });

    test("uses 1-indexed line numbers", () {
      final result = BulkValidatorService.validateBulkInput(
          "# comment\nhttps://example.com/page");
      // Comment is skipped, so only line 2 is validated
      expect(result.lines.first.lineNumber, equals(2));
    });

    test("reports tag too short", () {
      // SchemaRules.tag.min is 3
      final result = BulkValidatorService.validateBulkInput(
          "https://example.com/page | ab");
      expect(result.hasErrors, isTrue);
      final errors = result.errorLines.first.errors;
      expect(
        errors.any((e) => e.type == ValidationErrorType.tagTooShort),
        isTrue,
      );
    });

    test("reports tag with invalid characters", () {
      final result = BulkValidatorService.validateBulkInput(
          "https://example.com/page | tag123");
      expect(result.hasErrors, isTrue);
      final errors = result.errorLines.first.errors;
      expect(
        errors.any((e) => e.type == ValidationErrorType.tagInvalidCharacters),
        isTrue,
      );
    });

    test("accepts valid tags", () {
      final result = BulkValidatorService.validateBulkInput(
          "https://example.com/page | cool, stuff");
      expect(result.hasErrors, isFalse);
      expect(result.lines.first.tags, containsAll(["cool", "stuff"]));
    });

    test("collects multiple errors per line", () {
      // A URL that is too short AND has an invalid tag
      final result =
          BulkValidatorService.validateBulkInput("http://a.b | x!");
      final errors = result.lines.first.errors;
      // Should have URL error + tag errors
      expect(errors.length, greaterThanOrEqualTo(2));
    });

    test("errorLines returns only invalid results", () {
      final result = BulkValidatorService.validateBulkInput(
          "https://good-example.com\nshort\nhttps://another-good.com/x");
      expect(result.errorLines, hasLength(1));
      expect(result.errorLines.first.rawLine, equals("short"));
    });

    test("validLinesData returns only valid results", () {
      final result = BulkValidatorService.validateBulkInput(
          "https://good-example.com\nshort");
      expect(result.validLinesData, hasLength(1));
      expect(result.validLinesData.first.url, equals("https://good-example.com"));
    });
  });
}
