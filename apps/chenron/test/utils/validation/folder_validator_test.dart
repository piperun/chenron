import "package:flutter_test/flutter_test.dart";

import "package:chenron/utils/validation/folder_validator.dart";

void main() {
  // -------------------------------------------------------------------------
  // validateTitle()
  // -------------------------------------------------------------------------
  group("FolderValidator.validateTitle()", () {
    test("returns error for null", () {
      expect(FolderValidator.validateTitle(null), isNotNull);
    });

    test("returns error for empty string", () {
      expect(FolderValidator.validateTitle(""), isNotNull);
    });

    test("returns error for whitespace-only", () {
      expect(FolderValidator.validateTitle("   "), isNotNull);
    });

    test("returns error for too-short title", () {
      // SchemaRules.title.min is 6
      expect(FolderValidator.validateTitle("Short"), isNotNull);
    });

    test("returns error for too-long title", () {
      // SchemaRules.title.max is 30
      final longTitle = "A" * 31;
      expect(FolderValidator.validateTitle(longTitle), isNotNull);
    });

    test("returns null for valid English title", () {
      expect(FolderValidator.validateTitle("My Folder"), isNull);
    });

    test("returns null for title with numbers", () {
      expect(FolderValidator.validateTitle("Folder 42"), isNull);
    });

    test("returns null for title at min length", () {
      expect(FolderValidator.validateTitle("Abcdef"), isNull);
    });

    test("returns null for title at max length", () {
      final maxTitle = "A" * 30;
      expect(FolderValidator.validateTitle(maxTitle), isNull);
    });

    test("returns error for special characters", () {
      expect(FolderValidator.validateTitle("Folder!@#"), isNotNull);
    });

    test("accepts Cyrillic characters", () {
      expect(FolderValidator.validateTitle("Привет Мир"), isNull);
    });

    test("accepts Japanese characters", () {
      expect(FolderValidator.validateTitle("テスト フォルダ"), isNull);
    });

    test("accepts Swedish characters", () {
      expect(FolderValidator.validateTitle("Mappen Åäö"), isNull);
    });

    test("accepts Ukrainian characters", () {
      expect(FolderValidator.validateTitle("Тека Привіт"), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // validateDescription()
  // -------------------------------------------------------------------------
  group("FolderValidator.validateDescription()", () {
    test("returns null for null (optional field)", () {
      expect(FolderValidator.validateDescription(null), isNull);
    });

    test("returns null for empty string", () {
      expect(FolderValidator.validateDescription(""), isNull);
    });

    test("returns null for normal description", () {
      expect(FolderValidator.validateDescription("A nice folder"), isNull);
    });

    test("returns error for too-long description", () {
      // SchemaRules.description.max is 1000
      final longDesc = "A" * 1001;
      expect(FolderValidator.validateDescription(longDesc), isNotNull);
    });

    test("returns null at max length", () {
      final maxDesc = "A" * 1000;
      expect(FolderValidator.validateDescription(maxDesc), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // validateTags()
  // -------------------------------------------------------------------------
  group("FolderValidator.validateTags()", () {
    test("returns null for null (optional field)", () {
      expect(FolderValidator.validateTags(null), isNull);
    });

    test("returns null for valid tags", () {
      expect(FolderValidator.validateTags("cool, stuff"), isNull);
    });
  });
}
