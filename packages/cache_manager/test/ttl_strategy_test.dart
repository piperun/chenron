import "dart:math";

import "package:cache_manager/src/ttl_strategy.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("computeAdaptiveTtl", () {
    test("base case: unchanged=0 returns baseDays", () {
      expect(computeAdaptiveTtl(consecutiveUnchanged: 0), kDefaultBaseTtlDays);
    });

    test("doubles with each consecutive unchanged refresh", () {
      expect(computeAdaptiveTtl(consecutiveUnchanged: 1), 14);
      expect(computeAdaptiveTtl(consecutiveUnchanged: 2), 28);
      expect(computeAdaptiveTtl(consecutiveUnchanged: 3), 56);
    });

    test("caps at kMaxTtlDays (90)", () {
      // 7 * 2^4 = 112, should clamp to 90
      expect(computeAdaptiveTtl(consecutiveUnchanged: 4), kMaxTtlDays);
      expect(computeAdaptiveTtl(consecutiveUnchanged: 10), kMaxTtlDays);
    });

    test("respects custom maxDays", () {
      expect(
        computeAdaptiveTtl(consecutiveUnchanged: 3, maxDays: 30),
        30,
      );
    });

    test("works with higher baseDays (30)", () {
      // 30 * 2^0 = 30, 30 * 2^1 = 60, 30 * 2^2 = 120 → 90
      expect(computeAdaptiveTtl(baseDays: 30, consecutiveUnchanged: 0), 30);
      expect(computeAdaptiveTtl(baseDays: 30, consecutiveUnchanged: 1), 60);
      expect(computeAdaptiveTtl(baseDays: 30, consecutiveUnchanged: 2), 90);
    });
  });

  group("isDefaultTitle", () {
    test("detects domain name in title (rule34 / rule34.xxx)", () {
      expect(isDefaultTitle("rule34", "https://rule34.xxx/page"), isTrue);
    });

    test("detects title substring in domain (both ways)", () {
      expect(isDefaultTitle("GitHub", "https://github.com/user"), isTrue);
      expect(isDefaultTitle("Welcome to My GitHub Page", "https://github.com"),
          isTrue);
    });

    test("case insensitive comparison", () {
      expect(isDefaultTitle("GITHUB", "https://github.com"), isTrue);
      expect(isDefaultTitle("github", "https://GITHUB.com"), isTrue);
    });

    test("rejects custom titles that don't match domain", () {
      expect(isDefaultTitle("How to bake a cake", "https://recipes.com"),
          isFalse);
    });

    test("rejects null title", () {
      expect(isDefaultTitle(null, "https://example.com"), isFalse);
    });

    test("rejects empty title", () {
      expect(isDefaultTitle("", "https://example.com"), isFalse);
    });

    test("rejects titles shorter than 3 chars", () {
      expect(isDefaultTitle("ab", "https://ab.com"), isFalse);
    });

    test("handles malformed URL gracefully", () {
      expect(isDefaultTitle("Some Title", "not-a-url"), isFalse);
    });

    test("strips www from domain", () {
      expect(isDefaultTitle("example", "https://www.example.com"), isTrue);
    });

    test("ignores TLD-only matches (com is too short)", () {
      // "com" extracted from domain is only 3 chars — but the real domain core
      // is "example", not "com". The function should strip the TLD.
      expect(isDefaultTitle("com", "https://example.com"), isFalse);
    });
  });

  group("classifyUrlTtlTier", () {
    test("homepage (/) returns long tier", () {
      expect(classifyUrlTtlTier("https://example.com/"), TtlTier.long);
      expect(classifyUrlTtlTier("https://example.com"), TtlTier.long);
    });

    test("static pages return long tier", () {
      expect(classifyUrlTtlTier("https://example.com/about"), TtlTier.long);
      expect(
          classifyUrlTtlTier("https://example.com/terms-of-service"),
          TtlTier.long);
      expect(classifyUrlTtlTier("https://example.com/privacy"), TtlTier.long);
      expect(classifyUrlTtlTier("https://example.com/contact"), TtlTier.long);
    });

    test("search with query params returns short tier", () {
      expect(
          classifyUrlTtlTier("https://example.com/search?q=test"), TtlTier.short);
      expect(
          classifyUrlTtlTier("https://example.com/results?query=test"),
          TtlTier.short);
      expect(
          classifyUrlTtlTier("https://example.com/find?search=test"),
          TtlTier.short);
    });

    test("dynamic pages return short tier", () {
      expect(
          classifyUrlTtlTier("https://example.com/user/123"), TtlTier.short);
      expect(
          classifyUrlTtlTier("https://example.com/profile/abc"), TtlTier.short);
      expect(
          classifyUrlTtlTier("https://example.com/dashboard"), TtlTier.short);
    });

    test("content pages return medium tier", () {
      expect(
          classifyUrlTtlTier("https://example.com/post/hello"), TtlTier.medium);
      expect(
          classifyUrlTtlTier("https://example.com/blog/2024"), TtlTier.medium);
      expect(
          classifyUrlTtlTier("https://example.com/articles/dart"),
          TtlTier.medium);
    });

    test("unknown path returns medium tier (default)", () {
      expect(
          classifyUrlTtlTier("https://example.com/some/random/path"),
          TtlTier.medium);
    });

    test("malformed URL returns medium tier", () {
      expect(classifyUrlTtlTier("not-a-url"), TtlTier.medium);
    });
  });

  group("computeInitialTtl", () {
    test("default title returns 30 days", () {
      expect(
        computeInitialTtl(title: "example", url: "https://example.com/post/1"),
        kDefaultTitleBaseTtlDays,
      );
    });

    test("non-default title with /post/ returns 7 days", () {
      expect(
        computeInitialTtl(
            title: "How to bake a cake", url: "https://example.com/post/1"),
        TtlTier.medium.baseDays,
      );
    });

    test("default title overrides URL tier", () {
      // /search?q= would normally be short (3 days), but default title → 30
      expect(
        computeInitialTtl(
            title: "example", url: "https://example.com/search?q=test"),
        kDefaultTitleBaseTtlDays,
      );
    });

    test("null title falls back to URL tier", () {
      expect(
        computeInitialTtl(title: null, url: "https://example.com/about"),
        TtlTier.long.baseDays,
      );
    });
  });

  group("applyJitter", () {
    test("stays within ±20% of input (fixed seed, 100 iterations)", () {
      final random = Random(42);
      const ttl = 30;
      final lowerBound = (ttl * 0.8).floor();
      final upperBound = (ttl * 1.2).ceil();

      for (var i = 0; i < 100; i++) {
        final result = applyJitter(ttl, random: random);
        expect(result, greaterThanOrEqualTo(lowerBound));
        expect(result, lessThanOrEqualTo(upperBound));
      }
    });

    test("minimum 1 day", () {
      // With a very small TTL, jitter should never go below 1
      final random = Random(0);
      for (var i = 0; i < 100; i++) {
        final result = applyJitter(1, random: random);
        expect(result, greaterThanOrEqualTo(1));
      }
    });
  });

  group("hasContentChanged", () {
    test("detects title change", () {
      expect(
        hasContentChanged(
          oldTitle: "Old Title",
          newTitle: "New Title",
        ),
        isTrue,
      );
    });

    test("detects description change", () {
      expect(
        hasContentChanged(
          oldDescription: "Old desc",
          newDescription: "New desc",
        ),
        isTrue,
      );
    });

    test("detects image change", () {
      expect(
        hasContentChanged(
          oldImage: "https://old.png",
          newImage: "https://new.png",
        ),
        isTrue,
      );
    });

    test("returns false when nothing changed", () {
      expect(
        hasContentChanged(
          oldTitle: "Same",
          newTitle: "Same",
          oldDescription: "Desc",
          newDescription: "Desc",
          oldImage: "https://img.png",
          newImage: "https://img.png",
        ),
        isFalse,
      );
    });

    test("null-to-null returns false", () {
      expect(hasContentChanged(), isFalse);
    });

    test("null-to-value returns true", () {
      expect(
        hasContentChanged(
          oldTitle: null,
          newTitle: "Now has title",
        ),
        isTrue,
      );
    });
  });
}
