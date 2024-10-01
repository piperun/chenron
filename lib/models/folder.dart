import "package:cuid2/cuid2.dart";

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
