import "dart:async";

import "package:chenron/features/folder_editor/pages/folder_editor.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";

import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:database/database.dart";

import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:signals/signals_flutter.dart";
import "package:chenron/features/settings/controller/config_controller.dart";
import "package:chenron/locator.dart";
import "package:chenron/shared/item_detail/item_detail_dialog.dart";

class ViewerPresenter {
  final Signal<Set<String>> selectedItemIds = signal({});
  final Signal<Set<FolderItemType>> selectedTypes = signal({
    FolderItemType.folder,
    FolderItemType.link,
    FolderItemType.document,
  });
  final SearchController searchController = SearchController();
  final Signal<ViewMode> viewMode = signal(ViewMode.grid);
  final Signal<SortMode> sortMode = signal(SortMode.nameAsc);

  final _itemsController = StreamController<List<ViewerItem>>.broadcast();
  final ViewerModel _model;
  final ConfigController _configController = locator.get<ConfigController>();
  Stream<List<ViewerItem>>? _allItemsStream;
  List<ViewerItem> _currentItems = [];

  Map<String, ViewerItem> get _currentItemsById =>
      {for (final item in _currentItems) item.id: item};

  Stream<List<ViewerItem>> get itemsStream => _itemsController.stream;
  late final StreamSignal<List<ViewerItem>> itemsSignal =
      StreamSignal(() => _itemsController.stream);

  ViewerPresenter({ViewerModel? model}) : _model = model ?? ViewerModel() {
    searchController.addListener(_onSearchChanged);
  }

  Future<void> init() async {
    _allItemsStream = _model.watchAllItems();
    _allItemsStream!.listen(_processItems);
  }

  void clearSelectedItems() {
    selectedItemIds.value = {};
  }

  void onTypesChanged(Set<FolderItemType> types) {
    selectedTypes.value = Set.of(types);

    final itemById = _currentItemsById;
    selectedItemIds.value = Set.of(
      selectedItemIds.value.where((itemId) {
        final item = itemById[itemId];
        return item != null && types.contains(item.type);
      }),
    );

    _filterAndAddItems(_currentItems);
  }

  void onViewModeChanged(ViewMode mode) {
    viewMode.value = mode;
  }

  void onSortChanged(SortMode mode) {
    sortMode.value = mode;
    _filterAndAddItems(_currentItems);
  }

  void onFolderTap(BuildContext context, FolderResult folder) {
    unawaited(Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderViewerPage(folderId: folder.data.id),
      ),
    ));
  }

  void onEditTap(BuildContext context, String folderId) {
    unawaited(Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderEditor(
          folderId: folderId,
        ),
      ),
    ));
  }

  void toggleItemSelection(String itemId) {
    final current = Set<String>.of(selectedItemIds.value);
    if (current.contains(itemId)) {
      current.remove(itemId);
    } else {
      current.add(itemId);
    }
    selectedItemIds.value = current;
  }

  void _onSearchChanged() {
    _filterAndAddItems(_currentItems);
  }

  void _processItems(List<ViewerItem> items) {
    _currentItems = items;
    _filterAndAddItems(items);
  }

  void _filterAndAddItems(List<ViewerItem> items) {
    var filteredItems = filterItems(
      items,
      selectedTypes.value,
      searchController.text,
    );
    filteredItems = _sortItems(filteredItems);
    _itemsController.add(filteredItems);
  }

  List<ViewerItem> _sortItems(List<ViewerItem> items) {
    final sorted = List<ViewerItem>.from(items);
    final mode = sortMode.value;

    if (mode == SortMode.nameAsc || mode == SortMode.nameDesc) {
      // Cache lowercased titles to avoid repeated toLowerCase() in comparator
      final lowered = {for (final item in sorted) item: item.title.toLowerCase()};
      final dir = mode == SortMode.nameAsc ? 1 : -1;
      sorted.sort((a, b) => dir * lowered[a]!.compareTo(lowered[b]!));
    } else {
      final dir = mode == SortMode.dateAsc ? 1 : -1;
      sorted.sort((a, b) => dir * a.createdAt.compareTo(b.createdAt));
    }

    return sorted;
  }

  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    unawaited(_itemsController.close());
    selectedItemIds.dispose();
    selectedTypes.dispose();
    viewMode.dispose();
    sortMode.dispose();
  }

  List<ViewerItem> filterItems(
      List<ViewerItem> items, Set<FolderItemType> types, String searchQuery) {
    final query = searchQuery.toLowerCase();
    return items.where((item) {
      final matchesType = types.contains(item.type);
      final matchesSearch = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.tags.any((tag) => tag.name.toLowerCase().contains(query));

      return matchesType && matchesSearch;
    }).toList();
  }

  void onItemTap(BuildContext context, ViewerItem item) {
    final action = _configController.itemClickAction.peek();

    if (action == 1) {
      showItemDetailDialog(context,
          itemId: item.id, itemType: item.type);
      return;
    }

    // Default: Open Item
    switch (item.type) {
      case FolderItemType.folder:
        unawaited(Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderViewerPage(folderId: item.id),
          ),
        ));
      case FolderItemType.link:
        if (item.url != null) {
          unawaited(onOpenUrl(item.url!));
        }
        break;
      case FolderItemType.document:
        // Future implementation
        break;
    }
  }

  Future<void> onOpenUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> onDeleteSelected() async {
    if (selectedItemIds.value.isEmpty) return;

    final itemById = _currentItemsById;
    bool success = true;
    for (final itemId in selectedItemIds.value) {
      final item = itemById[itemId];
      if (item == null) continue;

      success = switch (item.type) {
        FolderItemType.folder => await _model.removeFolder(itemId),
        FolderItemType.link => await _model.removeLink(itemId),
        FolderItemType.document => await _model.removeDocument(itemId),
      };

      if (!success) break;
    }

    if (success) {
      clearSelectedItems();
    }
  }
}
