import "package:chenron/models/folder.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

part "folder_provider.g.dart";

class FolderDraft {
  Folder folder = Folder();
  void updateTitle(String newTitle) {
    folder.folderInfo.title = newTitle;
  }

  void updateDescription(String newDescription) {
    folder.folderInfo.description = newDescription;
  }

  void addTag(String tag, MetadataTypeEnum type) {
    folder.tags.add(Metadata(value: tag, type: type));
  }

  void removeTag(String tag) {
    folder.tags.removeWhere((element) => element.value == tag);
  }

  void addItem(FolderItem item) {
    folder.items.add(item);
  }

  void removeItem(int id) {
    folder.items.removeWhere((element) => element.listId == id);
  }
}

@riverpod
class CreateFolder extends _$CreateFolder {
  @override
  Folder build() {
    return Folder();
  }

  void updateTitle(String newTitle) {
    state.folderInfo.title = newTitle;
  }

  void updateDescription(String newDescription) {
    state.folderInfo.description = newDescription;
  }

  void addTag(String tag, MetadataTypeEnum type) {
    state.tags.add(Metadata(value: tag, type: type));
  }

  void removeTag(String tag) {
    state.tags.removeWhere((element) => element.value == tag);
  }

  void addItem(FolderItem item) {
    state.items.add(item);
  }

  void removeItem(int id) {
    state.items.removeWhere((element) => element.listId == id);
  }
}

class Folder {
  final FolderInfo folderInfo = FolderInfo(title: "", description: "");
  final Set<Metadata> tags = {};
  final Set<FolderItem> items = {};
}
