import "package:chenron/database/database.dart";
import "package:drift/drift.dart";

class Metadata {
  final String? _id;
  final String? _metadataId;
  String? get id => _id;
  String? get metadataId => _metadataId;

  String value;
  MetadataTypeEnum type;

  Metadata._internal(this._id, this._metadataId, this.value, this.type);

  factory Metadata(
      {String? id,
      String? metadataId,
      required String value,
      required MetadataTypeEnum type}) {
    return Metadata._internal(id, metadataId, value, type);
  }

  Insertable toCompanion(String folderId) {
    return MetadataRecordsCompanion.insert(
      id: _id!,
      itemId: folderId,
      metadataId: _metadataId!,
      typeId: type.index,
    );
  }

  Insertable toMetadataItem(String id) {
    switch (type) {
      case MetadataTypeEnum.tag:
        return TagsCompanion.insert(
          id: id,
          name: value,
        );
    }
  }
}

enum MetadataTypeEnum {
  tag,
}
