import "dart:async";

import "package:cache_manager/cache_manager.dart";
import "package:chenron/services/metadata/metadata_fetch_client.dart";
import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;

final class ScriptedClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(http.BaseRequest request)
      _handler;

  ScriptedClient(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _handler(request);
}

final class CancellableResponse {
  bool cancelled = false;
  late final StreamController<List<int>> _controller =
      StreamController<List<int>>(onCancel: () => cancelled = true);

  final int statusCode;
  final Map<String, String> headers;

  CancellableResponse(this.statusCode, {this.headers = const {}});

  http.StreamedResponse get response =>
      http.StreamedResponse(_controller.stream, statusCode, headers: headers);
}

void main() {
  group("MetadataFetchClient", () {
    // Catches conditional validators being omitted or a 304 being rejected.
    test("sends validators and returns notModified for 304", () async {
      final client = ScriptedClient((request) async {
        expect(request.headers["if-none-match"], '"abc"');
        expect(
          request.headers["if-modified-since"],
          "Sat, 01 Aug 2026 10:00:00 GMT",
        );
        return http.StreamedResponse(
          const Stream.empty(),
          304,
          headers: {"etag": '"abc"'},
        );
      });
      final fetcher = MetadataFetchClient(client: client);

      final result = await fetcher.fetch(
        "https://example.com/post",
        previous: Metadata(
          url: "https://example.com/post",
          fetchedAt: DateTime.utc(2026),
          etag: '"abc"',
          lastModified: "Sat, 01 Aug 2026 10:00:00 GMT",
        ),
      );

      expect(result, isA<MetadataNotModified>());
    });

    // Catches delegating redirects to the HTTP package or resolving a
    // relative Location header against the original URL.
    test("follows one relative redirect", () async {
      final seen = <Uri>[];
      final client = ScriptedClient((request) async {
        seen.add(request.url);
        expect(request.followRedirects, isFalse);
        expect(request.maxRedirects, 0);
        expect(request.headers["accept"], contains("text/html"));
        expect(request.headers["user-agent"], "Chenron/metadata");
        if (seen.length == 1) {
          return http.StreamedResponse(
            const Stream.empty(),
            302,
            headers: {"location": "../article"},
          );
        }
        return http.StreamedResponse(
          Stream.value(
            "<html><head><title>Article title</title></head></html>".codeUnits,
          ),
          200,
          headers: {"content-type": "text/html; charset=utf-8"},
        );
      });

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/posts/original");

      expect(seen, [
        Uri.parse("https://example.com/posts/original"),
        Uri.parse("https://example.com/article"),
      ]);
      expect(result, isA<MetadataModified>());
      expect(
        (result as MetadataModified).candidate.resolvedUrl,
        "https://example.com/article",
      );
    });

    // Catches following a sixth redirect instead of returning a bounded
    // terminal outcome after five hops.
    test("rejects a sixth redirect", () async {
      var requests = 0;
      final client = ScriptedClient((request) async {
        requests++;
        if (requests <= 6) {
          return http.StreamedResponse(
            const Stream.empty(),
            302,
            headers: {"location": "/hop-$requests"},
          );
        }
        return http.StreamedResponse(
          Stream.value("<title>Should not be reached</title>".codeUnits),
          200,
          headers: {"content-type": "text/html"},
        );
      });

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/start");

      expect(requests, 6);
      expect(result, isA<MetadataRejected>());
      expect(
        (result as MetadataRejected).kind,
        MetadataFailureKind.tooManyRedirects,
      );
    });

    // Catches mapping an access denial to a generic HTTP failure.
    test("maps 403 to blocked", () async {
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(const Stream.empty(), 403),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/private");

      expect(result, isA<MetadataRejected>());
      expect((result as MetadataRejected).kind, MetadataFailureKind.blocked);
      expect(result.statusCode, 403);
    });

    // Catches losing a delta-seconds Retry-After delay on rate limiting.
    test("maps delta-seconds Retry-After for 429", () async {
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(
          const Stream.empty(),
          429,
          headers: {"retry-after": "120"},
        ),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/rate-limited");

      expect(result, isA<MetadataRejected>());
      final rejected = result as MetadataRejected;
      expect(rejected.kind, MetadataFailureKind.rateLimited);
      expect(rejected.retryAfter, const Duration(seconds: 120));
    });

    // Catches losing an HTTP-date Retry-After delay or computing it from the
    // wall clock instead of the injected clock.
    test("maps HTTP-date Retry-After for 429", () async {
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(
          const Stream.empty(),
          429,
          headers: {"retry-after": "Sat, 01 Aug 2026 10:02:30 GMT"},
        ),
      );

      final result = await MetadataFetchClient(
        client: client,
        now: () => DateTime.utc(2026, 8, 1, 10),
      ).fetch("https://example.com/rate-limited");

      expect(result, isA<MetadataRejected>());
      expect(
        (result as MetadataRejected).retryAfter,
        const Duration(seconds: 150),
      );
    });

    // Catches accepting bot-protection HTML as page metadata at the HTTP
    // boundary even though it has a title.
    test("rejects challenge HTML", () async {
      const body = """
        <html>
          <head><title>Just a moment...</title></head>
          <body><script src="/cdn-cgi/challenge-platform/cf-chl-js"></script></body>
        </html>
      """;
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(
          Stream.value(body.codeUnits),
          200,
          headers: {"content-type": "text/html"},
        ),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/protected");

      expect(result, isA<MetadataRejected>());
      expect((result as MetadataRejected).kind, MetadataFailureKind.challenge);
    });

    // Catches decoding a direct image as HTML instead of returning an image
    // candidate for its resolved URL.
    test("returns direct image content as a modified candidate", () async {
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(
          Stream.value([0xff, 0xd8, 0xff, 0xd9]),
          200,
          headers: {
            "content-type": "image/jpeg",
            "etag": '"image-v1"',
            "last-modified": "Sat, 01 Aug 2026 10:00:00 GMT",
          },
        ),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://cdn.example.com/preview.jpg");

      expect(result, isA<MetadataModified>());
      final modified = result as MetadataModified;
      expect(modified.candidate.title, isNull);
      expect(
        modified.candidate.imageUrl,
        "https://cdn.example.com/preview.jpg",
      );
      expect(modified.candidate.resolvedUrl,
          "https://cdn.example.com/preview.jpg");
      expect(modified.candidate.etag, '"image-v1"');
      expect(
        modified.candidate.lastModified,
        "Sat, 01 Aug 2026 10:00:00 GMT",
      );
      expect(modified.responseBytes, 4);
    });

    // Catches buffering or draining bytes after the two MiB cap is crossed.
    test("does not read beyond the two MiB body limit", () async {
      var completed = false;
      final body = Stream<List<int>>.fromIterable(
        List.generate(2050, (_) => List<int>.filled(1024, 65)),
      ).transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleDone: (sink) {
            completed = true;
            sink.close();
          },
        ),
      );
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(
          body,
          200,
          headers: {"content-type": "text/html"},
        ),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/post");

      expect(result, isA<MetadataRejected>());
      expect((result as MetadataRejected).kind, MetadataFailureKind.oversized);
      expect(completed, isFalse);
    });

    // Catches returning late work after the total timeout or leaving an
    // abort-capable HTTP request running in the background.
    test("times out and aborts the active request", () async {
      var abortObserved = false;
      final client = ScriptedClient((request) async {
        if (request is! http.AbortableRequest) {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return http.StreamedResponse(
            Stream.value("<title>Late response</title>".codeUnits),
            200,
            headers: {"content-type": "text/html"},
          );
        }
        await request.abortTrigger!;
        abortObserved = true;
        throw http.RequestAbortedException(request.url);
      });

      final result = await MetadataFetchClient(
        client: client,
        totalTimeout: const Duration(milliseconds: 10),
      ).fetch("https://example.com/slow");
      await Future<void>.delayed(Duration.zero);

      expect(result, isA<MetadataFetchFailed>());
      expect(
        (result as MetadataFetchFailed).kind,
        MetadataFailureKind.timeout,
      );
      expect(abortObserved, isTrue);
    });

    // Catches leaking a normal network exception through the structured
    // metadata boundary.
    test("returns transport failure for a client exception", () async {
      final client = ScriptedClient((request) async {
        throw http.ClientException("connection refused", request.url);
      });

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/offline");

      expect(result, isA<MetadataFetchFailed>());
      final failed = result as MetadataFetchFailed;
      expect(failed.kind, MetadataFailureKind.transport);
      expect(failed.reason, contains("connection refused"));
    });

    // Catches leaking validators from a prior canonical response to the
    // original or an unrelated cross-origin redirect hop.
    test("only sends validators when a redirect reaches their resource",
        () async {
      final seen = <Uri>[];
      final client = ScriptedClient((request) async {
        seen.add(request.url);
        if (request.url == Uri.parse("https://original.example/post")) {
          expect(request.headers["if-none-match"], isNull);
          expect(request.headers["if-modified-since"], isNull);
          return http.StreamedResponse(
            const Stream.empty(),
            302,
            headers: {"location": "https://tracker.example/hop"},
          );
        }
        if (request.url == Uri.parse("https://tracker.example/hop")) {
          expect(request.headers["if-none-match"], isNull);
          expect(request.headers["if-modified-since"], isNull);
          return http.StreamedResponse(
            const Stream.empty(),
            302,
            headers: {"location": "https://canonical.example/post"},
          );
        }
        expect(request.url, Uri.parse("https://canonical.example/post"));
        expect(request.headers["if-none-match"], '"canonical-v1"');
        expect(
          request.headers["if-modified-since"],
          "Sat, 01 Aug 2026 10:00:00 GMT",
        );
        return http.StreamedResponse(const Stream.empty(), 304);
      });

      final result = await MetadataFetchClient(client: client).fetch(
        "https://original.example/post",
        previous: Metadata(
          url: "https://original.example/post",
          resolvedUrl: "https://canonical.example/post",
          fetchedAt: DateTime.utc(2026),
          etag: '"canonical-v1"',
          lastModified: "Sat, 01 Aug 2026 10:00:00 GMT",
        ),
      );

      expect(result, isA<MetadataNotModified>());
      expect(seen, hasLength(3));
    });

    // Catches hashing decoded text, response metadata, or nothing instead of
    // the exact accepted response bytes. The FNV-1a value is hand-checked.
    test("hashes accepted bytes with deterministic 64-bit FNV-1a", () async {
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(
          Stream.value("hello".codeUnits),
          200,
          headers: {"content-type": "image/png"},
        ),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://cdn.example.com/hello.png");

      expect(result, isA<MetadataModified>());
      expect(
        (result as MetadataModified).candidate.contentHash,
        "a430d84680aabd0b",
      );
    });

    // Catches reading and parsing a response whose media type is outside the
    // supported HTML/image boundary.
    test("rejects unsupported content type before reading the body", () async {
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(
          Stream.error(StateError("body must not be read")),
          200,
          headers: {"content-type": "application/json"},
        ),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/api");

      expect(result, isA<MetadataRejected>());
      expect(
        (result as MetadataRejected).kind,
        MetadataFailureKind.unsupportedContentType,
      );
    });

    // Catches leaking malformed HTML bytes as a FormatException instead of a
    // structured decoding rejection.
    test("rejects invalid UTF-8 HTML as decoding failure", () async {
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(
          Stream.value([0xff]),
          200,
          headers: {"content-type": "text/html; charset=utf-8"},
        ),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/broken");

      expect(result, isA<MetadataRejected>());
      expect((result as MetadataRejected).kind, MetadataFailureKind.decoding);
    });

    // Catches parsing an ordinary non-success response body or losing its
    // generic HTTP status classification.
    test("maps other non-2xx status without reading the body", () async {
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(
          Stream.error(StateError("error body must not be read")),
          500,
          headers: {"content-type": "text/html"},
        ),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/unavailable");

      expect(result, isA<MetadataRejected>());
      final rejected = result as MetadataRejected;
      expect(rejected.kind, MetadataFailureKind.httpStatus);
      expect(rejected.statusCode, 500);
    });

    // Catches abandoning response bodies on redirect and early terminal
    // outcomes, which can retain sockets and prevent connection reuse.
    test("cancels every unconsumed early response stream", () async {
      final redirect = CancellableResponse(
        302,
        headers: {"location": "/resolved"},
      );
      var redirectRequests = 0;
      final redirectResult = await MetadataFetchClient(
        client: ScriptedClient((_) async {
          redirectRequests++;
          if (redirectRequests == 1) return redirect.response;
          return http.StreamedResponse(
            Stream.value("<title>Resolved</title>".codeUnits),
            200,
            headers: {"content-type": "text/html"},
          );
        }),
      ).fetch("https://example.com/original");
      expect(redirectResult, isA<MetadataModified>());
      expect(redirect.cancelled, isTrue);

      final notModified = CancellableResponse(304);
      await MetadataFetchClient(
        client: ScriptedClient((_) async => notModified.response),
      ).fetch(
        "https://example.com/post",
        previous: Metadata(
          url: "https://example.com/post",
          fetchedAt: DateTime.utc(2026),
          etag: '"v1"',
        ),
      );
      expect(notModified.cancelled, isTrue);

      for (final response in [
        CancellableResponse(
          200,
          headers: {"content-type": "application/json"},
        ),
        CancellableResponse(403),
        CancellableResponse(429),
        CancellableResponse(500),
      ]) {
        await MetadataFetchClient(
          client: ScriptedClient((_) async => response.response),
        ).fetch("https://example.com/early-exit");
        expect(
          response.cancelled,
          isTrue,
          reason: "status ${response.statusCode} retained its response stream",
        );
      }
    });

    // Catches cancellation failures escaping the external response boundary.
    test("returns transport failure when response cancellation fails",
        () async {
      final controller = StreamController<List<int>>(
        onCancel: () => Future<void>.error(StateError("cancel failed")),
      );
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(controller.stream, 403),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/blocked");

      expect(result, isA<MetadataFetchFailed>());
      final failed = result as MetadataFetchFailed;
      expect(failed.kind, MetadataFailureKind.transport);
      expect(failed.reason, contains("cancel failed"));
    });

    // Catches treating an unsolicited 304 on a redirect target as proof that
    // metadata validated for a different resource is still current.
    test("rejects redirect-target 304 when that request sent no validator",
        () async {
      final unsolicited = CancellableResponse(304);
      var requests = 0;
      final client = ScriptedClient((request) async {
        requests++;
        if (requests == 1) {
          expect(request.headers["if-none-match"], '"original-v1"');
          return http.StreamedResponse(
            const Stream.empty(),
            302,
            headers: {"location": "https://other.example/target"},
          );
        }
        expect(request.headers["if-none-match"], isNull);
        return unsolicited.response;
      });

      final result = await MetadataFetchClient(client: client).fetch(
        "https://example.com/post",
        previous: Metadata(
          url: "https://example.com/post",
          fetchedAt: DateTime.utc(2026),
          etag: '"original-v1"',
        ),
      );

      expect(result, isA<MetadataRejected>());
      final rejected = result as MetadataRejected;
      expect(rejected.kind, MetadataFailureKind.httpStatus);
      expect(rejected.statusCode, 304);
      expect(unsolicited.cancelled, isTrue);
    });

    // Catches malformed Location values escaping URI resolution after a
    // redirect response has already been received.
    test("rejects malformed redirect Location after canceling its stream",
        () async {
      final redirect = CancellableResponse(
        302,
        headers: {"location": "https://[::1"},
      );
      final client = ScriptedClient((_) async => redirect.response);

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/original");

      expect(result, isA<MetadataRejected>());
      final rejected = result as MetadataRejected;
      expect(rejected.kind, MetadataFailureKind.malformed);
      expect(rejected.statusCode, 302);
      expect(redirect.cancelled, isTrue);
    });

    // Catches non-http exceptions from the external response stream escaping
    // the structured fetch-result boundary.
    test("returns transport failure for a raw response stream error", () async {
      final client = ScriptedClient(
        (_) async => http.StreamedResponse(
          Stream.error(StateError("socket stream failed")),
          200,
          headers: {"content-type": "text/html"},
        ),
      );

      final result = await MetadataFetchClient(client: client)
          .fetch("https://example.com/interrupted");

      expect(result, isA<MetadataFetchFailed>());
      final failed = result as MetadataFetchFailed;
      expect(failed.kind, MetadataFailureKind.transport);
      expect(failed.reason, contains("socket stream failed"));
      expect(failed.elapsed, isA<Duration>());
    });
  });
}
