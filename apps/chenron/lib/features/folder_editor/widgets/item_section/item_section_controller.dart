import "package:signals/signals.dart";
import "package:database/models/item.dart";

class ItemSectionController {
  final searchQuery = signal("");
  final allItems = signal<List<FolderItem>>([]);

  // Computed signal for filtered items
  late final ReadonlySignal<List<FolderItem>> filteredItems;

  ItemSectionController() {
    filteredItems = computed(() {
      var items = allItems.value;

      if (searchQuery.value.isNotEmpty) {
        items = items.where((item) {
          final title = getTitleFromItem(item).toLowerCase();
          return title.contains(searchQuery.value.toLowerCase());
        }).toList();
      }

      return items;
    });
  }

  static String getTitleFromItem(FolderItem item) {
    return item.map(
      link: (linkItem) => linkItem.url,
      document: (docItem) => docItem.title,
      folder: (folderItem) =>
          folderItem.folderId, // Will need to resolve folder name elsewhere
    );
  }

  void updateItems(List<FolderItem> items) {
    allItems.value = items;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = "";
  }

  void dispose() {
    searchQuery.dispose();
    allItems.dispose();
  }
}
