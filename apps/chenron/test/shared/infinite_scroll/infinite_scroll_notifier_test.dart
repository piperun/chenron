import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:chenron/shared/infinite_scroll/infinite_scroll_notifier.dart";

/// Controllable page source for driving [InfiniteScrollNotifier] under test.
///
/// Each call to [load] returns the page configured for the current call
/// index. When [gate] is non-null the returned future does not complete
/// until the test completes it, letting a load be held "in flight" while
/// other operations (e.g. [InfiniteScrollNotifier.reset]) run.
class _FakeLoader {
  /// Pages to hand out, indexed by call order.
  final List<List<int>> pages;

  /// When set, [load] awaits this before returning [pages] for that call.
  Completer<void>? gate;

  /// When true the next [load] throws instead of returning a page.
  bool throwOnNext = false;

  /// When true every [load] throws — models a persistently failing source
  /// (e.g. a closed/corrupt database).
  bool throwAlways = false;

  /// Offsets observed on each call, in order.
  final List<int> seenOffsets = [];

  int _calls = 0;

  _FakeLoader(this.pages);

  int get callCount => _calls;

  Future<List<int>> load(int limit, int offset) async {
    final index = _calls;
    _calls++;
    seenOffsets.add(offset);

    final gateToAwait = gate;
    if (gateToAwait != null) {
      await gateToAwait.future;
    }

    if (throwAlways) {
      throw StateError("loader down");
    }
    if (throwOnNext) {
      throwOnNext = false;
      throw StateError("loader boom");
    }

    if (index < pages.length) return pages[index];
    return const [];
  }
}

List<int> _range(int start, int count) =>
    List<int>.generate(count, (i) => start + i);

void main() {
  group("page boundary / hasMore", () {
    test("a full page leaves hasMore true", () async {
      final loader = _FakeLoader([_range(0, 50)]);
      final notifier = InfiniteScrollNotifier<int>(
        loader: loader.load,
        pageSize: 50,
      );
      addTearDown(notifier.dispose);

      await notifier.loadNextPage();

      expect(notifier.loadedItems.value, hasLength(50));
      expect(notifier.hasMore.value, isTrue);
    });

    test("a short page clears hasMore", () async {
      final loader = _FakeLoader([_range(0, 30)]);
      final notifier = InfiniteScrollNotifier<int>(
        loader: loader.load,
        pageSize: 50,
      );
      addTearDown(notifier.dispose);

      await notifier.loadNextPage();

      expect(notifier.loadedItems.value, hasLength(30));
      expect(notifier.hasMore.value, isFalse);
      expect(notifier.isFullyLoaded, isTrue);
    });

    test("an empty last page stops paging", () async {
      final loader = _FakeLoader([_range(0, 50), const []]);
      final notifier = InfiniteScrollNotifier<int>(
        loader: loader.load,
        pageSize: 50,
      );
      addTearDown(notifier.dispose);

      await notifier.loadNextPage(); // 50, hasMore stays true
      await notifier.loadNextPage(); // empty page -> hasMore false

      expect(notifier.loadedItems.value, hasLength(50));
      expect(notifier.hasMore.value, isFalse);
      expect(loader.seenOffsets, [0, 50]);
    });
  });

  group("re-entrancy guard", () {
    test("a second loadNextPage while one is in flight is a no-op", () async {
      final loader = _FakeLoader([_range(0, 50), _range(50, 50)]);
      loader.gate = Completer<void>();
      final notifier = InfiniteScrollNotifier<int>(
        loader: loader.load,
        pageSize: 50,
      );
      addTearDown(notifier.dispose);

      final first = notifier.loadNextPage();
      // Second call should bail immediately on the isLoadingMore guard.
      await notifier.loadNextPage();
      expect(loader.callCount, 1);

      loader.gate!.complete();
      await first;

      expect(loader.callCount, 1);
      expect(notifier.loadedItems.value, hasLength(50));
    });
  });

  group("reset vs in-flight load", () {
    test("an in-flight page resolving after reset is discarded", () async {
      // First page is gated so it is still awaiting the loader when
      // reset() runs. Its continuation must NOT append onto the freshly
      // cleared list nor advance the offset.
      final loader = _FakeLoader([_range(0, 50), _range(100, 10)]);
      loader.gate = Completer<void>();
      final notifier = InfiniteScrollNotifier<int>(
        loader: loader.load,
        pageSize: 50,
      );
      addTearDown(notifier.dispose);

      final stale = notifier.loadNextPage();

      // Simulate folder refresh mid-flight.
      notifier.reset();

      // Let the stale loader finish.
      loader.gate!.complete();
      await stale;

      // The stale page must have been dropped entirely.
      expect(notifier.loadedItems.value, isEmpty);
      expect(notifier.hasMore.value, isTrue);
      expect(notifier.isLoadingMore.value, isFalse);

      // A fresh page after reset starts from offset 0, not 50.
      loader.gate = null;
      await notifier.loadNextPage();
      expect(notifier.loadedItems.value, _range(100, 10));
      // The post-reset load reads offset 0, proving the offset was not
      // bumped by the discarded stale page.
      expect(loader.seenOffsets.last, 0);
    });

    test("reset frees the guard so a fresh load can start", () async {
      final gate = Completer<void>();
      final loader = _FakeLoader([_range(0, 50), _range(0, 20)]);
      loader.gate = gate;
      final notifier = InfiniteScrollNotifier<int>(
        loader: loader.load,
        pageSize: 50,
      );
      addTearDown(notifier.dispose);

      final stale = notifier.loadNextPage(); // holds the guard
      notifier.reset(); // must reopen the guard

      // Ungate so the fresh load (and the eventual stale completion) can
      // proceed. The fresh load should be allowed to run because reset()
      // cleared isLoadingMore, and it should read offset 0.
      loader.gate = null;
      gate.complete();
      await notifier.loadNextPage();
      expect(notifier.loadedItems.value, _range(0, 20));

      await stale; // stale completes, still discarded
      expect(notifier.loadedItems.value, _range(0, 20));
    });
  });

  group("loader errors degrade gracefully", () {
    test("a throwing loader does not propagate and stays recoverable",
        () async {
      // First call throws; the retry (call index 1) serves the page.
      final loader = _FakeLoader([_range(0, 50), _range(0, 50)]);
      loader.throwOnNext = true;
      final notifier = InfiniteScrollNotifier<int>(
        loader: loader.load,
        pageSize: 50,
      );
      addTearDown(notifier.dispose);

      // Must not throw out of loadNextPage.
      await notifier.loadNextPage();

      expect(notifier.loadedItems.value, isEmpty);
      expect(notifier.isLoadingMore.value, isFalse);
      // hasMore preserved so the user can retry.
      expect(notifier.hasMore.value, isTrue);

      // Retry succeeds and appends normally.
      await notifier.loadNextPage();
      expect(notifier.loadedItems.value, hasLength(50));
    });

    test("loadInitial does not surface a loader error to its caller",
        () async {
      final loader = _FakeLoader([_range(0, 50)]);
      loader.throwOnNext = true;
      final notifier = InfiniteScrollNotifier<int>(
        loader: loader.load,
        pageSize: 50,
      );
      addTearDown(notifier.dispose);

      // Should complete normally despite the loader throwing.
      await expectLater(notifier.loadInitial(), completes);
      expect(notifier.loadedItems.value, isEmpty);
    });

    test("loadAll stops instead of spinning when the loader fails", () async {
      // Page 0 succeeds (full page, hasMore stays true); from then on the
      // loader is down. A swallowed error keeps hasMore true, so loadAll
      // must break on the error instead of retrying the failing page
      // forever.
      final loader = _FakeLoader([_range(0, 50)]);
      final notifier = InfiniteScrollNotifier<int>(
        loader: loader.load,
        pageSize: 50,
      );
      addTearDown(notifier.dispose);

      await notifier.loadNextPage(); // page 0 ok
      loader.throwAlways = true; // every subsequent page fails

      await notifier.loadAll().timeout(
            const Duration(seconds: 5),
            onTimeout: () =>
                fail("loadAll spun on a persistently failing loader"),
          );

      expect(notifier.hasError, isTrue);
      expect(notifier.loadedItems.value, hasLength(50));
    });
  });
}
