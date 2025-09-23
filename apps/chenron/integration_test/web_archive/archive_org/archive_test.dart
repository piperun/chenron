import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chenron/utils/web_archive/archive_org/archive_org.dart';
import 'package:chenron/test_support/path_provider_fake.dart';
import 'package:chenron/test_support/logger_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  installFakePathProvider();
  installTestLogger();

  late ArchiveOrgClient archiveClient;

  // Offline tests: use a fake client via the factory to avoid network calls.
  group("[offline] ArchiveOrgClient", () {
    setUpAll(() {
      archiveOrgClientFactory = (k, s) => _FakeArchiveOrgClient();
      archiveClient = archiveOrgClientFactory('', '');
    });

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
  });

  // Online tests: require credentials in environment variables.
  final key = Platform.environment['CHENRON_ARCHIVE_ORG_KEY'];
  final secret = Platform.environment['CHENRON_ARCHIVE_ORG_SECRET'];
  final haveCreds = (key != null && key.isNotEmpty && secret != null && secret.isNotEmpty);

  group("[online] ArchiveOrgClient", skip: haveCreds ? false : 'Set CHENRON_ARCHIVE_ORG_KEY and CHENRON_ARCHIVE_ORG_SECRET to run online tests', () {
    setUpAll(() {
      archiveOrgClientFactory = (k, s) => ArchiveOrgClient(k, s);
      archiveClient = archiveOrgClientFactory(key!, secret!);
    });

    test("authenticates successfully with valid credentials", () async {
      expect(archiveClient.apiKey, isNotEmpty);
      expect(archiveClient.apiSecret, isNotEmpty);
      expect(await archiveClient.checkAuthentication(), isTrue);
    });

    test("archives a single URL successfully", () async {
      const targetUrl = "https://example.com";
      final archivedUrl = await archiveClient.archiveAndWait(targetUrl);
      expect(archivedUrl, isNotEmpty);
      expect(archivedUrl, contains("web.archive.org/web/"));
    });
  });
}

class _FakeArchiveOrgClient extends ArchiveOrgClient {
  _FakeArchiveOrgClient() : super('', '');

  @override
  Future<bool> checkAuthentication() async => true;

  @override
  Future<String> archiveAndWait(String targetUrl) async {
    return 'https://web.archive.org/web/20990101000000/$targetUrl';
  }
}
