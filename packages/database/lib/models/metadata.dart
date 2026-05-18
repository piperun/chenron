import "package:database/database.dart";
import "package:drift/drift.dart";

export "package:database/models/enums.dart" show MetadataTypeEnum;

class Metadata {
  final String? _id;
  final String? _metadataId;
  String? get id => _id;
  String? get metadataId => _metadataId;

  String value;
  MetadataTypeEnum type;
  int? color;

  Metadata._internal(
      this._id, this._metadataId, this.value, this.type, this.color);

  factory Metadata(
      {String? id,
      String? metadataId,
      required String value,
      required MetadataTypeEnum type,
      int? color}) {
    return Metadata._internal(id, metadataId, value, type, color);
  }

  Insertable toCompanion(String folderId) {
    return MetadataRecordsCompanion.insert(
      id: _id!,
      itemId: folderId,
      metadataId: _metadataId!,
      typeId: type,
    );
  }

  Insertable toMetadataItem(String id) {
    switch (type) {
      case MetadataTypeEnum.tag:
        return TagsCompanion.insert(
          id: id,
          name: value,
          color: Value(color),
        );
    }
  }
}

// MetadataTypeEnum is defined in `models/enums.dart` and re-exported above.
