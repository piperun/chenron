import "package:signals/signals.dart";
import "package:chenron/models/item.dart";

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
    if (item.path is StringContent) {
      return (item.path as StringContent).value;
    } else if (item.path is MapContent) {
      final mapValue = (item.path as MapContent).value;
      return mapValue["title"] ?? mapValue["body"] ?? "";
    }
    return "";
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
