import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";

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
  // validateUrl(client:) — shared-client plumbing
  // -------------------------------------------------------------------------
  group("validateUrl(client:)", () {
    test("uses the supplied client for HTTP requests", () async {
      var callCount = 0;
      Uri? capturedUri;
      final client = MockClient((request) async {
        callCount++;
        capturedUri = request.url;
        return http.Response("", 200);
      });

      final result = await UrlValidatorService.validateUrl(
        "http://localhost/some-path",
        client: client,
      );

      expect(callCount, greaterThanOrEqualTo(1),
          reason: "MockClient was never invoked — client plumbing broken");
      expect(capturedUri?.host, "localhost");
      expect(result.isValid, isTrue);
      expect(result.isReachable, isTrue);
      expect(result.statusCode, 200);
    });

    test("falls back to GET when HEAD fails on the supplied client",
        () async {
      var headCount = 0;
      var getCount = 0;
      final client = MockClient((request) async {
        if (request.method == "HEAD") {
          headCount++;
          throw http.ClientException("HEAD not allowed", request.url);
        }
        getCount++;
        return http.Response("body", 200);
      });

      final result = await UrlValidatorService.validateUrl(
        "http://localhost/",
        client: client,
      );

      expect(headCount, 1);
      expect(getCount, 1);
      expect(result.isReachable, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // validateUrls — bounded concurrency + shared client
  // -------------------------------------------------------------------------
  group("validateUrls", () {
    test("returns empty map for empty input without creating a client",
        () async {
      // If the implementation accidentally constructs/closes an http.Client
      // here it's a waste, but functionally the map should still be empty.
      final result = await UrlValidatorService.validateUrls([]);
      expect(result, isEmpty);
    });

    test("returns one result per input URL with shared client", () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        return http.Response("", 200);
      });

      final urls = List.generate(5, (i) => "http://localhost/$i");
      final results = await UrlValidatorService.validateUrls(
        urls,
        client: client,
        concurrency: 2,
      );

      expect(results.length, 5);
      expect(results.keys, containsAll(urls));
      // 5 URLs × (1 HEAD each, no fallback path) = 5 client calls.
      expect(callCount, 5);
    });

    test("never lets more than `concurrency` requests be in flight",
        () async {
      // Regression: bulk import used to fire Future.wait over every URL at
      // once. The chunking loop in validateUrls bounds the in-flight count.
      var inFlight = 0;
      var maxInFlight = 0;
      final client = MockClient((request) async {
        inFlight++;
        if (inFlight > maxInFlight) maxInFlight = inFlight;
        // Hold the response long enough for chunkmates to also enter.
        await Future<void>.delayed(const Duration(milliseconds: 20));
        inFlight--;
        return http.Response("", 200);
      });

      final urls = List.generate(20, (i) => "http://localhost/$i");
      await UrlValidatorService.validateUrls(
        urls,
        client: client,
        concurrency: 3,
      );

      expect(maxInFlight, lessThanOrEqualTo(3),
          reason: "in-flight count exceeded the concurrency cap");
      expect(maxInFlight, greaterThanOrEqualTo(2),
          reason: "test should genuinely overlap requests; if max is 1 the "
              "delay didn't take effect and we're not really testing bounds");
    });

    test("does not close a caller-owned client", () async {
      var closed = false;
      final client = _ClosableMockClient(
        (request) async => http.Response("", 200),
        onClose: () => closed = true,
      );

      await UrlValidatorService.validateUrls(
        ["http://localhost/"],
        client: client,
      );

      expect(closed, isFalse,
          reason: "validateUrls must not close a client owned by the caller");
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

/// MockClient that exposes whether `close()` was called.
class _ClosableMockClient extends MockClient {
  final void Function() onClose;
  _ClosableMockClient(super.fn, {required this.onClose});

  @override
  void close() {
    onClose();
    super.close();
  }
}
