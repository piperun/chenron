/// Categories of unsuccessful metadata retrieval outcomes.
enum MetadataFailureKind {
  blocked,
  rateLimited,
  httpStatus,
  unsupportedContentType,
  oversized,
  timeout,
  tooManyRedirects,
  decoding,
  malformed,
  transport,
  challenge,
  noUsableMetadata,
}

/// Metadata extracted from a successful HTTP response.
class MetadataCandidate {
  final String? title;
  final String? description;
  final String? imageUrl;
  final String resolvedUrl;
  final String? etag;
  final String? lastModified;
  final String? contentHash;

  const MetadataCandidate({
    this.title,
    this.description,
    this.imageUrl,
    required this.resolvedUrl,
    this.etag,
    this.lastModified,
    this.contentHash,
  });
}

/// Structured terminal outcome of a metadata HTTP retrieval.
sealed class MetadataFetchResult {
  const MetadataFetchResult();
}

/// A response whose metadata differs from the previous snapshot.
final class MetadataModified extends MetadataFetchResult {
  final MetadataCandidate candidate;
  final int statusCode;
  final int responseBytes;
  final Duration elapsed;

  const MetadataModified({
    required this.candidate,
    required this.statusCode,
    required this.responseBytes,
    required this.elapsed,
  });
}

/// A conditional request response that confirms the prior snapshot is current.
final class MetadataNotModified extends MetadataFetchResult {
  final String resolvedUrl;
  final String? etag;
  final String? lastModified;
  final Duration elapsed;

  const MetadataNotModified({
    required this.resolvedUrl,
    this.etag,
    this.lastModified,
    required this.elapsed,
  });
}

/// A response that was understood but is ineligible for metadata storage.
final class MetadataRejected extends MetadataFetchResult {
  final MetadataFailureKind kind;
  final String reason;
  final int? statusCode;
  final Duration? retryAfter;
  final Duration elapsed;

  const MetadataRejected({
    required this.kind,
    required this.reason,
    this.statusCode,
    this.retryAfter,
    required this.elapsed,
  });
}

/// A retrieval that did not yield a usable HTTP response.
final class MetadataFetchFailed extends MetadataFetchResult {
  final MetadataFailureKind kind;
  final String reason;
  final int? statusCode;
  final Duration elapsed;

  const MetadataFetchFailed({
    required this.kind,
    required this.reason,
    this.statusCode,
    required this.elapsed,
  });
}
