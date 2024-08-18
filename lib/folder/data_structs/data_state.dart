import 'package:flutter/material.dart';

class CUDProvider<T> extends ChangeNotifier {
  List<T> create = [];
  Map<int, T> update = {};
  List<int> remove = [];

  void addItem(T item) {
    create.add(item);
    notifyListeners();
  }

  void updateItem(int id, T item) {
    update[id] = item;
    notifyListeners();
  }

  void removeItem(int id) {
    remove.add(id);
    notifyListeners();
  }

  void toggleSelection(int index) {}
}
