import "package:signals/signals.dart";
import "package:chenron/models/item.dart";

class ItemSectionController {
  final searchQuery = signal("");
  final selectedFilters = signal<Set<String>>({});
  final allItems = signal<List<FolderItem>>([]);

  // Computed signal for filtered items
  late final ReadonlySignal<List<FolderItem>> filteredItems;

  ItemSectionController() {
    filteredItems = computed(() {
      var items = allItems.value;

      // Apply search filter
      if (searchQuery.value.isNotEmpty) {
        items = items.where((item) {
          final title = _getTitleFromItem(item).toLowerCase();
          return title.contains(searchQuery.value.toLowerCase());
        }).toList();
      }

      // Apply other filters if needed
      if (selectedFilters.value.isNotEmpty) {
        // Add filter logic here
      }

      return items;
    });
  }

  String _getTitleFromItem(FolderItem item) {
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

  void clearSearch() {
    searchQuery.value = "";
  }

  void dispose() {
    searchQuery.dispose();
    selectedFilters.dispose();
    allItems.dispose();
  }
}
