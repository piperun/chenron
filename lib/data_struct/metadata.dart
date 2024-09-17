import 'package:chenron/database/database.dart';
import 'package:cuid2/cuid2.dart';
import 'package:drift/drift.dart';

class Metadata {
  String id;
  String metadataId;

  dynamic value;
  MetadataTypeEnum type;

  Metadata({
    String? id,
    String? metadataId,
    this.value,
    required this.type,
  })  : id = id ?? cuidSecure(30),
        metadataId = metadataId ?? cuidSecure(30);

  Insertable toCompanion(String itemId) {
    return MetadataRecordsCompanion.insert(
      id: id,
      itemId: itemId,
      metadataId: metadataId,
      typeId: type.index,
    );
  }

  Insertable toMetadataItem() {
    switch (type) {
      case MetadataTypeEnum.tag:
        return TagsCompanion.insert(
          id: metadataId,
          name: value,
        );
    }
  }
}

enum MetadataTypeEnum {
  tag,
}
