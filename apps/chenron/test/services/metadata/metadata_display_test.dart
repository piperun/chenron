import "package:cache_manager/cache_manager.dart";
import "package:chenron/services/metadata/metadata_display.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("inferMetadataTitle", () {
    // Catches URL inference that ignores a meaningful Media tags parameter.
    test("derives Media tag title without persisting it", () {
      const url =
          "https://media.example/index.php?page=post&s=list&tags=sampletag";

      expect(inferMetadataTitle(url), "sampletag - Media");
    });

    // Catches country-code public suffixes leaking into the site label.
    test("strips a common second-level country suffix", () {
      expect(inferMetadataTitle("https://www.example.co.uk"), "Example");
    });
  });

  group("resolveMetadataDisplayTitle", () {
    // Catches replacing a verified cached page title with an inferred fallback.
    test("uses a verified title before URL inference", () {
      final state = MetadataState.available(
        data: Metadata(
          url: "https://example.com/posts/real-title",
          title: "Publisher title",
          fetchedAt: DateTime.utc(2026, 8, 1),
        ),
        freshness: MetadataFreshness.stale,
      );

      expect(
        resolveMetadataDisplayTitle(
          "https://example.com/posts/real-title",
          state,
        ),
        "Publisher title",
      );
    });

    // Catches displaying legacy spacing-equivalent domain-only cached titles.
    test("ignores a legacy domain-only cached title", () {
      final state = MetadataState.available(
        data: Metadata(
          url: "https://media.example/index.php?page=post&s=list&tags=sampletag",
          title: "Media",
          fetchedAt: DateTime.utc(2026, 8, 1),
        ),
        freshness: MetadataFreshness.stale,
      );

      expect(
        resolveMetadataDisplayTitle(
            "https://media.example/index.php?page=post&s=list&tags=sampletag",
            state),
        "sampletag - Media",
      );
    });
  });
}
