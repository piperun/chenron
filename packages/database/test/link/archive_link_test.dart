import "package:database/main.dart";
import "package:database/src/features/link/archive.dart";
import "package:database/src/features/link/create.dart";
import "package:database/src/features/link/read.dart";
import "package:web_archiver/web_archiver.dart";
import "package:flutter_test/flutter_test.dart";
import "package:chenron_mockups/chenron_mockups.dart";

void main() {
  setUpAll(() {
    installFakePathProvider();
    installTestLogger();
  });

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase(
      databaseName: "test_db",
      setupOnInit: true,
      debugMode: true,
    );
  });

  tearDown(() async {
    final links = database.links;
    await database.delete(links).go();
    await database.close();
  });

  group("archiveLink()", () {
    test("archives link and stores URL in database", () async {
      final created = await database.createLink(
        link: "https://example.com/page",
      );

      final fakeClient = _FakeArchiveOrgClient();

      await database.archiveLink(
        created.linkId,
        accessKey: "test-key",
        secretKey: "test-secret",
        client: fakeClient,
      );

      final linkResult = await database.getLink(linkId: created.linkId);
      expect(linkResult, isNotNull);
      expect(
        linkResult!.data.archiveOrgUrl,
        equals("https://web.archive.org/web/fake/https://example.com/page"),
      );
    });

    test("non-existent link ID throws StateError", () async {
      final fakeClient = _FakeArchiveOrgClient();

      await expectLater(
        database.archiveLink(
          "non_existent_link_id",
          accessKey: "test-key",
          secretKey: "test-secret",
          client: fakeClient,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test("archive failure rethrows and does not update link", () async {
      final created = await database.createLink(
        link: "https://example.com/fail",
      );

      final failingClient = _FakeArchiveOrgClient(shouldFail: true);

      await expectLater(
        database.archiveLink(
          created.linkId,
          accessKey: "test-key",
          secretKey: "test-secret",
          client: failingClient,
        ),
        throwsA(isA<Exception>()),
      );

      // Verify link was not updated
      final linkResult = await database.getLink(linkId: created.linkId);
      expect(linkResult!.data.archiveOrgUrl, isNull);
    });

    test("passes options to client", () async {
      final created = await database.createLink(
        link: "https://example.com/with-options",
      );

      final fakeClient = _FakeArchiveOrgClient();
      final options = ArchiveOrgOptions(captureAll: true, forceGet: true);

      await database.archiveLink(
        created.linkId,
        accessKey: "test-key",
        secretKey: "test-secret",
        client: fakeClient,
        options: options,
      );

      expect(fakeClient.lastOptions, isNotNull);
      expect(fakeClient.lastOptions!.captureAll, isTrue);
      expect(fakeClient.lastOptions!.forceGet, isTrue);
    });
  });

  group("batchArchiveLinks()", () {
    test("archives multiple links", () async {
      final link1 = await database.createLink(
        link: "https://example.com/batch1",
      );
      final link2 = await database.createLink(
        link: "https://example.com/batch2",
      );

      final fakeClient = _FakeArchiveOrgClient();

      await database.batchArchiveLinks(
        [link1.linkId, link2.linkId],
        accessKey: "test-key",
        secretKey: "test-secret",
        client: fakeClient,
      );

      final result1 = await database.getLink(linkId: link1.linkId);
      final result2 = await database.getLink(linkId: link2.linkId);

      expect(result1!.data.archiveOrgUrl, isNotNull);
      expect(result2!.data.archiveOrgUrl, isNotNull);
      expect(fakeClient.archiveCallCount, equals(2));
    });

    test("empty list is a no-op", () async {
      final fakeClient = _FakeArchiveOrgClient();

      await database.batchArchiveLinks(
        [],
        accessKey: "test-key",
        secretKey: "test-secret",
        client: fakeClient,
      );

      expect(fakeClient.archiveCallCount, equals(0));
    });
  });
}

class _FakeArchiveOrgClient extends ArchiveOrgClient {
  final bool shouldFail;
  int archiveCallCount = 0;
  ArchiveOrgOptions? lastOptions;

  _FakeArchiveOrgClient({this.shouldFail = false}) : super("fake", "fake");

  @override
  Future<String> archiveAndWait(String targetUrl,
      {ArchiveOrgOptions? options}) async {
    archiveCallCount++;
    lastOptions = options;
    if (shouldFail) {
      throw Exception("Simulated archive failure");
    }
    return "https://web.archive.org/web/fake/$targetUrl";
  }
}
