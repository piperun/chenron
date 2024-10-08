import "package:chenron/models/folder.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:flutter/foundation.dart";

class FolderProvider extends ChangeNotifier {
  final _Folder _folder = _Folder();
  void updateTitle(String newTitle) {
    _folder.folderInfo.title = newTitle;
    notifyListeners();
  }

  void updateDescription(String newDescription) {
    _folder.folderInfo.description = newDescription;
    notifyListeners();
  }

  void addTag(String tag, MetadataTypeEnum type) {
    _folder.tags.add(Metadata(value: tag, type: type));
    notifyListeners();
  }

  void removeTag(String tag) {
    _folder.tags.removeWhere((element) => element.value == tag);
    notifyListeners();
  }

  void addItem(FolderItem item) {
    _folder.items.add(item);
    notifyListeners();
  }

  void removeItem(int id) {
    _folder.items.removeWhere((element) => element.listId == id);
    notifyListeners();
  }
}

class _Folder {
  final FolderInfo folderInfo = FolderInfo(title: "", description: "");
  final Set<Metadata> tags = {};
  final Set<FolderItem> items = {};
}
