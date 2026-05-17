import "package:chenron/shared/item_display/folder_item_type_ui.dart";
import "package:database/models/item.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("FolderItemTypeUi", () {
    test("icon maps each variant to a distinct Material icon", () {
      expect(FolderItemType.link.icon, Icons.link);
      expect(FolderItemType.document.icon, Icons.description);
      expect(FolderItemType.folder.icon, Icons.folder);
    });

    test("label maps each variant to a short user-facing string", () {
      expect(FolderItemType.link.label, "Link");
      expect(FolderItemType.document.label, "Doc");
      expect(FolderItemType.folder.label, "Folder");
    });

    test("colorOf pulls from the active colorScheme", () {
      final theme = ThemeData.light();
      expect(
          FolderItemType.link.colorOf(theme), theme.colorScheme.primary);
      expect(FolderItemType.document.colorOf(theme),
          theme.colorScheme.tertiary);
      expect(FolderItemType.folder.colorOf(theme),
          theme.colorScheme.secondary);
    });
  });

  group("String.toFolderItemType", () {
    test("parses canonical names case-insensitively", () {
      expect("link".toFolderItemType(), FolderItemType.link);
      expect("LINK".toFolderItemType(), FolderItemType.link);
      expect("document".toFolderItemType(), FolderItemType.document);
      expect("folder".toFolderItemType(), FolderItemType.folder);
    });

    test("accepts 'doc' as an alias for document", () {
      expect("doc".toFolderItemType(), FolderItemType.document);
      expect("DOC".toFolderItemType(), FolderItemType.document);
    });

    test("returns null for unrecognized input", () {
      expect("".toFolderItemType(), isNull);
      expect("file".toFolderItemType(), isNull);
      expect("links".toFolderItemType(), isNull);
    });
  });
}
