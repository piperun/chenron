import "package:database/main.dart";
import "package:database/models/db_result.dart";
import "package:database/models/item.dart";
import "package:database/models/document_file_type.dart";

/// Immutable data holder for the item detail dialog.
///
/// Aggregates item data, tags, and parent folders into a single
/// object regardless of item type.
class ItemDetailData {
  final String itemId;
  final FolderItemType itemType;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Tag> tags;
  final List<Folder> parentFolders;

  // Link-specific
  final String? url;
  final String? domain;
  final String? archiveOrgUrl;
  final String? archiveIsUrl;
  final String? localArchivePath;

  // Document-specific
  final DocumentFileType? fileType;
  final int? fileSize;
  final String? filePath;

  // Folder-specific
  final String? description;
  final int? color;
  final int linkCount;
  final int documentCount;
  final int folderCount;

  const ItemDetailData({
    required this.itemId,
    required this.itemType,
    required this.title,
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.parentFolders = const [],
    this.url,
    this.domain,
    this.archiveOrgUrl,
    this.archiveIsUrl,
    this.localArchivePath,
    this.fileType,
    this.fileSize,
    this.filePath,
    this.description,
    this.color,
    this.linkCount = 0,
    this.documentCount = 0,
    this.folderCount = 0,
  });

  factory ItemDetailData.fromLink(LinkResult result, List<Folder> parents) {
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

  factory ItemDetailData.fromDocument(
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

  factory ItemDetailData.fromFolder(
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
