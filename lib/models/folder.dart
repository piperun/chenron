import "package:cuid2/cuid2.dart";

@Deprecated(
    "Use Folder instead, this class is exactly the same as Folder, but still using the dangerous id generation")
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
