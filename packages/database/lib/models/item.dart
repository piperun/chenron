import "package:cuid2/cuid2.dart";
import "package:database/main.dart";
import "package:database/models/document_file_type.dart";
import "package:drift/drift.dart" hide JsonKey;
import "package:freezed_annotation/freezed_annotation.dart";

part "item.freezed.dart";

@freezed
sealed class FolderItem with _$FolderItem {
  const FolderItem._();

  const factory FolderItem.link({
    String? id,
    String? itemId,
    required String url,
    String? archiveOrg,
    String? archiveIs,
    DateTime? createdAt,
    DateTime? addedAt,
    @Default([]) List<Tag> tags,
  }) = LinkItem;

  const factory FolderItem.document({
    String? id,
    String? itemId,
    required String title,
    required String filePath,
    @Default(DocumentFileType.markdown) DocumentFileType fileType,
    int? fileSize,
    String? checksum,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? addedAt,
    @Default([]) List<Tag> tags,
  }) = DocumentItem;

  const factory FolderItem.folder({
    String? id,
    String? itemId,
    required String folderId,
    required String title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? addedAt,
    @Default([]) List<Tag> tags,
  }) = FolderItemNested;

  /// Get the type of this folder item
  FolderItemType get type => map(
        link: (_) => FolderItemType.link,
        document: (_) => FolderItemType.document,
        folder: (_) => FolderItemType.folder,
      );

  /// Create a companion for the Items table (many-to-many relation)
  Insertable toCompanion(String folderId) {
    return ItemsCompanion.insert(
      id: id ?? "",
      folderId: folderId,
      itemId: itemId ?? "",
      typeId: type.dbId,
    );
  }

  /// Create the type-specific companion (Link, Document, or null for Folder)
  Insertable? toTypeCompanion(String generatedId) {
    if (!isCuid(generatedId)) {
      throw Exception("Invalid id: not a CUID");
    }

    return map(
      link: (item) => LinksCompanion.insert(
        id: generatedId,
        path: item.url,
        archiveOrgUrl: Value(item.archiveOrg),
        archiveIsUrl: Value(item.archiveIs),
      ),
      document: (item) => DocumentsCompanion.insert(
        id: generatedId,
        title: item.title,
        filePath: item.filePath,
        fileType: item.fileType,
        fileSize: Value(item.fileSize),
        checksum: Value(item.checksum),
      ),
      folder: (_) => null, // Folder already exists, no need to create
    );
  }
}

enum FolderItemType {
  link,
  document,
  folder;

  /// Database ID (1-based, matching item_types seed table).
  int get dbId => index + 1;
}
