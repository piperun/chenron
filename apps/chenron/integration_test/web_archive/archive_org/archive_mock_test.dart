import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:web_archiver/web_archiver.dart";
import "package:chenron/test_support/archive_org_mock.dart";
import "package:chenron/test_support/logger_setup.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  installTestLogger();

  group("ArchiveOrgClient - Mock Tests", () {
    group("Immediate Success Behavior", () {
      late MockArchiveOrgClient client;

      setUp(() {
        client = MockArchiveOrgClient(
          behavior: MockBehavior.immediateSuccess,
        );
      });

      test("archiveUrl returns archived URL immediately", () async {
        const targetUrl = "https://example.com";
        final result = await client.archiveUrl(targetUrl);

        expect(result, startsWith("https://web.archive.org/web/"));
        expect(result, contains(targetUrl));
      });

      test("archiveAndWait completes successfully", () async {
        const targetUrl = "https://flutter.dev";
        final archivedUrl = await client.archiveAndWait(targetUrl);

        expect(archivedUrl, isNotEmpty);
        expect(archivedUrl, contains("web.archive.org"));
        expect(archivedUrl, contains(targetUrl));
      });

      test("multiple URLs can be archived sequentially", () async {
        final urls = [
          "https://example.com",
          "https://flutter.dev",
          "https://dart.dev",
        ];

        for (final url in urls) {
          final archived = await client.archiveUrl(url);
          expect(archived, contains(url));
        }
      });

      test("authentication check succeeds", () async {
        final isAuthenticated = await client.checkAuthentication();
        expect(isAuthenticated, isTrue);
      });
    });

    group("Pending Behavior", () {
      late MockArchiveOrgClient client;

      setUp(() {
        client = MockArchiveOrgClient(
          behavior: MockBehavior.pending,
          pendingCount: 3,
          delayMs: 5,
        );
      });

      tearDown(() {
        client.reset();
      });

      test("archiveUrl returns job ID", () async {
        const targetUrl = "https://example.com";
        final jobId = await client.archiveUrl(targetUrl);

        expect(jobId, startsWith("spn2-"));
        expect(jobId, isNot(contains("http")));
      });

      test("checkStatus returns pending then success", () async {
        const targetUrl = "https://example.com";
        final jobId = await client.archiveUrl(targetUrl);

        // First call should be pending
        final status1 = await client.checkStatus(jobId);
        expect(status1["status"], equals("pending"));

        // Second call should be pending
        final status2 = await client.checkStatus(jobId);
        expect(status2["status"], equals("pending"));

        // Third call should succeed
        final status3 = await client.checkStatus(jobId);
        expect(status3["status"], equals("success"));
        expect(status3["archived_snapshots"]["closest"]["url"], isNotEmpty);
      });

      test("waitForCompletion polls until success", () async {
        const targetUrl = "https://example.com";
        final jobId = await client.archiveUrl(targetUrl);

        final archivedUrl = await client.waitForCompletion(jobId);

        expect(archivedUrl, startsWith("https://web.archive.org/web/"));
      });

      test("archiveAndWait handles pending job", () async {
        const targetUrl = "https://example.com";

        final archivedUrl = await client.archiveAndWait(targetUrl);

        expect(archivedUrl, isNotEmpty);
        expect(archivedUrl, contains("web.archive.org"));
      });
    });

    group("Error Behavior", () {
      late MockArchiveOrgClient client;

      setUp(() {
        client = MockArchiveOrgClient(
          behavior: MockBehavior.error,
          errorMessage: "Custom error message",
        );
      });

      test("archiveUrl throws exception", () async {
        expect(
          () => client.archiveUrl("https://example.com"),
          throwsA(isA<Exception>()),
        );
      });

      test("archiveAndWait throws exception", () async {
        expect(
          () => client.archiveAndWait("https://example.com"),
          throwsA(isA<Exception>()),
        );
      });

      test("error contains custom message", () async {
        try {
          await client.archiveUrl("https://example.com");
          fail("Should have thrown an exception");
        } catch (e) {
          expect(e.toString(), contains("Custom error message"));
        }
      });

      test("checkStatus returns error status", () async {
        final status = await client.checkStatus("fake-job-id");

        expect(status["status"], equals("error"));
        expect(status["message"], equals("Custom error message"));
      });
    });

    group("Invalid URL Behavior", () {
      late MockArchiveOrgClient client;

      setUp(() {
        client = MockArchiveOrgClient(
          behavior: MockBehavior.invalidUrl,
        );
      });

      test("throws ArgumentError for invalid URL", () async {
        expect(
          () => client.archiveUrl("not-a-url"),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group("Rate Limited Behavior", () {
      late MockArchiveOrgClient client;

      setUp(() {
        client = MockArchiveOrgClient(
          behavior: MockBehavior.rateLimited,
        );
      });

      test("throws rate limit exception", () async {
        try {
          await client.archiveUrl("https://example.com");
          fail("Should have thrown an exception");
        } catch (e) {
          expect(e.toString(), contains("Rate limit"));
        }
      });
    });

    group("Options Handling", () {
      late MockArchiveOrgClient client;

      setUp(() {
        client = MockArchiveOrgClient(
          behavior: MockBehavior.optionsRespected,
        );
      });

      test("default options result has standard timestamp", () async {
        const targetUrl = "https://example.com";
        final result = await client.archiveUrl(targetUrl);

        expect(result, contains("20990101000000"));
      });

      test("forceGet option changes timestamp", () async {
        const targetUrl = "https://example.com";
        final options = ArchiveOrgOptions(forceGet: true);

        final result = await client.archiveUrl(targetUrl, options: options);

        expect(result, contains("20990102000000"));
      });

      test("options are passed through archiveAndWait", () async {
        const targetUrl = "https://example.com";
        final options = ArchiveOrgOptions(forceGet: true);

        final result = await client.archiveAndWait(targetUrl, options: options);

        expect(result, contains("20990102000000"));
      });

      test("various options can be set", () {
        final options = ArchiveOrgOptions(
          captureAll: true,
          captureOutlinks: true,
          captureScreenshot: true,
          forceGet: true,
          jsBehaviorTimeout: 10,
        );

        final json = options.toJson();

        expect(json["capture_all"], equals(1));
        expect(json["capture_outlinks"], equals(1));
        expect(json["capture_screenshot"], equals(1));
        expect(json["force_get"], equals(1));
        expect(json["js_behavior_timeout"], equals(10));
      });

      test("ifNotArchivedWithin option", () {
        final options = ArchiveOrgOptions(
          ifNotArchivedWithin: "2d",
        );

        final json = options.toJson();

        expect(json["if_not_archived_within"], equals("2d"));
      });

      test("default options have correct values", () {
        final options = ArchiveOrgOptions();
        final json = options.toJson();

        expect(json["capture_all"], equals(0));
        expect(json["capture_outlinks"], equals(0));
        expect(json["force_get"], equals(0));
        expect(json["js_behavior_timeout"], equals(5));
      });
    });

    group("Authentication", () {
      test("successful authentication", () async {
        final client = MockArchiveOrgClient(authSuccess: true);
        expect(await client.checkAuthentication(), isTrue);
      });

      test("failed authentication", () async {
        final client = MockArchiveOrgClient(authSuccess: false);
        expect(await client.checkAuthentication(), isFalse);
      });

      test("credentials are stored", () {
        final client = MockArchiveOrgClient();
        expect(client.apiKey, equals("mock_key"));
        expect(client.apiSecret, equals("mock_secret"));
      });
    });

    group("Edge Cases", () {
      test("empty URL", () async {
        final client = MockArchiveOrgClient(
          behavior: MockBehavior.invalidUrl,
        );

        expect(
          () => client.archiveUrl(""),
          throwsA(isA<ArgumentError>()),
        );
      });

      test("very long URL", () async {
        final client = MockArchiveOrgClient();
        final longUrl = "https://example.com/${"a" * 2000}";

        final result = await client.archiveUrl(longUrl);

        expect(result, contains("web.archive.org"));
      });

      test("URL with special characters", () async {
        final client = MockArchiveOrgClient();
        const specialUrl =
            "https://example.com/path?param=value&other=123#fragment";

        final result = await client.archiveUrl(specialUrl);

        expect(result, contains("web.archive.org"));
      });

      test("multiple concurrent archive requests", () async {
        final client = MockArchiveOrgClient(delayMs: 50);

        final futures = List.generate(
          5,
          (i) => client.archiveUrl("https://example$i.com"),
        );

        final results = await Future.wait(futures);

        expect(results.length, equals(5));
        for (final result in results) {
          expect(result, contains("web.archive.org"));
        }
      });

      test("reset clears internal state", () async {
        final client = MockArchiveOrgClient(
          behavior: MockBehavior.pending,
          pendingCount: 2,
        );

        final jobId = await client.archiveUrl("https://example.com");

        // First check - should be pending
        var status = await client.checkStatus(jobId);
        expect(status["status"], equals("pending"));

        // Reset
        client.reset();

        // After reset, same job should still work but counter is reset
        status = await client.checkStatus(jobId);
        expect(status["status"], equals("pending"));
      });
    });

    group("URL Format Validation", () {
      late MockArchiveOrgClient client;

      setUp(() {
        client = MockArchiveOrgClient();
      });

      test("HTTPS URL is accepted", () async {
        final result = await client.archiveUrl("https://example.com");
        expect(result, isNotEmpty);
      });

      test("HTTP URL is accepted", () async {
        final result = await client.archiveUrl("http://example.com");
        expect(result, isNotEmpty);
      });

      test("URL with path", () async {
        final result =
            await client.archiveUrl("https://example.com/path/to/page");
        expect(result, contains("example.com/path/to/page"));
      });

      test("URL with query parameters", () async {
        final result = await client.archiveUrl("https://example.com?q=search");
        expect(result, isNotEmpty);
      });

      test("URL with fragment", () async {
        final result = await client.archiveUrl("https://example.com#section");
        expect(result, isNotEmpty);
      });
    });
  });
}
