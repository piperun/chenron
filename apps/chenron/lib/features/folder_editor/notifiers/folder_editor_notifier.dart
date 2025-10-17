import "package:flutter/foundation.dart";
import "package:signals/signals.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/cud.dart";

class FolderEditorNotifier extends ChangeNotifier {
  final Signal<String> _title = signal("");
  final Signal<String> _description = signal("");
  final Signal<Set<String>> _tags = signal({});
  final Signal<List<String>> _parentFolderIds = signal([]);
  final Signal<CUD<FolderItem>> _itemUpdates = signal(CUD<FolderItem>());

  Signal<String> get title => _title;
  Signal<String> get description => _description;
  Signal<Set<String>> get tags => _tags;
  Signal<List<String>> get parentFolderIds => _parentFolderIds;
  Signal<CUD<FolderItem>> get itemUpdates => _itemUpdates;

  bool _hasChanges = false;
  bool get hasChanges => _hasChanges;

  bool get isValid => _title.value.trim().isNotEmpty;

  void setTitle(String value) {
    _title.value = value;
    _updateChangesState();
  }

  void setDescription(String value) {
    _description.value = value;
    _updateChangesState();
  }

  void setParentFolders(List<String> folderIds) {
    _parentFolderIds.value = folderIds;
    _updateChangesState();
  }

  void setTags(Set<String> tags) {
    _tags.value = tags;
    _updateChangesState();
  }

  void addTag(String tag) {
    final cleanTag = tag.trim().toLowerCase();
    if (cleanTag.isNotEmpty && !_tags.value.contains(cleanTag)) {
      _tags.value = {..._tags.value, cleanTag};
      _updateChangesState();
    }
  }

  void removeTag(String tag) {
    if (_tags.value.contains(tag)) {
      _tags.value = {..._tags.value}..remove(tag);
      _updateChangesState();
    }
  }

  void updateItems(CUD<FolderItem> updates) {
    _itemUpdates.value.create.addAll(updates.create);
    _itemUpdates.value.update.addAll(updates.update);
    _itemUpdates.value.remove.addAll(updates.remove);
    _updateChangesState();
  }

  void addItem(FolderItem item) {
    _itemUpdates.value.create.add(item);
    _updateChangesState();
  }

  void _updateChangesState() {
    final hasChanges = _itemUpdates.value.isNotEmpty ||
        _title.value.trim().isNotEmpty ||
        _description.value.trim().isNotEmpty;

    if (hasChanges != _hasChanges) {
      _hasChanges = hasChanges;
      notifyListeners();
    }
  }

  void resetChanges() {
    _itemUpdates.value = CUD<FolderItem>();
    _hasChanges = false;
    notifyListeners();
  }

  void reset() {
    _title.value = "";
    _description.value = "";
    _tags.value = {};
    _parentFolderIds.value = [];
    _itemUpdates.value = CUD<FolderItem>();
    _hasChanges = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _tags.dispose();
    _parentFolderIds.dispose();
    _itemUpdates.dispose();
    super.dispose();
  }
}
