import "package:database/models/item.dart" show FolderItem;
import "package:database/models/metadata.dart";

class FolderDraft {
  String title;
  String description;

  final Set<Metadata> tags = {};
  final Set<FolderItem> items = {};
  FolderDraft({
    required this.title,
    required this.description,
  });
}


