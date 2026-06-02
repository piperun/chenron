import "package:chenron/features/folder_editor/widgets/item_section/item_section_notifier.dart";
import "package:database/models/item.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("ItemSectionNotifier.getTitleFromItem", () {
    test("folder item resolves to its title, not its folderId", () {
      const item = FolderItem.folder(
        folderId: "fldr_abc123raw_cuid",
        title: "My Folder",
      );

      expect(ItemSectionNotifier.getTitleFromItem(item), "My Folder");
    });

    test("link item resolves to its url", () {
      const item = FolderItem.link(url: "https://example.com");

      expect(
          ItemSectionNotifier.getTitleFromItem(item), "https://example.com");
    });

    test("document item resolves to its title", () {
      const item = FolderItem.document(
        title: "Notes",
        filePath: "/tmp/notes.md",
      );

      expect(ItemSectionNotifier.getTitleFromItem(item), "Notes");
    });

    test("search filters folder items by title", () {
      final notifier = ItemSectionNotifier();
      addTearDown(notifier.dispose);

      notifier.updateItems(const [
        FolderItem.folder(folderId: "fldr_1", title: "Recipes"),
        FolderItem.folder(folderId: "fldr_2", title: "Travel"),
      ]);
      notifier.updateSearchQuery("reci");

      final filtered = notifier.filteredItems.value;
      expect(filtered, hasLength(1));
      expect(
        filtered.single.map(
          link: (i) => i.url,
          document: (i) => i.title,
          folder: (i) => i.title,
        ),
        "Recipes",
      );
    });
  });
}
