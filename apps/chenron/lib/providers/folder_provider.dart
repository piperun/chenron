import "package:chenron/models/folder.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:signals/signals.dart";

enum FolderType { folder, link, document }

enum ArchiveMode {
  off,
  archiveIs,
  archiveOrg,
}

class FolderSignal {
  final FolderDraft folder = FolderDraft(title: "", description: "");
  // Maybe we don't need signals for these, but to be sure it's good to have them
  // one thing to note is that signals as .value will not be updated when the the state updates, only
  // in build with .value will it.
  Signal<FolderType?> folderType = signal(null);
  Signal<ArchiveMode> archiveMode = signal(ArchiveMode.off);

  void updateTitle(String newTitle) {
    folder.title = newTitle;
  }

  void updateDescription(String newDescription) {
    folder.description = newDescription;
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
