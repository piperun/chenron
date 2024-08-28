import 'package:flutter/foundation.dart';
import 'package:chenron/data_struct/item.dart';

class FolderItemProvider extends ChangeNotifier {
  List<FolderItem> _items = [];

  List<FolderItem> get items => _items;

  void addItem(FolderItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateItem(FolderItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  List<FolderItem> getItemsByType(FolderItemType type) {
    return _items.where((item) => item.type == type).toList();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
