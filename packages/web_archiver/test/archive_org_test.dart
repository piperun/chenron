import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:http/testing.dart";
import "package:web_archiver/src/archive_org/archive_org.dart";

/// Returns a [MockClient] that answers the POST to `/save` with [body] at the
/// given [status]. Any other path returns 404 so unexpected calls are obvious.
MockClient _saveClient(String body, {int status = 200}) {
  return MockClient((request) async {
    if (request.method == "POST" && request.url.path == "/save") {
      return http.Response(body, status, request: request);
    }
    return http.Response("unexpected", 404, request: request);
  });
}

ArchiveOrgClient _client(MockClient http) =>
    ArchiveOrgClient("key", "secret", client: http);

void main() {
  group("ArchiveOrgClient.archiveUrl parsing", () {
    test("returns the snapshot URL on a well-formed success response",
        () async {
      final client = _client(_saveClient(jsonEncode({
        "status": "success",
        "archived_snapshots": {
          "closest": {
            "url": "https://web.archive.org/web/20231027120000/https://x.com",
          }
        },
      })));

      final result = await client.archiveUrl("https://x.com");

      expect(result,
          equals("https://web.archive.org/web/20231027120000/https://x.com"));
    });

    test("returns the job_id when status is pending", () async {
      final client = _client(_saveClient(jsonEncode({
        "status": "pending",
        "job_id": "spn2-abcdef",
      })));

      final result = await client.archiveUrl("https://x.com");

      expect(result, equals("spn2-abcdef"));
    });

    test("returns the job_id for an unknown status that carries a job_id",
        () async {
      // Falls into the default branch; a present, non-empty job_id is treated
      // as "in progress".
      final client = _client(_saveClient(jsonEncode({
        "status": "queued",
        "job_id": "spn2-queued-1",
      })));

      final result = await client.archiveUrl("https://x.com");

      expect(result, equals("spn2-queued-1"));
    });

    test("throws (not NoSuchMethodError) when status is unknown and job_id is "
        "absent", () async {
      // Regression: the default branch used `data['job_id'].isNotEmpty`, which
      // threw NoSuchMethodError on null. A malformed body must surface as a
      // normal Exception, not a crash.
      final client = _client(_saveClient(jsonEncode({
        "status": "weird",
        // no job_id at all
      })));

      await expectLater(
        client.archiveUrl("https://x.com"),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), "message", isNot(contains("NoSuchMethod")))),
      );
    });

    test("throws on an error status, surfacing the message", () async {
      final client = _client(_saveClient(jsonEncode({
        "status": "error",
        "message": "Cannot capture",
        "status_ext": "error:invalid-url",
      })));

      await expectLater(
        client.archiveUrl("https://x.com"),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), "message", contains("Cannot capture"))),
      );
    });

    test("throws (not a crash) when success body lacks archived_snapshots",
        () async {
      // Regression: the success branch chained
      // data['archived_snapshots']['closest']['url'] with no null checks.
      final client = _client(_saveClient(jsonEncode({
        "status": "success",
        // archived_snapshots missing entirely
      })));

      await expectLater(
        client.archiveUrl("https://x.com"),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), "message", isNot(contains("NoSuchMethod")))),
      );
    });

    test("throws when success body has archived_snapshots but closest is null",
        () async {
      final client = _client(_saveClient(jsonEncode({
        "status": "success",
        "archived_snapshots": {"closest": null},
      })));

      await expectLater(
        client.archiveUrl("https://x.com"),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), "message", isNot(contains("NoSuchMethod")))),
      );
    });

    test("throws when success closest.url is missing or not a string",
        () async {
      final client = _client(_saveClient(jsonEncode({
        "status": "success",
        "archived_snapshots": {
          "closest": {"timestamp": "20231027120000"}, // no url
        },
      })));

      await expectLater(
        client.archiveUrl("https://x.com"),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), "message", isNot(contains("NoSuchMethod")))),
      );
    });

    test("throws on a non-200 response", () async {
      final client = _client(_saveClient("upstream exploded", status: 503));

      await expectLater(
        client.archiveUrl("https://x.com"),
        throwsA(isA<Exception>()),
      );
    });

    test("throws (not a crash) on a body that is valid JSON but not an object",
        () async {
      // e.g. the API returns a bare string or array; indexing it must not crash.
      final client = _client(_saveClient(jsonEncode("totally unexpected")));

      await expectLater(
        client.archiveUrl("https://x.com"),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), "message", isNot(contains("NoSuchMethod")))),
      );
    });
  });
}
