import "dart:async";

import "package:chenron/database/actions/handlers/read_handler.dart"
    show Result;
import "package:chenron/database/database.dart" show Folder;
import "package:chenron/features/editor/pages/editor.dart";
import "package:chenron/features/show_folder/pages/show_folder.dart";
import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/models/item.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class ViewerPresenter extends ChangeNotifier {
  final Set<String> selectedItemIds = {};
  final Set<FolderItemType> selectedTypes = {FolderItemType.folder};
  final SearchController searchController = SearchController();

  final _itemsController = StreamController<List<ViewerItem>>.broadcast();
  final ViewerModel _model = ViewerModel();
  Stream<List<ViewerItem>>? _allItemsStream;
  List<ViewerItem> _currentItems = [];

  Stream<List<ViewerItem>> get itemsStream => _itemsController.stream;

  ViewerPresenter() {
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

  void onFolderTap(BuildContext context, Result<Folder> folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowFolder(folderId: folder.data.id),
      ),
    );
  }

  void onEditTap(BuildContext context, String folderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderEditor(
          folderId: folderId,
        ),
      ),
    );
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
    final filteredItems = filterItems(
      items,
      selectedTypes,
      searchController.text,
    );
    _itemsController.add(filteredItems);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _itemsController.close();
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
    switch (item.type) {
      case FolderItemType.folder:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowFolder(folderId: item.id),
          ),
        );
      case FolderItemType.link:
        break;
      case FolderItemType.document:
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
