import "package:chenron/components/favicon_display/favicon.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("Favicon cache LRU bound", () {
    setUp(Favicon.debugClearCache);

    test("stays bounded at debugMaxCacheSize when over-filled", () {
      final cap = Favicon.debugMaxCacheSize;

      for (var i = 0; i < cap + 100; i++) {
        Favicon.debugPutInCache("https://example$i.test", Future.value(null));
      }

      expect(Favicon.debugCacheSize, equals(cap));
    });

    test("evicts least-recently-inserted entries first", () {
      final cap = Favicon.debugMaxCacheSize;

      for (var i = 0; i < cap; i++) {
        Favicon.debugPutInCache("https://example$i.test", Future.value(null));
      }
      expect(Favicon.debugCacheSize, equals(cap));
      expect(Favicon.debugContains("https://example0.test"), isTrue);

      // One past capacity — oldest entry should evict.
      Favicon.debugPutInCache(
          "https://overflow.test", Future.value(null));

      expect(Favicon.debugCacheSize, equals(cap));
      expect(Favicon.debugContains("https://example0.test"), isFalse);
      expect(Favicon.debugContains("https://overflow.test"), isTrue);
    });

    test("re-inserting an existing url does not grow the cache", () {
      Favicon.debugPutInCache("https://same.test", Future.value(null));
      Favicon.debugPutInCache("https://same.test", Future.value(null));
      Favicon.debugPutInCache("https://same.test", Future.value(null));

      expect(Favicon.debugCacheSize, equals(1));
    });
  });
}
