import "package:flutter_test/flutter_test.dart";
import "package:chenron/utils/validation/tag_validator.dart";

void main() {
  group("TagValidator.validateTag", () {
    group("null and empty", () {
      test("returns error for null", () {
        expect(TagValidator.validateTag(null), "Tag cannot be empty");
      });

      test("returns error for empty string", () {
        expect(TagValidator.validateTag(""), "Tag cannot be empty");
      });
    });

    group("length", () {
      test("rejects tag shorter than 3 characters", () {
        expect(TagValidator.validateTag("ab"), contains("3-12 characters"));
      });

      test("accepts tag at minimum length (3)", () {
        expect(TagValidator.validateTag("abc"), isNull);
      });

      test("accepts tag at maximum length (12)", () {
        expect(TagValidator.validateTag("abcdefghijkl"), isNull);
      });

      test("rejects tag longer than 12 characters", () {
        expect(
          TagValidator.validateTag("abcdefghijklm"),
          contains("3-12 characters"),
        );
      });
    });

    group("alphanumeric with at least one letter", () {
      test("accepts alphabetic tag", () {
        expect(TagValidator.validateTag("flutter"), isNull);
      });

      test("accepts alphanumeric tag", () {
        expect(TagValidator.validateTag("rule34"), isNull);
      });

      test("accepts tag starting with number", () {
        expect(TagValidator.validateTag("3dprint"), isNull);
      });

      test("accepts single letter with numbers", () {
        expect(TagValidator.validateTag("v12"), isNull);
      });

      test("rejects purely numeric tag", () {
        expect(
          TagValidator.validateTag("12345"),
          "Tag must contain at least one letter",
        );
      });

      test("rejects long purely numeric tag", () {
        expect(
          TagValidator.validateTag("111111111"),
          "Tag must contain at least one letter",
        );
      });

      test("rejects tag with special characters", () {
        expect(
          TagValidator.validateTag("my-tag"),
          contains("letters and numbers"),
        );
      });

      test("rejects tag with spaces", () {
        expect(
          TagValidator.validateTag("my tag"),
          contains("letters and numbers"),
        );
      });

      test("rejects tag with underscores", () {
        expect(
          TagValidator.validateTag("my_tag"),
          contains("letters and numbers"),
        );
      });

      test("rejects tag with dots", () {
        expect(
          TagValidator.validateTag("v1.0"),
          contains("letters and numbers"),
        );
      });
    });

    group("valid tags", () {
      test("accepts common tags", () {
        final validTags = [
          "flutter",
          "dart",
          "web",
          "rule34",
          "css3",
          "html5",
          "es6",
          "react18",
          "vue3",
        ];

        for (final tag in validTags) {
          expect(TagValidator.validateTag(tag), isNull, reason: "'$tag' should be valid");
        }
      });
    });
  });

  group("TagValidator.validateTags", () {
    test("returns null for empty list", () {
      expect(TagValidator.validateTags([]), isNull);
    });

    test("returns null when all tags valid", () {
      expect(TagValidator.validateTags(["flutter", "dart", "web"]), isNull);
    });

    test("returns error with offending tag name", () {
      final result = TagValidator.validateTags(["flutter", "ab", "dart"]);
      expect(result, contains("3-12 characters"));
      expect(result, contains("'ab'"));
    });

    test("returns first error encountered", () {
      final result = TagValidator.validateTags(["a", "12345"]);
      expect(result, contains("3-12 characters"));
      expect(result, contains("'a'"));
    });
  });

  group("TagValidator.validateTagString", () {
    test("returns null for null input", () {
      expect(TagValidator.validateTagString(null), isNull);
    });

    test("returns null for empty string", () {
      expect(TagValidator.validateTagString(""), isNull);
    });

    test("validates single tag", () {
      expect(TagValidator.validateTagString("flutter"), isNull);
    });

    test("validates comma-separated tags", () {
      expect(TagValidator.validateTagString("flutter, dart, web"), isNull);
    });

    test("returns error for invalid tag in list", () {
      final result = TagValidator.validateTagString("flutter, ab, dart");
      expect(result, contains("3-12 characters"));
      expect(result, contains("'ab'"));
    });

    test("handles extra commas and whitespace", () {
      expect(TagValidator.validateTagString("flutter,,, dart,  ,web"), isNull);
    });

    test("validates alphanumeric tags in comma string", () {
      expect(TagValidator.validateTagString("css3, html5, es6"), isNull);
    });

    test("rejects purely numeric tag in comma string", () {
      final result = TagValidator.validateTagString("flutter, 12345, dart");
      expect(result, contains("at least one letter"));
    });
  });
}
