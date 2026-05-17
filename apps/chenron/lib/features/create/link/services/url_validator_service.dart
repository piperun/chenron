import "dart:async";
import "dart:io";
import "package:http/http.dart" as http;

class UrlValidationResult {
  final bool isValid;
  final bool isReachable;
  final String? message;
  final int? statusCode;

  UrlValidationResult({
    required this.isValid,
    required this.isReachable,
    this.message,
    this.statusCode,
  });

  bool get isSuccess => isValid && isReachable;
}

class UrlValidatorService {
  static const Duration _timeout = Duration(seconds: 3);

  /// Default in-flight cap for [validateUrls]. Bulk-import flows used to
  /// fire `Future.wait` across every URL at once, which spun up a fresh
  /// HTTP connection per row (top-level `http.head` / `http.get` allocate
  /// a one-shot Client). 8 is a safe ceiling for residential connections
  /// — large enough to keep latency low, small enough to avoid storming
  /// remote hosts or exhausting local sockets.
  static const int defaultConcurrency = 8;

  /// Validates URL format
  static bool isValidUrlFormat(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Performs async validation: checks DNS resolution and HTTP status.
  ///
  /// Pass [client] to reuse one HTTP client across many validations
  /// (lets the underlying socket pool kick in). When omitted a throw-away
  /// client is implicit via the top-level `http.head`/`http.get` helpers.
  static Future<UrlValidationResult> validateUrl(
    String url, {
    http.Client? client,
  }) async {
    if (!isValidUrlFormat(url)) {
      return UrlValidationResult(
        isValid: false,
        isReachable: false,
        message: "Invalid URL format",
      );
    }

    try {
      final uri = Uri.parse(url);

      // Check DNS resolution
      final addresses = await InternetAddress.lookup(
        uri.host,
        type: InternetAddressType.any,
      ).timeout(_timeout);

      if (addresses.isEmpty) {
        return UrlValidationResult(
          isValid: true,
          isReachable: false,
          message: "Domain not found",
        );
      }

      // Check HTTP status
      try {
        final response = await _head(uri, client)
            .timeout(_timeout)
            .catchError((_) => _get(uri, client).timeout(_timeout));

        final isReachable =
            response.statusCode >= 200 && response.statusCode < 400;

        return UrlValidationResult(
          isValid: true,
          isReachable: isReachable,
          statusCode: response.statusCode,
          message: isReachable
              ? "URL is reachable"
              : "URL returned status ${response.statusCode}",
        );
      } on TimeoutException {
        return UrlValidationResult(
          isValid: true,
          isReachable: false,
          message: "Request timed out",
        );
      } on http.ClientException {
        return UrlValidationResult(
          isValid: true,
          isReachable: false,
          message: "Unable to connect",
        );
      }
    } on SocketException {
      return UrlValidationResult(
        isValid: true,
        isReachable: false,
        message: "Domain not found",
      );
    } on TimeoutException {
      return UrlValidationResult(
        isValid: true,
        isReachable: false,
        message: "DNS lookup timed out",
      );
    } catch (e) {
      return UrlValidationResult(
        isValid: true,
        isReachable: false,
        message: "Validation error: $e",
      );
    }
  }

  static Future<http.Response> _head(Uri uri, http.Client? client) =>
      client != null ? client.head(uri) : http.head(uri);

  static Future<http.Response> _get(Uri uri, http.Client? client) =>
      client != null ? client.get(uri) : http.get(uri);

  /// Batch validate multiple URLs with bounded concurrency and a single
  /// shared HTTP client.
  ///
  /// At most [concurrency] requests are in flight at any time. Pass a
  /// [client] to bring your own — useful for tests with `MockClient`,
  /// and for batched callers (e.g. bulk import) that already own a
  /// client. Otherwise an internal one is created and closed in a
  /// `finally`.
  static Future<Map<String, UrlValidationResult>> validateUrls(
    List<String> urls, {
    int concurrency = defaultConcurrency,
    http.Client? client,
  }) async {
    final results = <String, UrlValidationResult>{};
    if (urls.isEmpty) return results;

    final ownedClient = client == null ? http.Client() : null;
    final activeClient = client ?? ownedClient!;
    try {
      for (var i = 0; i < urls.length; i += concurrency) {
        final end =
            (i + concurrency < urls.length) ? i + concurrency : urls.length;
        final chunk = urls.sublist(i, end);
        await Future.wait(chunk.map((url) async {
          results[url] = await validateUrl(url, client: activeClient);
        }));
      }
      return results;
    } finally {
      ownedClient?.close();
    }
  }
}
