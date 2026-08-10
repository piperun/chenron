import "dart:async";

import "package:chenron/features/viewer/mvc/viewer_model.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";

import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/utils/safe_async.dart";
import "package:database/database.dart";

import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";

class ViewerRetentionSnapshot {
  const ViewerRetentionSnapshot({
    required this.retainedRows,
    required this.activeSubscriptions,
    required this.disposed,
  });

  final int retainedRows;
  final int activeSubscriptions;
  final bool disposed;
}

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
  Stream<List<ViewerItem>>? _allItemsStream;
  StreamSubscription<List<ViewerItem>>? _allItemsSubscription;
  int _activeSubscriptions = 0;
  List<ViewerItem> _currentItems = [];
  bool _disposed = false;

  Map<String, ViewerItem> get _currentItemsById =>
      {for (final item in _currentItems) item.id: item};

  Stream<List<ViewerItem>> get itemsStream => _itemsController.stream;
  ViewerRetentionSnapshot get retentionSnapshot => ViewerRetentionSnapshot(
        retainedRows: _currentItems.length,
        activeSubscriptions: _activeSubscriptions,
        disposed: _disposed,
      );
  late final StreamSignal<List<ViewerItem>> itemsSignal =
      StreamSignal(() => _itemsController.stream);

  ViewerPresenter({ViewerModel? model}) : _model = model ?? ViewerModel() {
    searchController.addListener(_onSearchChanged);
  }

  /// Subscribes to the reactive item stream exactly once.
  ///
  /// `Viewer` owns this presenter for one mounted page. Guarding here keeps
  /// refresh callbacks from stacking another live `watchAllItems()`
  /// subscription on top of the existing page subscription.
  Future<void> init() async {
    if (_disposed) return;
    if (_allItemsSubscription != null) return;

    _allItemsStream = _model.watchAllItems();
    _allItemsSubscription = safeWatch<List<ViewerItem>>(
      _allItemsStream!,
      tag: "ViewerPresenter",
      onData: _processItems,
      onUiError: (_) {
        // Push an empty list so the viewer renders the empty-state
        // widget instead of stalling on the last successful payload.
        if (!_itemsController.isClosed) _itemsController.add(const []);
      },
    );
    _activeSubscriptions++;
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
      final lowered = {
        for (final item in sorted) item: item.title.toLowerCase()
      };
      final dir = mode == SortMode.nameAsc ? 1 : -1;
      sorted.sort((a, b) => dir * lowered[a]!.compareTo(lowered[b]!));
    } else {
      final dir = mode == SortMode.dateAsc ? 1 : -1;
      sorted.sort((a, b) => dir * a.createdAt.compareTo(b.createdAt));
    }

    return sorted;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_allItemsSubscription?.cancel());
    _allItemsSubscription = null;
    _activeSubscriptions = 0;
    _currentItems = const [];
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

  Future<void> handleDeleteSelected() async {
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
