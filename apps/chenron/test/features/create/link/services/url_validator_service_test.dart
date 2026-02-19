import "package:flutter_test/flutter_test.dart";

import "package:chenron/features/create/link/services/url_validator_service.dart";

void main() {
  // -------------------------------------------------------------------------
  // isValidUrlFormat()
  // -------------------------------------------------------------------------
  group("isValidUrlFormat()", () {
    test("returns true for https URL", () {
      expect(UrlValidatorService.isValidUrlFormat("https://example.com"),
          isTrue);
    });

    test("returns true for http URL", () {
      expect(
          UrlValidatorService.isValidUrlFormat("http://example.com"), isTrue);
    });

    test("returns true for URL with path", () {
      expect(
          UrlValidatorService.isValidUrlFormat("https://example.com/path/to"),
          isTrue);
    });

    test("returns true for URL with query params", () {
      expect(
          UrlValidatorService.isValidUrlFormat("https://example.com?q=test"),
          isTrue);
    });

    test("returns true for URL with port", () {
      expect(UrlValidatorService.isValidUrlFormat("https://example.com:8080"),
          isTrue);
    });

    test("returns false for empty string", () {
      expect(UrlValidatorService.isValidUrlFormat(""), isFalse);
    });

    test("returns false for plain text", () {
      expect(UrlValidatorService.isValidUrlFormat("just some text"), isFalse);
    });

    test("returns false for missing scheme", () {
      expect(UrlValidatorService.isValidUrlFormat("example.com"), isFalse);
    });

    test("returns false for scheme-only", () {
      expect(UrlValidatorService.isValidUrlFormat("https://"), isFalse);
    });

    test("returns true for ftp scheme", () {
      expect(UrlValidatorService.isValidUrlFormat("ftp://files.example.com"),
          isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // validateUrl() - format failure path only
  // -------------------------------------------------------------------------
  group("validateUrl() format check", () {
    test("returns invalid for malformed URL", () async {
      final result =
          await UrlValidatorService.validateUrl("not a url");
      expect(result.isValid, isFalse);
      expect(result.isReachable, isFalse);
      expect(result.isSuccess, isFalse);
      expect(result.message, contains("Invalid"));
    });

    test("returns invalid for empty string", () async {
      final result = await UrlValidatorService.validateUrl("");
      expect(result.isValid, isFalse);
      expect(result.isReachable, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // UrlValidationResult
  // -------------------------------------------------------------------------
  group("UrlValidationResult", () {
    test("isSuccess requires both isValid and isReachable", () {
      final success = UrlValidationResult(
        isValid: true,
        isReachable: true,
      );
      expect(success.isSuccess, isTrue);

      final validButUnreachable = UrlValidationResult(
        isValid: true,
        isReachable: false,
      );
      expect(validButUnreachable.isSuccess, isFalse);

      final invalidButReachable = UrlValidationResult(
        isValid: false,
        isReachable: true,
      );
      expect(invalidButReachable.isSuccess, isFalse);
    });
  });
}
