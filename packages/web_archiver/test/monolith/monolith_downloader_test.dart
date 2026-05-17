import "dart:async";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:http/http.dart" as http;
import "package:web_archiver/src/monolith/monolith_downloader.dart";

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp
        .createTemp("monolith_downloader_test_");
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group("MonolithDownloader.downloadToFile", () {
    test("streams a 200 response into the target file", () async {
      final body = List<int>.generate(64 * 1024, (i) => i & 0xff);
      final client = _StreamingMockClient((request) {
        return _ok(body);
      });

      final savePath = "${tempDir.path}/binary.bin";
      await MonolithDownloader.downloadToFile(
        client,
        Uri.parse("https://example.test/monolith.bin"),
        savePath,
        timeout: const Duration(seconds: 5),
      );

      final file = File(savePath);
      expect(await file.exists(), isTrue);
      expect(await file.length(), body.length);
      expect(await file.readAsBytes(), body);
    });

    test("throws on non-200 status and does not leave a stale file",
        () async {
      final client = _StreamingMockClient((request) {
        return http.StreamedResponse(
          Stream<List<int>>.empty(),
          404,
        );
      });

      final savePath = "${tempDir.path}/missing.bin";
      await expectLater(
        MonolithDownloader.downloadToFile(
          client,
          Uri.parse("https://example.test/missing.bin"),
          savePath,
          timeout: const Duration(seconds: 5),
        ),
        throwsA(isA<Exception>()),
      );

      expect(await File(savePath).exists(), isFalse,
          reason: "non-200 must not leave an empty placeholder on disk");
    });

    test("deletes the partial file when the stream errors mid-download",
        () async {
      final controller = StreamController<List<int>>();
      // Emit some bytes, then error.
      controller.add(const [1, 2, 3, 4]);
      controller.addError(const SocketException("connection reset"));
      // Don't close — the consumer is expected to bail on the error.

      final client = _StreamingMockClient((request) {
        return http.StreamedResponse(controller.stream, 200);
      });

      final savePath = "${tempDir.path}/partial.bin";
      await expectLater(
        MonolithDownloader.downloadToFile(
          client,
          Uri.parse("https://example.test/partial.bin"),
          savePath,
          timeout: const Duration(seconds: 5),
        ),
        throwsA(isA<SocketException>()),
      );

      expect(await File(savePath).exists(), isFalse,
          reason: "partial file must be cleaned up on stream error");

      await controller.close();
    });

    test("times out when the send Future never resolves", () async {
      final client = _StreamingMockClient((request) async {
        // Never completes — the .timeout() in downloadToFile must fire.
        await Completer<void>().future;
        return _ok(const []);
      });

      final savePath = "${tempDir.path}/timeout.bin";
      await expectLater(
        MonolithDownloader.downloadToFile(
          client,
          Uri.parse("https://example.test/slow.bin"),
          savePath,
          timeout: const Duration(milliseconds: 50),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}

http.StreamedResponse _ok(List<int> body) {
  return http.StreamedResponse(
    Stream<List<int>>.fromIterable([body]),
    200,
    contentLength: body.length,
  );
}

/// MockClient is the `package:http/testing.dart` helper for unit responses,
/// but it converts handlers into a `StreamedResponse` from `Response.body`
/// — losing the ability to test true streaming. This shim implements
/// `BaseClient.send` directly with a handler that returns a
/// `StreamedResponse`, so the stream the test feeds in is the stream the
/// production code consumes.
class _StreamingMockClient extends http.BaseClient {
  final FutureOr<http.StreamedResponse> Function(http.BaseRequest) _handler;

  _StreamingMockClient(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return await _handler(request);
  }
}
