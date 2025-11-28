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
import "package:chenron/shared/item_display/widgets/viewer_item/item_info_modal.dart";

class ViewerPresenter extends ChangeNotifier {
  final Set<String> selectedItemIds = {};
  final Set<FolderItemType> selectedTypes = {
    FolderItemType.folder,
    FolderItemType.link,
    FolderItemType.document,
  };
  final SearchController searchController = SearchController();
  ViewMode viewMode = ViewMode.grid;
  SortMode sortMode = SortMode.nameAsc;

  final _itemsController = StreamController<List<ViewerItem>>.broadcast();
  final ViewerModel _model;
  final ConfigController _configController = locator.get<ConfigController>();
  Stream<List<ViewerItem>>? _allItemsStream;
  List<ViewerItem> _currentItems = [];

  Stream<List<ViewerItem>> get itemsStream => _itemsController.stream;
  late final StreamSignal<List<ViewerItem>> itemsSignal =
      StreamSignal(() => _itemsController.stream);

  ViewerPresenter({ViewerModel? model}) : _model = model ?? ViewerModel() {
    searchController.addListener(_onSearchChanged);
  }

  Future<void> init() async {
    _allItemsStream = _model.watchAllItems();
    _allItemsStream!.listen(_processItems);
    notifyListeners();
  }

  void clearSelectedItems() {
    selectedItemIds.clear();
    notifyListeners();
  }

  void onTypesChanged(Set<FolderItemType> types) {
    selectedTypes.clear();
    selectedTypes.addAll(types);

    selectedItemIds.removeWhere((itemId) {
      final item = _currentItems.firstWhere((item) => item.id == itemId);
      return !types.contains(item.type);
    });

    _filterAndAddItems(_currentItems);
    notifyListeners();
  }

  void onViewModeChanged(ViewMode mode) {
    viewMode = mode;
    notifyListeners();
  }

  void onSortChanged(SortMode mode) {
    sortMode = mode;
    _filterAndAddItems(_currentItems);
    notifyListeners();
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
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
    notifyListeners();
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
      selectedTypes,
      searchController.text,
    );
    filteredItems = _sortItems(filteredItems);
    _itemsController.add(filteredItems);
  }

  List<ViewerItem> _sortItems(List<ViewerItem> items) {
    final sorted = List<ViewerItem>.from(items);
    sorted.sort((a, b) {
      switch (sortMode) {
        case SortMode.nameAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortMode.nameDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        case SortMode.dateAsc:
          return a.createdAt.compareTo(b.createdAt);
        case SortMode.dateDesc:
          return b.createdAt.compareTo(a.createdAt);
      }
    });
    return sorted;
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    unawaited(_itemsController.close());
    super.dispose();
  }

  List<ViewerItem> filterItems(
      List<ViewerItem> items, Set<FolderItemType> types, String searchQuery) {
    return items.where((item) {
      final matchesType = types.contains(item.type);
      final matchesSearch = searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.tags.any((tag) =>
              tag.name.toLowerCase().contains(searchQuery.toLowerCase()));

      return matchesType && matchesSearch;
    }).toList();
  }

  void onItemTap(BuildContext context, ViewerItem item) {
    final action = _configController.itemClickAction.peek();

    if (action == 1) {
      // Show Details
      // Convert ViewerItem to FolderItem for the modal
      final folderItem = switch (item.type) {
        FolderItemType.link => FolderItem.link(
            id: item.id,
            itemId: null,
            url: item.url ?? "",
            tags: item.tags,
            createdAt: item.createdAt,
          ),
        FolderItemType.document => FolderItem.document(
            id: item.id,
            itemId: null,
            title: item.title,
            filePath: "", // Will need to be populated from ViewerItem
            tags: item.tags,
            createdAt: item.createdAt,
          ),
        FolderItemType.folder => FolderItem.folder(
            id: item.id,
            itemId: null,
            folderId: item.id,
            title: item.title,
            tags: item.tags,
          ),
      };

      unawaited(showDialog(
        context: context,
        builder: (context) => ItemInfoModal(item: folderItem),
      ));
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
    if (selectedItemIds.isEmpty) return;

    bool success = true;
    for (final itemId in selectedItemIds) {
      final item = _currentItems.firstWhere((item) => item.id == itemId);

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
