import "package:chenron/features/settings/models/settings_category.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("SettingsCategory tree", () {
    test("sidebar order groups locations under Storage", () {
      expect(SettingsCategory.topLevel, [
        SettingsCategory.appearance,
        SettingsCategory.storage,
        SettingsCategory.archive,
        SettingsCategory.importExport,
        SettingsCategory.tags,
      ]);
    });

    test("storage owns the on-disk location sub-categories", () {
      expect(SettingsCategory.storage.children, [
        SettingsCategory.database,
        SettingsCategory.cache,
        SettingsCategory.backup,
      ]);
      for (final child in SettingsCategory.storage.children) {
        expect(child.parent, SettingsCategory.storage);
        expect(child.isLeaf, isTrue);
      }
    });

    test("importExport is a top-level leaf", () {
      expect(SettingsCategory.importExport.isTopLevel, isTrue);
      expect(SettingsCategory.importExport.isLeaf, isTrue);
      expect(SettingsCategory.importExport.label, "Import & Export");
    });

    test("default selection is the first appearance child", () {
      expect(SettingsCategory.defaultSelection, SettingsCategory.theme);
    });

    test("every parent's children point back at it", () {
      for (final category in SettingsCategory.values) {
        for (final child in category.children) {
          expect(child.parent, category);
        }
      }
    });
  });
}
