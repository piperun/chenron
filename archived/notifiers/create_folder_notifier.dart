import "package:flutter/foundation.dart";
import "package:signals/signals.dart";

class CreateFolderNotifier extends ChangeNotifier {
  final Signal<String> _title = signal("");
  final Signal<String> _description = signal("");
  final Signal<Set<String>> _tags = signal({});
  final Signal<List<String>> _parentFolderIds = signal([]);

  Signal<String> get title => _title;
  Signal<String> get description => _description;
  Signal<Set<String>> get tags => _tags;
  Signal<List<String>> get parentFolderIds => _parentFolderIds;

  bool get isValid => _title.value.trim().isNotEmpty;

  void setTitle(String value) {
    _title.value = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description.value = value;
    notifyListeners();
  }

  void setParentFolders(List<String> folderIds) {
    _parentFolderIds.value = folderIds;
    notifyListeners();
  }

  void addTag(String tag) {
    final cleanTag = tag.trim().toLowerCase();
    if (cleanTag.isNotEmpty && !_tags.value.contains(cleanTag)) {
      _tags.value = {..._tags.value, cleanTag};
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    if (_tags.value.contains(tag)) {
      _tags.value = {..._tags.value}..remove(tag);
      notifyListeners();
    }
  }

  void clearTags() {
    if (_tags.value.isNotEmpty) {
      _tags.value = {};
      notifyListeners();
    }
  }

  void reset() {
    _title.value = "";
    _description.value = "";
    _tags.value = {};
    _parentFolderIds.value = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _tags.dispose();
    _parentFolderIds.dispose();
    super.dispose();
  }
}
