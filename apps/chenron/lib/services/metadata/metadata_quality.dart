import "package:cache_manager/cache_manager.dart";
import "package:chenron/services/metadata/metadata_parser.dart";

sealed class MetadataQualityDecision {
  const MetadataQualityDecision();
}

final class AcceptedMetadataQuality extends MetadataQualityDecision {
  final MetadataCandidate candidate;

  const AcceptedMetadataQuality(this.candidate);
}

final class RejectedMetadataQuality extends MetadataQualityDecision {
  final MetadataFailureKind kind;
  final String reason;

  const RejectedMetadataQuality(this.kind, this.reason);
}

MetadataQualityDecision evaluateMetadataQuality({
  required String requestedUrl,
  required String resolvedUrl,
  required int statusCode,
  required String? contentType,
  required String body,
  required ParsedMetadata parsed,
}) {
  if (statusCode < 200 || statusCode >= 300) {
    final kind = switch (statusCode) {
      403 => MetadataFailureKind.blocked,
      429 => MetadataFailureKind.rateLimited,
      _ => MetadataFailureKind.httpStatus,
    };
    return RejectedMetadataQuality(kind, "HTTP status $statusCode");
  }

  if (_isChallengeDocument(body, parsed.title)) {
    return const RejectedMetadataQuality(
      MetadataFailureKind.challenge,
      "Challenge document",
    );
  }

  final title = isDomainPlaceholderTitle(parsed.title, requestedUrl)
      ? null
      : _collapseWhitespace(parsed.title);
  final description = _collapseWhitespace(parsed.description);
  final usableDescription =
      description == requestedUrl || description == resolvedUrl
          ? null
          : description;
  final imageUrl = _usableImageUrl(parsed.imageUrl);

  if (title == null && usableDescription == null && imageUrl == null) {
    return const RejectedMetadataQuality(
      MetadataFailureKind.noUsableMetadata,
      "No usable metadata",
    );
  }

  return AcceptedMetadataQuality(MetadataCandidate(
    title: title,
    description: usableDescription,
    imageUrl: imageUrl,
    resolvedUrl: resolvedUrl,
  ));
}

String? _usableImageUrl(String? value) {
  final uri = value == null ? null : Uri.tryParse(value);
  if (uri == null || (uri.scheme != "http" && uri.scheme != "https")) {
    return null;
  }
  const videoExtensions = [".mp4", ".webm", ".mov", ".avi", ".mkv", ".flv"];
  if (videoExtensions
      .any((extension) => uri.path.toLowerCase().endsWith(extension))) {
    return null;
  }
  return uri.toString();
}

bool _isChallengeDocument(String body, String? title) {
  final normalizedTitle = title?.toLowerCase() ?? "";
  final hasChallengeTitle = normalizedTitle.contains("just a moment") ||
      normalizedTitle.contains("attention required") ||
      normalizedTitle.contains("checking your browser");
  if (!hasChallengeTitle) return false;

  final normalizedBody = body.toLowerCase();
  return normalizedBody.contains("cf-chl-") ||
      normalizedBody.contains("__cf_chl_") ||
      normalizedBody.contains("/cdn-cgi/challenge-platform/") ||
      RegExp(r"<form\\b[^>]+(?:challenge|captcha|interstitial)").hasMatch(
        normalizedBody,
      );
}

/// Whether [title] only identifies the requested site's domain.
///
/// This supplements cache_manager's default-title heuristic for visual
/// equivalents such as "Media" and the `media` host core.
bool isDomainPlaceholderTitle(String? title, String url) {
  if (isDefaultTitle(title, url)) return true;

  final uri = Uri.tryParse(url);
  if (title == null || uri == null || uri.host.isEmpty) return false;

  final normalizedTitle = _alphanumeric(title);
  final hostCore = uri.host
      .toLowerCase()
      .replaceFirst(RegExp(r"^www\."), "")
      .split(".")
      .first;
  final normalizedHostCore = _alphanumeric(hostCore);
  return normalizedTitle.length >= 3 && normalizedTitle == normalizedHostCore;
}

String? _collapseWhitespace(String? value) {
  if (value == null) return null;
  final collapsed = value.replaceAll(RegExp(r"\s+"), " ").trim();
  return collapsed.isEmpty ? null : collapsed;
}

String _alphanumeric(String value) =>
    value.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), "");
