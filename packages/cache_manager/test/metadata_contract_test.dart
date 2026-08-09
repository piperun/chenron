import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("available state keeps data while refresh fails", () {
    final metadata = Metadata(
      url: "https://media.example/index.php?page=post&s=list&tags=sampletag",
      title: "Media / sampletag",
      fetchedAt: DateTime.utc(2026, 8, 1),
    );
    const failure = MetadataRefreshFailure(
      kind: MetadataFailureKind.blocked,
      reason: "challenge page",
      attemptCount: 2,
      statusCode: 403,
      nextRetryAt: null,
    );

    final state = MetadataState.available(
      data: metadata,
      freshness: MetadataFreshness.stale,
      refreshPhase: MetadataRefreshPhase.failed,
      lastFailure: failure,
    );

    expect(state, isA<MetadataStateAvailable>());
    expect(
      (state as MetadataStateAvailable).data.title,
      "Media / sampletag",
    );
    expect(state.lastFailure, failure);
  });

  test("refresh summary counts every terminal category", () {
    const summary = MetadataRefreshSummary(
      updated: 1,
      unchanged: 2,
      skipped: 3,
      rejected: 4,
      failed: 5,
    );
    expect(summary.total, 15);
  });
}
