import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;
import "package:meta/meta.dart";
import "package:path_provider/path_provider.dart";
import "package:platform_provider/platform_provider.dart";

/// Downloads the Monolith executable.
class MonolithDownloader {
  /// Timeout for the GitHub release-metadata API call.
  static const Duration defaultApiTimeout = Duration(seconds: 30);

  /// Timeout for streaming the binary to disk.
  static const Duration defaultDownloadTimeout = Duration(minutes: 5);

  /// Downloads the latest release of Monolith from GitHub and writes it to
  /// disk, returning the saved-file path.
  ///
  /// - Both HTTP calls have timeouts and share one `http.Client`.
  /// - The binary is **streamed** to disk via `Stream.pipe` — previously the
  ///   entire executable was buffered in memory via `http.readBytes` before
  ///   any write.
  /// - Pass [client] to reuse a caller-owned HTTP client (test fixtures,
  ///   batch operations). When omitted, an internal client is created and
  ///   closed in a `finally`.
  static Future<String> downloadLatestRelease({
    http.Client? client,
    Duration apiTimeout = defaultApiTimeout,
    Duration downloadTimeout = defaultDownloadTimeout,
  }) async {
    const githubApiUrl =
        "https://api.github.com/repos/Y2Z/monolith/releases/latest";

    final ownedClient = client == null ? http.Client() : null;
    final activeClient = client ?? ownedClient!;
    try {
      final response =
          await activeClient.get(Uri.parse(githubApiUrl)).timeout(apiTimeout);

      if (response.statusCode != 200) {
        throw Exception(
            "Failed to fetch Monolith release info: HTTP ${response.statusCode}");
      }

      final releaseData = json.decode(response.body) as Map<String, dynamic>;
      final assets = releaseData["assets"] as List;

      if (!OperatingSystem.current.isDesktop) {
        throw UnsupportedError("Unsupported platform");
      }
      final assetName =
          OperatingSystem.current.resources.monolithExecutableName;

      final asset = assets.firstWhere((a) => a["name"] == assetName);
      final downloadUrl = asset["browser_download_url"] as String;

      final appDir = await getApplicationDocumentsDirectory();
      final saveDir = Directory("${appDir.path}/chenron");
      await saveDir.create(recursive: true);

      final savePath = "${saveDir.path}/$assetName";
      await downloadToFile(
        activeClient,
        Uri.parse(downloadUrl),
        savePath,
        timeout: downloadTimeout,
      );

      return savePath;
    } finally {
      ownedClient?.close();
    }
  }

  /// Streams a remote URL into [savePath] using [client].
  ///
  /// Exposed for testing — `downloadLatestRelease` is its only production
  /// caller. On any error during streaming, the partial file is deleted so
  /// retries start from a clean state.
  @visibleForTesting
  static Future<void> downloadToFile(
    http.Client client,
    Uri downloadUrl,
    String savePath, {
    required Duration timeout,
  }) async {
    final request = http.Request("GET", downloadUrl);
    final streamed = await client.send(request).timeout(timeout);

    if (streamed.statusCode != 200) {
      throw Exception(
          "Failed to download from $downloadUrl: HTTP ${streamed.statusCode}");
    }

    final file = File(savePath);
    final sink = file.openWrite();
    try {
      await streamed.stream.pipe(sink);
    } catch (_) {
      // `Stream.pipe` typically closes the sink itself, but `close()` is
      // safe to call twice — fail-safe in case the error path skipped it.
      try {
        await sink.close();
      } catch (_) {
        // Already closed by pipe.
      }
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }
}
