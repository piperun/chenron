import "package:cache_manager/src/metadata_fetch_result.dart";
import "package:cache_manager/src/metadata_state.dart";

/// Whether cached metadata is within its freshness lifetime.
enum MetadataFreshness { fresh, stale }

/// The progress of a refresh while a metadata state remains observable.
enum MetadataRefreshPhase { idle, refreshing, failed }

/// Terminal result of a metadata refresh attempt.
enum MetadataRefreshOutcome { updated, unchanged, skipped, rejected, failed }

/// Information about the last unsuccessful refresh attempt.
class MetadataRefreshFailure {
  final MetadataFailureKind kind;
  final String reason;
  final int attemptCount;
  final int? statusCode;
  final DateTime? nextRetryAt;

  const MetadataRefreshFailure({
    required this.kind,
    required this.reason,
    required this.attemptCount,
    this.statusCode,
    this.nextRetryAt,
  });
}

/// State and terminal outcome for one refreshed URL.
class MetadataRefreshResult {
  final String url;
  final MetadataRefreshOutcome outcome;
  final MetadataState state;

  const MetadataRefreshResult({
    required this.url,
    required this.outcome,
    required this.state,
  });
}

/// Counts terminal outcomes from a bulk refresh run.
class MetadataRefreshSummary {
  final int updated;
  final int unchanged;
  final int skipped;
  final int rejected;
  final int failed;

  const MetadataRefreshSummary({
    this.updated = 0,
    this.unchanged = 0,
    this.skipped = 0,
    this.rejected = 0,
    this.failed = 0,
  });

  int get total => updated + unchanged + skipped + rejected + failed;

  MetadataRefreshSummary add(MetadataRefreshOutcome outcome) =>
      switch (outcome) {
        MetadataRefreshOutcome.updated => copyWith(updated: updated + 1),
        MetadataRefreshOutcome.unchanged => copyWith(unchanged: unchanged + 1),
        MetadataRefreshOutcome.skipped => copyWith(skipped: skipped + 1),
        MetadataRefreshOutcome.rejected => copyWith(rejected: rejected + 1),
        MetadataRefreshOutcome.failed => copyWith(failed: failed + 1),
      };

  MetadataRefreshSummary copyWith({
    int? updated,
    int? unchanged,
    int? skipped,
    int? rejected,
    int? failed,
  }) =>
      MetadataRefreshSummary(
        updated: updated ?? this.updated,
        unchanged: unchanged ?? this.unchanged,
        skipped: skipped ?? this.skipped,
        rejected: rejected ?? this.rejected,
        failed: failed ?? this.failed,
      );
}
