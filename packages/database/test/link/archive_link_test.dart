import "dart:async";

import "package:database/database.dart";
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

    test(
        "does not hold a write transaction across the network call",
        () async {
      // The archive round-trip (archiveAndWait) can take minutes against the
      // real Archive.org API. It must NOT run inside an open write
      // transaction, or it blocks every other writer on the single SQLite
      // connection for the whole HTTP duration. This test gates that: while
      // the archive is mid-flight, a concurrent write must still complete.
      final created = await database.createLink(
        link: "https://example.com/blocking",
      );

      final blockingClient = _BlockingArchiveOrgClient();

      // Start the archive but do not await it — it parks on the completer
      // inside archiveAndWait, standing in for a slow network round-trip.
      final archiveFuture = database.archiveLink(
        created.linkId,
        accessKey: "test-key",
        secretKey: "test-secret",
        client: blockingClient,
      );

      // Wait until archiveAndWait has actually been entered (the network
      // call is in flight) before probing for the lock.
      await blockingClient.started.future;

      // A concurrent write must complete while the archive is still
      // blocked. If archiveLink held a write transaction open across the
      // network call, this insert would never resolve (the test would hang
      // and time out).
      final concurrentWrite = database.createLink(
        link: "https://example.com/concurrent",
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw StateError(
          "Concurrent write blocked: archiveLink held the write "
          "transaction across the network call.",
        ),
      );

      final concurrent = await concurrentWrite;
      final concurrentRow = await database.getLink(linkId: concurrent.linkId);
      expect(concurrentRow, isNotNull,
          reason: "concurrent write should persist while archive is pending");

      // Now release the archive and confirm the URL still lands.
      blockingClient.release("https://web.archive.org/web/fake/blocked");
      await archiveFuture;

      final archivedRow = await database.getLink(linkId: created.linkId);
      expect(
        archivedRow!.data.archiveOrgUrl,
        equals("https://web.archive.org/web/fake/blocked"),
      );
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

/// Archive client whose [archiveAndWait] parks on a [Completer] until the
/// test releases it, simulating a slow network round-trip. [started]
/// completes once the call has been entered so the test can probe the lock
/// while the archive is genuinely in flight.
class _BlockingArchiveOrgClient extends ArchiveOrgClient {
  final Completer<void> started = Completer<void>();
  final Completer<String> _gate = Completer<String>();

  _BlockingArchiveOrgClient() : super("fake", "fake");

  void release(String archivedUrl) => _gate.complete(archivedUrl);

  @override
  Future<String> archiveAndWait(String targetUrl,
      {ArchiveOrgOptions? options}) async {
    if (!started.isCompleted) started.complete();
    return _gate.future;
  }
}
