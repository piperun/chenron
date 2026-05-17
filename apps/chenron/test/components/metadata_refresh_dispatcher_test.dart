import "package:chenron/components/metadata_refresh_dispatcher.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("MetadataRefreshDispatcher", () {
    late MetadataRefreshDispatcher dispatcher;

    setUp(() {
      dispatcher = MetadataRefreshDispatcher();
    });

    test("dispatch wakes only the subscribers for that url", () {
      var aHits = 0;
      var bHits = 0;
      dispatcher.subscribe("https://a", () => aHits++);
      dispatcher.subscribe("https://b", () => bHits++);

      dispatcher.dispatch("https://a");
      expect(aHits, 1);
      expect(bHits, 0);

      dispatcher.dispatch("https://b");
      expect(aHits, 1);
      expect(bHits, 1);
    });

    test("repeated dispatches for the same url all fire", () {
      // Regression: the previous implementation used a single
      // Signal<String?> and had to bump null between consecutive writes
      // of the same URL because Signal dedupes on ==. The dispatcher
      // model has no such workaround — every dispatch must fire.
      var hits = 0;
      dispatcher.subscribe("https://same", () => hits++);

      dispatcher.dispatch("https://same");
      dispatcher.dispatch("https://same");
      dispatcher.dispatch("https://same");

      expect(hits, 3);
    });

    test("multiple subscribers on the same url all fire on dispatch", () {
      final hits = <String>[];
      dispatcher.subscribe("https://x", () => hits.add("a"));
      dispatcher.subscribe("https://x", () => hits.add("b"));
      dispatcher.subscribe("https://x", () => hits.add("c"));

      dispatcher.dispatch("https://x");

      expect(hits, containsAll(["a", "b", "c"]));
      expect(hits, hasLength(3));
    });

    test("dispose function detaches the subscriber", () {
      var hits = 0;
      final dispose = dispatcher.subscribe("https://x", () => hits++);

      dispatcher.dispatch("https://x");
      expect(hits, 1);

      dispose();
      dispatcher.dispatch("https://x");
      expect(hits, 1);
    });

    test("dispose prunes the url entry when set goes empty", () {
      final disposeA = dispatcher.subscribe("https://x", () {});
      final disposeB = dispatcher.subscribe("https://x", () {});

      expect(dispatcher.debugTrackedUrlCount, 1);
      disposeA();
      expect(dispatcher.debugTrackedUrlCount, 1);
      disposeB();
      expect(dispatcher.debugTrackedUrlCount, 0);
    });

    test("dispatch for an unknown url is a no-op", () {
      // Smoke: must not throw, must not allocate listener storage.
      dispatcher.dispatch("https://nobody-cares");
      expect(dispatcher.debugTrackedUrlCount, 0);
    });

    test("subscriber that disposes during dispatch does not break iteration",
        () {
      final hits = <String>[];
      late void Function() disposeB;
      dispatcher.subscribe("https://x", () => hits.add("a"));
      disposeB = dispatcher.subscribe("https://x", () {
        hits.add("b");
        disposeB();
      });
      dispatcher.subscribe("https://x", () => hits.add("c"));

      dispatcher.dispatch("https://x");

      expect(hits, containsAll(["a", "b", "c"]));
    });
  });
}
