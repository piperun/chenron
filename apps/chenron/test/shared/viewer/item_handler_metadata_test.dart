import "dart:async";
import "dart:math";

import "package:cache_manager/cache_manager.dart";
import "package:chenron/shared/viewer/item_handler.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("refreshMetadataUrls deduplicates, caps workers, and summarizes",
      () async {
    final processed = <String>[];
    var active = 0;
    var maxObserved = 0;
    final gate = Completer<void>();
    final urls = [
      "https://example.com/updated",
      "https://example.com/unchanged",
      "https://example.com/skipped",
      "https://example.com/rejected",
      "https://example.com/failed",
      "https://example.com/updated",
    ];

    final future = refreshMetadataUrls(
      urls,
      maxConcurrent: 3,
      refreshOne: (url) async {
        processed.add(url);
        active++;
        maxObserved = max(maxObserved, active);
        await gate.future;
        active--;
        return _result(
          url,
          MetadataRefreshOutcome.values
              .byName(Uri.parse(url).pathSegments.last),
        );
      },
    );

    await pumpEventQueue();
    expect(maxObserved, 3);

    gate.complete();
    final summary = await future;

    expect(processed.toSet(), urls.toSet());
    expect(processed.length, 5);
    expect(summary.updated, 1);
    expect(summary.unchanged, 1);
    expect(summary.skipped, 1);
    expect(summary.rejected, 1);
    expect(summary.failed, 1);
    expect(summary.total, 5);
  });

  test("metadata refresh message reports every terminal category", () {
    const summary = MetadataRefreshSummary(
      updated: 4,
      unchanged: 7,
      skipped: 2,
      rejected: 1,
    );

    expect(
      metadataRefreshSummaryMessage(summary),
      "Metadata: 4 updated, 7 unchanged, 2 skipped, 1 rejected, 0 failed",
    );
  });

  test("refreshMetadataUrls rejects a non-positive worker cap", () async {
    await expectLater(
      refreshMetadataUrls(
        ["https://example.com/item"],
        refreshOne: (url) async => _result(url, MetadataRefreshOutcome.updated),
        maxConcurrent: 0,
      ),
      throwsArgumentError,
    );
  });
}

MetadataRefreshResult _result(
  String url,
  MetadataRefreshOutcome outcome,
) =>
    MetadataRefreshResult(
      url: url,
      outcome: outcome,
      state: const MetadataState.unavailable(),
    );
