import 'package:flutter/foundation.dart';

class FolderInfoProvider extends ChangeNotifier {
  String title = "";
  String description = "";
  Set<String> _tags = {};

  Set<String> get tags => _tags;

  void updateTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  void updateDescription(String newDescription) {
    description = newDescription;
    notifyListeners();
  }

  void addTag(String tag) {
    _tags.add(tag);
    notifyListeners();
  }

  void removeTag(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }
}
