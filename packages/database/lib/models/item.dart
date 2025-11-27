import 'package:database/database.dart';
import 'package:cuid2/cuid2.dart';
import 'package:drift/drift.dart' hide JsonKey;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';

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
    @Default([]) List<Tag> tags,
  }) = LinkItem;

  const factory FolderItem.document({
    String? id,
    String? itemId,
    required String title,
    required String filePath,
    @Default('text/markdown') String mimeType,
    int? fileSize,
    String? checksum,
    DateTime? createdAt,
    DateTime? updatedAt,
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
    @Default([]) List<Tag> tags,
  }) = FolderItemNested;

  /// Get the type of this folder item
  FolderItemType get type => map(
        link: (_) => FolderItemType.link,
        document: (_) => FolderItemType.document,
        folder: (_) => FolderItemType.folder,
      );

  /// Get the id (if set)
  String? get entityId => map(
        link: (item) => item.id,
        document: (item) => item.id,
        folder: (item) => item.id,
      );

  /// Create a companion for the Items table (many-to-many relation)
  Insertable toCompanion(String folderId) {
    return ItemsCompanion.insert(
      id: entityId ?? "",
      folderId: folderId,
      itemId: itemId ?? "",
      typeId: type.index,
    );
  }

  /// Create the actual entity (Link, Document, or reference to Folder)
  Insertable? toEntityCompanion(String generatedId) {
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
        mimeType: item.mimeType,
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
  folder,
}
