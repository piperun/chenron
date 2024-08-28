import 'package:cuid2/cuid2.dart';

class FolderInfo {
  String id;
  String title;
  String description;
  FolderInfo({
    String? id,
    required this.title,
    required this.description,
  }) : id = id ?? cuidSecure(30);
}
