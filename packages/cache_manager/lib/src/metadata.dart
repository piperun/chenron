import "package:freezed_annotation/freezed_annotation.dart";

part "metadata.freezed.dart";
part "metadata.g.dart";

/// A single cached metadata snapshot for one URL.
///
/// Captures the descriptive fields fetched from a web page (title,
/// description, image) alongside the bookkeeping fields the cache uses
/// to decide whether the snapshot is still fresh and how aggressively
/// to refresh it: when it was fetched, its per-entry TTL, an ETag for
/// conditional requests, a content hash for change detection, and a
/// counter of how many consecutive refreshes returned unchanged
/// content (drives the adaptive-TTL back-off).
@freezed
abstract class Metadata with _$Metadata {
  const factory Metadata({
    required String url,
    String? title,
    String? description,
    String? imageUrl,
    required DateTime fetchedAt,
    @Default(7) int ttlDays,
    String? etag,
    String? contentHash,
    @Default(0) int consecutiveUnchanged,
  }) = _Metadata;

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);
}
