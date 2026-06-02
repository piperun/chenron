import "package:core/utils/str_sanitizer.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("removeDupSpaces", () {
    test("collapses runs of multiple spaces to a single space", () {
      expect(removeDupSpaces("a    b"), equals("a b"));
      expect(removeDupSpaces("a  b   c"), equals("a b c"));
    });

    test("collapses tabs and newlines that occur in runs", () {
      // `\s{2,}` matches any run of 2+ whitespace chars, including tabs and
      // newlines, replacing the whole run with a single space.
      expect(removeDupSpaces("a\t\tb"), equals("a b"));
      expect(removeDupSpaces("a\n\nb"), equals("a b"));
      expect(removeDupSpaces("a \t\n b"), equals("a b"));
    });

    test("trims leading and trailing whitespace", () {
      expect(removeDupSpaces("   hello   "), equals("hello"));
      expect(removeDupSpaces("\t hello \n"), equals("hello"));
    });

    test("leaves single internal spaces untouched", () {
      expect(removeDupSpaces("a b c"), equals("a b c"));
    });

    test("does not collapse a single internal tab or newline (run length 1)",
        () {
      // A lone tab/newline is one whitespace char, so `\s{2,}` does not match
      // it; it is preserved verbatim. This documents the current behavior.
      expect(removeDupSpaces("a\tb"), equals("a\tb"));
      expect(removeDupSpaces("a\nb"), equals("a\nb"));
    });

    test("returns empty string for whitespace-only or empty input", () {
      expect(removeDupSpaces(""), equals(""));
      expect(removeDupSpaces("     "), equals(""));
      expect(removeDupSpaces("\t\n  "), equals(""));
    });
  });

  group("removeTrailingSlash", () {
    test("removes a single trailing slash", () {
      expect(removeTrailingSlash("https://example.com/"),
          equals("https://example.com"));
      expect(removeTrailingSlash("path/"), equals("path"));
    });

    test("leaves a string without a trailing slash unchanged", () {
      expect(removeTrailingSlash("https://example.com"),
          equals("https://example.com"));
      expect(removeTrailingSlash("path"), equals("path"));
    });

    test("removes only the last slash when several are trailing", () {
      // Only one trailing slash is stripped per call.
      expect(removeTrailingSlash("path//"), equals("path/"));
    });

    test("a lone slash becomes an empty string", () {
      // Edge case: "/" has a trailing slash, so it collapses to "". Callers that
      // treat "/" as a root path should be aware of this.
      expect(removeTrailingSlash("/"), equals(""));
    });

    test("an empty string stays empty", () {
      // "" has no trailing slash, so it is returned unchanged.
      expect(removeTrailingSlash(""), equals(""));
    });

    test("does not touch interior slashes", () {
      expect(removeTrailingSlash("a/b/c"), equals("a/b/c"));
    });
  });
}
