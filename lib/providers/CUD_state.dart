import "package:flutter/material.dart";
import "package:chenron/models/cud.dart";

class CUDProvider<T> extends ChangeNotifier {
  final CUD<T> _cud = CUD<T>();

  List<T> get create => _cud.create;
  List<T> get update => _cud.update;
  List<String> get remove => _cud.remove;

  void addItem(T item) {
    _cud.addItem(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _cud.removeItem(id);
    notifyListeners();
  }

  void toggleSelection(int index) {}
}
