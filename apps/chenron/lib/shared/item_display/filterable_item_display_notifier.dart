import "package:database/database.dart";
import "package:database/main.dart";
import "package:signals/signals.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode.dart";
import "package:chenron/shared/item_display/widgets/display_mode/display_mode_preference.dart";
import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/shared/tag_filter/tag_filter_state.dart";

class FilterableItemDisplayNotifier {
  final Signal<ViewMode> viewMode;
  final Signal<SortMode> sortMode;
  final Signal<Set<FolderItemType>> selectedTypes;
  final Signal<DisplayMode> displayMode;
  final Signal<bool> isLoadingDisplayMode = signal(true);
  final Signal<bool> isDeleteMode = signal(false);
  final Signal<Map<String, FolderItem>> selectedItems = signal({});

  final SearchFilter searchFilter;
  final bool ownsSearchFilter;
  final TagFilterState tagFilterState;
  final bool ownsTagFilterState;

  FilterableItemDisplayNotifier({
    required ViewMode initialViewMode,
    required SortMode initialSortMode,
    required Set<FolderItemType> initialSelectedTypes,
    required DisplayMode initialDisplayMode,
    required this.searchFilter,
    required this.ownsSearchFilter,
    required this.tagFilterState,
    required this.ownsTagFilterState,
  })  : viewMode = signal(initialViewMode),
        sortMode = signal(initialSortMode),
        selectedTypes = signal(Set.of(initialSelectedTypes)),
        displayMode = signal(initialDisplayMode);

  void setViewMode(ViewMode mode) => viewMode.value = mode;
  void setSortMode(SortMode mode) => sortMode.value = mode;
  void setSelectedTypes(Set<FolderItemType> types) =>
      selectedTypes.value = types;

  Future<void> loadDisplayMode({String? context}) async {
    final savedMode =
        await DisplayModePreference.getDisplayMode(context: context);
    displayMode.value = savedMode;
    isLoadingDisplayMode.value = false;
  }

  Future<void> setDisplayMode(DisplayMode mode, {String? context}) async {
    displayMode.value = mode;
    await DisplayModePreference.setDisplayMode(mode, context: context);
  }

  void toggleDeleteMode() {
    final entering = !isDeleteMode.value;
    isDeleteMode.value = entering;
    if (!entering) {
      selectedItems.value = {};
    }
  }

  void toggleItemSelection(FolderItem item) {
    if (!isDeleteMode.value || item.id == null) return;
    final current = Map<String, FolderItem>.from(selectedItems.value);
    if (current.containsKey(item.id)) {
      current.remove(item.id);
    } else {
      current[item.id!] = item;
    }
    selectedItems.value = current;
  }

  void selectAll(List<FolderItem> items) {
    if (!isDeleteMode.value) return;
    final current = Map<String, FolderItem>.from(selectedItems.value);
    for (final item in items) {
      if (item.id != null) {
        current[item.id!] = item;
      }
    }
    selectedItems.value = current;
  }

  void handleSearchSubmitted(String query) {
    final cleanQuery = tagFilterState.parseAndAddFromQuery(query);
    searchFilter.controller.value = cleanQuery;
  }

  List<FolderItem> getFilteredAndSortedItems({
    required List<FolderItem> items,
    required String query,
    required bool enableTagFiltering,
  }) {
    return searchFilter.filterAndSort(
      items: items,
      query: query,
      types: selectedTypes.value,
      includedTags:
          enableTagFiltering ? tagFilterState.includedTagNames : null,
      excludedTags:
          enableTagFiltering ? tagFilterState.excludedTagNames : null,
      sortMode: sortMode.value,
    );
  }

  void dispose() {
    viewMode.dispose();
    sortMode.dispose();
    selectedTypes.dispose();
    displayMode.dispose();
    isLoadingDisplayMode.dispose();
    isDeleteMode.dispose();
    selectedItems.dispose();
    if (ownsSearchFilter) searchFilter.dispose();
    if (ownsTagFilterState) tagFilterState.dispose();
  }
}

Map<FolderItemType, int> getItemCounts(List<FolderItem> items) {
  final counts = <FolderItemType, int>{
    FolderItemType.link: 0,
    FolderItemType.document: 0,
    FolderItemType.folder: 0,
  };
  for (final item in items) {
    counts[item.type] = (counts[item.type] ?? 0) + 1;
  }
  return counts;
}

List<Tag> collectAllTags(List<FolderItem> items) {
  final byId = <String, Tag>{};
  for (final item in items) {
    for (final tag in item.tags) {
      byId[tag.id] = tag;
    }
  }
  return byId.values.toList();
}
