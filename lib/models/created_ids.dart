import "package:chenron/database/database.dart";

/// Enum for secondary ID keys to provide type safety
enum IdKey { metadataId, linkId, documentId, itemId }

/// A generic class to represent any collection of IDs resulting from database operations
class CreatedIds<T> {
  // Primary ID for the entity
  final String? primaryId;

  // Map for flexible additional IDs (can be any type of ID)
  final Map<IdKey, String?> secondaryIds;

  // Related entities - can be of different types
  final Map<IncludeOptions, List<CreatedIds>> relationIds;

  const CreatedIds({
    this.primaryId,
    this.secondaryIds = const {},
    this.relationIds = const {},
  });

  // Factory constructors for specific entity types
  factory CreatedIds.folder({
    String? folderId,
    List<CreatedIds>? items,
    List<CreatedIds>? tags,
  }) {
    return CreatedIds<T>(primaryId: folderId, relationIds: {
      if (items != null) IncludeOptions.items: items,
      if (tags != null) IncludeOptions.tags: tags,
    });
  }

  factory CreatedIds.item({
    String? itemId,
    String? linkId,
    String? documentId,
  }) {
    return CreatedIds<T>(primaryId: itemId, secondaryIds: {
      if (linkId != null) IdKey.linkId: linkId,
      if (documentId != null) IdKey.documentId: documentId,
    });
  }

  factory CreatedIds.tag({
    String? tagId,
    String? metadataId,
  }) {
    return CreatedIds<T>(primaryId: tagId, secondaryIds: {
      if (metadataId != null) IdKey.metadataId: metadataId,
    });
  }

  // Helper methods
  List<CreatedIds>? getRelated(IncludeOptions option) => relationIds[option];

  String? getSecondaryId(IdKey key) => secondaryIds[key];

  // Type checking helpers
  bool get isTagResult => secondaryIds.containsKey(IdKey.metadataId);
  bool get isItemResult =>
      secondaryIds.containsKey(IdKey.linkId) ||
      secondaryIds.containsKey(IdKey.documentId);
  bool get isFolderResult => relationIds.isNotEmpty;
}

extension TagCreatedIdsExtension on CreatedIds<Tag> {
  String? get tagId => primaryId;
  String? get metadataId => getSecondaryId(IdKey.metadataId);
}

extension ItemCreatedIdsExtension on CreatedIds<Item> {
  String? get itemId => primaryId;
  String? get linkId => getSecondaryId(IdKey.linkId);
  String? get documentId => getSecondaryId(IdKey.documentId);
}

extension FolderCreatedIdsExtension on CreatedIds<Folder> {
  String? get folderId => primaryId;

  List<CreatedIds<Item>>? get typedItems =>
      getRelated(IncludeOptions.items)?.cast<CreatedIds<Item>>();

  List<CreatedIds<Tag>>? get typedTags =>
      getRelated(IncludeOptions.tags)?.cast<CreatedIds<Tag>>();
}

extension UserConfigExtensions on CreatedIds<UserConfig> {
  String? get userConfigId => primaryId;
}
