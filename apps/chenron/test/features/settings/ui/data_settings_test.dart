import "package:flutter_test/flutter_test.dart";

import "package:chenron/features/settings/models/settings_category.dart";

void main() {
  group("SettingsCategory.data", () {
    test("is a top-level category", () {
      expect(SettingsCategory.data.isTopLevel, true);
    });

    test("has no parent", () {
      expect(SettingsCategory.data.parent, isNull);
    });

    test("has no children", () {
      expect(SettingsCategory.data.children, isEmpty);
    });

    test("is a leaf", () {
      expect(SettingsCategory.data.isLeaf, true);
    });

    test("has correct label", () {
      expect(SettingsCategory.data.label, "Data");
    });

    test("appears in topLevel list", () {
      expect(SettingsCategory.topLevel, contains(SettingsCategory.data));
    });
  });
}
