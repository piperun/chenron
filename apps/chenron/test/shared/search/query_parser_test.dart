import "package:chenron/shared/search/query_parser.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("QueryParser.parseTags", () {
    test("extracts included tags", () {
      final result = QueryParser.parseTags("hello #world #dart");
      expect(result.includedTags, {"world", "dart"});
      expect(result.cleanQuery, "hello");
    });

    test("extracts excluded tags", () {
      final result = QueryParser.parseTags("hello -#removed");
      expect(result.excludedTags, {"removed"});
      expect(result.cleanQuery, "hello");
    });

    test("preserves quoted strings containing hash", () {
      final result = QueryParser.parseTags('"#notag" #realtag');
      expect(result.includedTags, {"realtag"});
      expect(result.cleanQuery, "#notag");
    });

    test("handles empty query", () {
      final result = QueryParser.parseTags("");
      expect(result.cleanQuery, "");
      expect(result.includedTags, isEmpty);
      expect(result.excludedTags, isEmpty);
    });

    test("handles query with only tags", () {
      final result = QueryParser.parseTags("#a -#b #c");
      expect(result.cleanQuery, "");
      expect(result.includedTags, {"a", "c"});
      expect(result.excludedTags, {"b"});
    });

    test("handles multiple spaces between tokens", () {
      final result = QueryParser.parseTags("hello   #tag   world");
      expect(result.includedTags, {"tag"});
      expect(result.cleanQuery, "hello world");
    });

    test("repeated calls produce consistent results (cached RegExp)", () {
      // Regression: old code compiled new RegExp per call.
      // Verify repeated calls are consistent.
      for (var i = 0; i < 100; i++) {
        final result =
            QueryParser.parseTags('"quoted #hash" #real -#exc text');
        expect(result.cleanQuery, "quoted #hash text");
        expect(result.includedTags, {"real"});
        expect(result.excludedTags, {"exc"});
      }
    });
  });
}
