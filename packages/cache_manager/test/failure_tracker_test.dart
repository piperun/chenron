import "package:cache_manager/cache_manager.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  late FailureTracker tracker;

  setUp(() {
    tracker = FailureTracker();
  });

  group("FailureTracker shouldRetry", () {
    test("returns true for never-failed URL", () {
      expect(tracker.shouldRetry("https://new.com"), isTrue);
    });

    test("returns false immediately after first failure", () {
      tracker.recordFailure("https://fail.com");
      // First back-off step is 2 minutes; immediately after, no retry.
      expect(tracker.shouldRetry("https://fail.com"), isFalse);
    });

    test("clearFailure resets retry to true", () {
      tracker.recordFailure("https://fail.com");
      expect(tracker.shouldRetry("https://fail.com"), isFalse);

      tracker.clearFailure("https://fail.com");
      expect(tracker.shouldRetry("https://fail.com"), isTrue);
    });

    test("many failures don't crash or permanently block past the cap", () {
      // Record more failures than the schedule has entries; the
      // back-off should cap at the last step (24 hr) — still no
      // immediate retry, but the call itself must not throw.
      for (var i = 0; i < 20; i++) {
        tracker.recordFailure("https://fail.com");
      }
      expect(tracker.shouldRetry("https://fail.com"), isFalse);

      tracker.clearFailure("https://fail.com");
      expect(tracker.shouldRetry("https://fail.com"), isTrue);
    });

    test("failure tracking is per-URL", () {
      tracker.recordFailure("https://bad.com");
      expect(tracker.shouldRetry("https://bad.com"), isFalse);
      expect(tracker.shouldRetry("https://good.com"), isTrue);
    });
  });

  group("FailureTracker failureCount", () {
    test("zero for never-failed URL", () {
      expect(tracker.failureCount("https://x.com"), 0);
    });

    test("increments on each recordFailure", () {
      tracker.recordFailure("https://x.com");
      expect(tracker.failureCount("https://x.com"), 1);

      tracker.recordFailure("https://x.com");
      expect(tracker.failureCount("https://x.com"), 2);
    });

    test("clearFailure resets to zero", () {
      tracker.recordFailure("https://x.com");
      tracker.recordFailure("https://x.com");
      tracker.clearFailure("https://x.com");
      expect(tracker.failureCount("https://x.com"), 0);
    });
  });

  group("FailureTracker cleanupStale", () {
    test("recent failures survive cleanup", () {
      tracker.recordFailure("https://recent.com");
      tracker.cleanupStale();
      // Recent failure was not purged — still blocked by back-off.
      expect(tracker.shouldRetry("https://recent.com"), isFalse);
    });

    test("safe to call with no recorded failures", () {
      tracker.cleanupStale();
      expect(tracker.shouldRetry("https://anything.com"), isTrue);
    });

    test("clearFailure + cleanupStale leaves clean state", () {
      tracker.recordFailure("https://a.com");
      tracker.recordFailure("https://b.com");
      tracker.clearFailure("https://a.com");
      tracker.cleanupStale();

      // a.com was cleared explicitly.
      expect(tracker.shouldRetry("https://a.com"), isTrue);
      // b.com is recent — still blocked.
      expect(tracker.shouldRetry("https://b.com"), isFalse);
    });
  });

  group("FailureTracker clearAll", () {
    test("wipes all tracked failures", () {
      tracker.recordFailure("https://a.com");
      tracker.recordFailure("https://b.com");
      tracker.clearAll();

      expect(tracker.shouldRetry("https://a.com"), isTrue);
      expect(tracker.shouldRetry("https://b.com"), isTrue);
      expect(tracker.failureCount("https://a.com"), 0);
      expect(tracker.failureCount("https://b.com"), 0);
    });
  });
}
