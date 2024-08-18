import 'package:flutter/foundation.dart';

class FolderProvider extends ChangeNotifier {
  String title = "";
  String description = "";
  List<String> tags = [];

  void updateTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  void updateDescription(String newDescription) {
    description = newDescription;
    notifyListeners();
  }

  void updateTags(List<String> newTags) {
    tags = tags + newTags;
    notifyListeners();
  }
}
