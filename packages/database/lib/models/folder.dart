import "package:database/models/item.dart";
import "package:database/models/metadata.dart";
import "package:drift/drift.dart";

class FolderDraft {
  String title;
  String description;
  int? color;

  final Set<Metadata> tags = {};
  final Set<FolderItem> items = {};
  FolderDraft({
    required this.title,
    required this.description,
    this.color,
  });

  FolderDraft copyWith({
    String? title,
    String? description,
    Value<int?>? color,
  }) {
    return FolderDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      color: color != null ? color.value : this.color,
    );
  }
}
