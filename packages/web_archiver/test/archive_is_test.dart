import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:web_archiver/src/archive_is/archive_is.dart";

/// Builds a [MockClient] that drives an [ArchiveIsClient.archiveUrl] flow:
///   1. HEAD (domain detection) -> 200, echoing the request so the final URL
///      is discoverable.
///   2. GET  (homepage, for submitid) -> 200 with empty body (no submitid).
///   3. POST (submit) -> a caller-supplied [postResponse].
MockClient _flowClient(http.Response Function(http.Request request) onPost) {
  return MockClient((request) async {
    switch (request.method) {
      case "HEAD":
        // Echo the request so `_findCurrentDomain` can read response.request.url.
        return http.Response("", 200, request: request);
      case "GET":
        // Homepage fetch for submitid — empty body, no submitid present.
        return http.Response("<html></html>", 200, request: request);
      case "POST":
        return onPost(request);
      default:
        return http.Response("unexpected ${request.method}", 500,
            request: request);
    }
  });
}

void main() {
  group("ArchiveIsClient Refresh-header memento parsing", () {
    test("extracts the memento from a normal Refresh header", () async {
      final client = _flowClient((request) {
        return http.Response("", 200, request: request, headers: {
          "refresh": "0;url=https://archive.ph/abc123",
        });
      });
      final archiver = ArchiveIsClient(client: client);

      final memento = await archiver.archiveUrl("https://example.com");

      expect(memento, equals("https://archive.ph/abc123"));
    });

    test("keeps the full memento when the URL itself contains ';url='",
        () async {
      // The memento URL carries a query parameter that embeds ";url=". A naive
      // split on ";url=" yields 3 parts and a length==2 guard drops the whole
      // memento; the parser must consume only the FIRST delimiter.
      const mementoWithDelimiter =
          "https://archive.ph/o/abcd/https://example.com/page?redirect=;url=evil";
      final client = _flowClient((request) {
        return http.Response("", 200, request: request, headers: {
          "refresh": "0;url=$mementoWithDelimiter",
        });
      });
      final archiver = ArchiveIsClient(client: client);

      final memento = await archiver.archiveUrl("https://example.com");

      expect(memento, equals(mementoWithDelimiter));
    });

    test(
        "falls back to the Location header when no Refresh header is present",
        () async {
      final client = _flowClient((request) {
        return http.Response("", 302, request: request, headers: {
          "location": "https://archive.ph/located",
        });
      });
      final archiver = ArchiveIsClient(client: client);

      final memento = await archiver.archiveUrl("https://example.com");

      expect(memento, equals("https://archive.ph/located"));
    });

    test("throws when neither Refresh nor Location header carries a memento",
        () async {
      final client = _flowClient((request) {
        // 200 with no refresh and no redirect/location header.
        return http.Response("no memento here", 200, request: request);
      });
      final archiver = ArchiveIsClient(client: client);

      await expectLater(
        archiver.archiveUrl("https://example.com"),
        throwsA(isA<Exception>()),
      );
    });
  });
}
