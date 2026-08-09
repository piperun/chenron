import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:cache_manager/cache_manager.dart";
import "package:chenron/services/metadata/metadata_parser.dart";
import "package:chenron/services/metadata/metadata_quality.dart";
import "package:http/http.dart" as http;

String contentHash(List<int> bytes) {
  var hash = BigInt.parse("cbf29ce484222325", radix: 16);
  final prime = BigInt.parse("100000001b3", radix: 16);
  final mask = BigInt.parse("ffffffffffffffff", radix: 16);
  for (final byte in bytes) {
    hash ^= BigInt.from(byte);
    hash = (hash * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, "0");
}

final class _MetadataTransportException implements Exception {
  final Object error;

  const _MetadataTransportException(this.error);
}

class MetadataFetchClient {
  static const defaultMaxBodyBytes = 2 * 1024 * 1024;
  static const defaultMaxRedirects = 5;
  static const defaultTotalTimeout = Duration(seconds: 15);

  final http.Client _client;
  final int maxBodyBytes;
  final int maxRedirects;
  final Duration totalTimeout;
  final DateTime Function() _now;

  MetadataFetchClient({
    http.Client? client,
    this.maxBodyBytes = defaultMaxBodyBytes,
    this.maxRedirects = defaultMaxRedirects,
    this.totalTimeout = defaultTotalTimeout,
    DateTime Function()? now,
  })  : _client = client ?? http.Client(),
        _now = now ?? DateTime.now;

  Future<MetadataFetchResult> fetch(String url, {Metadata? previous}) async {
    final stopwatch = Stopwatch()..start();
    final abort = Completer<void>();
    try {
      return await _fetch(
        Uri.parse(url),
        requestedUrl: url,
        previous: previous,
        stopwatch: stopwatch,
        redirectCount: 0,
        abortTrigger: abort.future,
      ).timeout(
        totalTimeout,
        onTimeout: () {
          if (!abort.isCompleted) abort.complete();
          return MetadataFetchFailed(
            kind: MetadataFailureKind.timeout,
            reason: "metadata request exceeded ${totalTimeout.inSeconds}s",
            elapsed: stopwatch.elapsed,
          );
        },
      );
    } on http.ClientException catch (error) {
      return MetadataFetchFailed(
        kind: MetadataFailureKind.transport,
        reason: error.message,
        elapsed: stopwatch.elapsed,
      );
    } on _MetadataTransportException catch (error) {
      return MetadataFetchFailed(
        kind: MetadataFailureKind.transport,
        reason: error.error.toString(),
        elapsed: stopwatch.elapsed,
      );
    }
  }

  Future<MetadataFetchResult> _fetch(
    Uri uri, {
    required String requestedUrl,
    required Metadata? previous,
    required Stopwatch stopwatch,
    required int redirectCount,
    required Future<void> abortTrigger,
  }) async {
    final request = http.AbortableRequest(
      "GET",
      uri,
      abortTrigger: abortTrigger,
    )
      ..followRedirects = false
      ..maxRedirects = 0
      ..headers["accept"] = "text/html,application/xhtml+xml,image/*"
      ..headers["user-agent"] = "Chenron/metadata";

    var sentValidators = false;
    if (_isValidatorResource(uri, previous)) {
      if (previous?.etag case final etag?) {
        request.headers["if-none-match"] = etag;
        sentValidators = true;
      }
      if (previous?.lastModified case final lastModified?) {
        request.headers["if-modified-since"] = lastModified;
        sentValidators = true;
      }
    }

    final response = await _client.send(request);
    if (_isRedirect(response.statusCode)) {
      final location = response.headers["location"];
      if (location != null) {
        await _cancelResponse(response);
        if (redirectCount >= maxRedirects) {
          return MetadataRejected(
            kind: MetadataFailureKind.tooManyRedirects,
            reason: "metadata request exceeded $maxRedirects redirects",
            statusCode: response.statusCode,
            elapsed: stopwatch.elapsed,
          );
        }
        late final Uri redirectUri;
        try {
          redirectUri = uri.resolve(location);
        } on FormatException catch (error) {
          return MetadataRejected(
            kind: MetadataFailureKind.malformed,
            reason: error.message,
            statusCode: response.statusCode,
            elapsed: stopwatch.elapsed,
          );
        }
        return _fetch(
          redirectUri,
          requestedUrl: requestedUrl,
          previous: previous,
          stopwatch: stopwatch,
          redirectCount: redirectCount + 1,
          abortTrigger: abortTrigger,
        );
      }
    }

    if (response.statusCode == 304 && sentValidators) {
      await _cancelResponse(response);
      return MetadataNotModified(
        resolvedUrl: uri.toString(),
        etag: response.headers["etag"],
        lastModified: response.headers["last-modified"],
        elapsed: stopwatch.elapsed,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final contentType = response.headers["content-type"];
      final mimeType = contentType?.split(";").first.trim().toLowerCase();
      final isImage = mimeType?.startsWith("image/") ?? false;
      final isHtml =
          mimeType == "text/html" || mimeType == "application/xhtml+xml";
      if (!isImage && !isHtml) {
        await _cancelResponse(response);
        return MetadataRejected(
          kind: MetadataFailureKind.unsupportedContentType,
          reason: "unsupported metadata content type: ${contentType ?? "none"}",
          statusCode: response.statusCode,
          elapsed: stopwatch.elapsed,
        );
      }

      final bytes = BytesBuilder(copy: false);
      try {
        await for (final chunk in response.stream) {
          if (bytes.length + chunk.length > maxBodyBytes) {
            return MetadataRejected(
              kind: MetadataFailureKind.oversized,
              reason: "metadata response exceeded $maxBodyBytes bytes",
              statusCode: response.statusCode,
              elapsed: stopwatch.elapsed,
            );
          }
          bytes.add(chunk);
        }
      } catch (error) {
        throw _MetadataTransportException(error);
      }
      final bodyBytes = bytes.takeBytes();
      if (isImage) {
        return MetadataModified(
          candidate: MetadataCandidate(
            imageUrl: uri.toString(),
            resolvedUrl: uri.toString(),
            etag: response.headers["etag"],
            lastModified: response.headers["last-modified"],
            contentHash: contentHash(bodyBytes),
          ),
          statusCode: response.statusCode,
          responseBytes: bodyBytes.length,
          elapsed: stopwatch.elapsed,
        );
      }
      late final String body;
      try {
        body = utf8.decode(bodyBytes);
      } on FormatException catch (error) {
        return MetadataRejected(
          kind: MetadataFailureKind.decoding,
          reason: error.message,
          statusCode: response.statusCode,
          elapsed: stopwatch.elapsed,
        );
      }
      final parsed = parseMetadataDocument(body, baseUri: uri);
      final decision = evaluateMetadataQuality(
        requestedUrl: requestedUrl,
        resolvedUrl: uri.toString(),
        statusCode: response.statusCode,
        contentType: response.headers["content-type"],
        body: body,
        parsed: parsed,
      );
      if (decision is AcceptedMetadataQuality) {
        final candidate = decision.candidate;
        return MetadataModified(
          candidate: MetadataCandidate(
            title: candidate.title,
            description: candidate.description,
            imageUrl: candidate.imageUrl,
            resolvedUrl: candidate.resolvedUrl,
            etag: response.headers["etag"],
            lastModified: response.headers["last-modified"],
            contentHash: contentHash(bodyBytes),
          ),
          statusCode: response.statusCode,
          responseBytes: bodyBytes.length,
          elapsed: stopwatch.elapsed,
        );
      }
      final rejected = decision as RejectedMetadataQuality;
      return MetadataRejected(
        kind: rejected.kind,
        reason: rejected.reason,
        statusCode: response.statusCode,
        elapsed: stopwatch.elapsed,
      );
    }

    if (response.statusCode == 429) {
      await _cancelResponse(response);
      return MetadataRejected(
        kind: MetadataFailureKind.rateLimited,
        reason: "HTTP status 429",
        statusCode: response.statusCode,
        retryAfter: _retryAfter(response.headers["retry-after"]),
        elapsed: stopwatch.elapsed,
      );
    }

    if (response.statusCode == 403) {
      await _cancelResponse(response);
      return MetadataRejected(
        kind: MetadataFailureKind.blocked,
        reason: "HTTP status 403",
        statusCode: response.statusCode,
        elapsed: stopwatch.elapsed,
      );
    }

    await _cancelResponse(response);
    return MetadataRejected(
      kind: MetadataFailureKind.httpStatus,
      reason: "HTTP status ${response.statusCode}",
      statusCode: response.statusCode,
      elapsed: stopwatch.elapsed,
    );
  }

  Future<void> _cancelResponse(http.StreamedResponse response) async {
    try {
      final subscription = response.stream.listen(null);
      await subscription.cancel();
    } catch (error) {
      throw _MetadataTransportException(error);
    }
  }

  Duration? _retryAfter(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value);
    if (seconds != null) return Duration(seconds: seconds);
    try {
      return HttpDate.parse(value).difference(_now().toUtc());
    } on FormatException {
      return null;
    }
  }

  bool _isRedirect(int statusCode) =>
      statusCode == 301 ||
      statusCode == 302 ||
      statusCode == 303 ||
      statusCode == 307 ||
      statusCode == 308;

  bool _isValidatorResource(Uri uri, Metadata? previous) {
    if (previous == null) return false;
    final validatorUrl = previous.resolvedUrl ?? previous.url;
    return uri == Uri.tryParse(validatorUrl);
  }

  void close() => _client.close();
}
