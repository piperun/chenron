class FolderResults {
  String? folderId;
  List<ItemResults>? itemIds;
  List<TagResults>? tagIds;

  FolderResults({
    this.folderId,
    this.itemIds,
    this.tagIds,
  });
}

class ItemResults {
  final String? linkId;
  final String? documentId;
  final String? itemId;

  ItemResults({
    this.linkId,
    this.documentId,
    this.itemId,
  });
}

class TagResults {
  final String? tagId;
  final String? metadataId;

  TagResults({
    this.tagId,
    this.metadataId,
  });
}
