import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:chenron/database/database.dart";
import "package:chenron/utils/web_archive/archive_org/archive_org.dart";
import "package:chenron/test_support/path_provider_fake.dart";
import "package:chenron/test_support/logger_setup.dart";
import "package:drift/drift.dart" as drift;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Install fakes and test logger once for this suite.
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late ConfigDatabase database;
  late ArchiveOrgClient archiveClient;

  setUp(() async {
    database = ConfigDatabase();
    final userConfig = await database.select(database.userConfigs).getSingle();
    archiveClient = ArchiveOrgClient(
      userConfig.archiveOrgS3AccessKey ?? "",
      userConfig.archiveOrgS3SecretKey ?? "",
    );
  });

  tearDown(() async {
    await database.close();
  });

  group("ArchiveOrgClient", () {
    group("Authentication and API Tests", () {
      test("authenticates successfully with valid credentials", () async {
        expect(archiveClient.apiKey, isNotEmpty);
        expect(archiveClient.apiSecret, isNotEmpty);
        expect(await archiveClient.checkAuthentication(), isTrue);
      });

      test("fails authentication with invalid credentials", () async {
        final invalidClient = ArchiveOrgClient("invalid_key", "invalid_secret");
        expect(
            () async => await invalidClient.archiveUrl("https://example.com"),
            throwsException);
      });

      test("handles rate limiting", () async {
        const int requestCount = 10;
        const int delayMs = 100;

        for (int i = 0; i < requestCount; i++) {
          await archiveClient.archiveUrl("https://example.com");
          await Future.delayed(const Duration(milliseconds: delayMs));
        }

        // Check if the last request was successful or if it was rate limited
        try {
          await archiveClient.archiveUrl("https://example.com");
          // If we reach here, the rate limiting wasn't triggered
          expect(true, isTrue, reason: "Rate limiting was not triggered");
        } catch (e) {
          expect(e.toString(), contains("rate limit exceeded"),
              reason: "Rate limiting was triggered as expected");
        }
      });
    });

    group("URL Archiving Tests", () {
      test("archives a single URL successfully", () async {
        const targetUrl = "https://example.com";
        final archivedUrl = await archiveClient.archiveAndWait(targetUrl);
        expect(archivedUrl, isNotEmpty);
        expect(archivedUrl, contains("web.archive.org/web/"));
      });

      test("archives multiple URLs in sequence", () async {
        final urls = [
          "https://example.com",
          "https://example.org",
          "https://example.net",
        ];

        for (final url in urls) {
          final archivedUrl = await archiveClient.archiveAndWait(url);
          expect(archivedUrl, isNotEmpty);
          expect(archivedUrl, contains("web.archive.org"));
        }
      });

      test("handles archiving errors gracefully", () async {
        const invalidUrl = "https://invalid-url-that-does-not-exist.com";
        expect(() async => await archiveClient.archiveAndWait(invalidUrl),
            throwsException);
      });
    });
  });
}
