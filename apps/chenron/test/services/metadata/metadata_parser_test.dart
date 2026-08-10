import "package:chenron/services/metadata/metadata_parser.dart";
import "package:flutter_test/flutter_test.dart";

import "metadata_fixture.dart";

void main() {
  group("parseMetadataDocument", () {
    // Catches a precedence regression that lets lower-priority tags replace OG.
    test("prefers OG over Twitter JSON-LD and title", () {
      final parsed = parseMetadataDocument(
        readMetadataFixture("all_sources.html"),
        baseUri: Uri.parse("https://example.com/post/1"),
      );

      expect(parsed.title, "OG title");
      expect(parsed.description, "OG description");
      expect(parsed.imageUrl, "https://example.com/images/og.jpg");
    });

    // Catches a fallback regression that skips valid JSON-LD without social tags.
    test("uses JSON-LD when social tags are absent", () {
      final parsed = parseMetadataDocument(
        readMetadataFixture("json_ld.html"),
        baseUri: Uri.parse("https://example.com/post/1"),
      );

      expect(parsed.title, "Structured title");
      expect(parsed.description, "Structured description");
      expect(parsed.imageUrl, "https://example.com/images/structured.jpg");
    });
  });
}
