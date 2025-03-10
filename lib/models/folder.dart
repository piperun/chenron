import "package:cuid2/cuid2.dart";

// TODO: Look into if this is needed or if we can simply use Folder
class FolderInfo {
  String id;
  String title;
  String description;
  DateTime? createdAt;
  FolderInfo({
    String? id,
    required this.title,
    required this.description,
    DateTime? createdAt,
  }) : id = id ?? cuidSecure(30);
}
