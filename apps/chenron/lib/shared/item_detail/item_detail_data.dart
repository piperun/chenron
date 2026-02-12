import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:database/models/item.dart";
import "package:database/models/document_file_type.dart";
import "package:freezed_annotation/freezed_annotation.dart";

part "item_detail_data.freezed.dart";

/// Immutable data holder for the item detail dialog.
///
/// Aggregates item data, tags, and parent folders into a single
/// object regardless of item type.
@freezed
abstract class ItemDetailData with _$ItemDetailData {
  const factory ItemDetailData({
    required String itemId,
    required FolderItemType itemType,
    required String title,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<Tag> tags,
    @Default([]) List<Folder> parentFolders,

    // Link-specific
    String? url,
    String? domain,
    String? archiveOrgUrl,
    String? archiveIsUrl,
    String? localArchivePath,

    // Document-specific
    DocumentFileType? fileType,
    int? fileSize,
    String? filePath,

    // Folder-specific
    String? description,
    int? color,
    @Default(0) int linkCount,
    @Default(0) int documentCount,
    @Default(0) int folderCount,
  }) = _ItemDetailData;

  static ItemDetailData fromLink(LinkResult result, List<Folder> parents) {
    final link = result.data;
    String? domain;
    try {
      final uri = Uri.parse(link.path);
      domain = uri.host.isEmpty ? null : uri.host;
    } catch (_) {}

    return ItemDetailData(
      itemId: link.id,
      itemType: FolderItemType.link,
      title: link.path,
      createdAt: link.createdAt,
      tags: result.tags,
      parentFolders: parents,
      url: link.path,
      domain: domain,
      archiveOrgUrl: link.archiveOrgUrl,
      archiveIsUrl: link.archiveIsUrl,
      localArchivePath: link.localArchivePath,
    );
  }

  static ItemDetailData fromDocument(
      DocumentResult result, List<Folder> parents) {
    final doc = result.data;
    return ItemDetailData(
      itemId: doc.id,
      itemType: FolderItemType.document,
      title: doc.title,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
      tags: result.tags ?? [],
      parentFolders: parents,
      fileType: doc.fileType,
      fileSize: doc.fileSize,
      filePath: doc.filePath,
    );
  }

  static ItemDetailData fromFolder(
      FolderResult result, List<Folder> parents) {
    final folder = result.data;

    int links = 0;
    int documents = 0;
    int folders = 0;
    for (final item in result.items) {
      switch (item.type) {
        case FolderItemType.link:
          links++;
        case FolderItemType.document:
          documents++;
        case FolderItemType.folder:
          folders++;
      }
    }

    return ItemDetailData(
      itemId: folder.id,
      itemType: FolderItemType.folder,
      title: folder.title,
      createdAt: folder.createdAt,
      updatedAt: folder.updatedAt,
      tags: result.tags,
      parentFolders: parents,
      description: folder.description,
      color: folder.color,
      linkCount: links,
      documentCount: documents,
      folderCount: folders,
    );
  }
}
