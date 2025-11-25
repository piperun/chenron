import "package:database/database.dart";
import "package:database/models/item.dart";

class ViewerItem {
  final String id;
  final String title;
  final String description;
  final FolderItemType type;
  final List<Tag> tags;
  final DateTime createdAt;
  final String? url;

  ViewerItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.tags,
    required this.createdAt,
    this.url,
  });
}

