import "package:chenron/database/database.dart";
import "package:chenron/models/metadata.dart";
import "package:cuid2/cuid2.dart";

class LinkTestData {
  final Link link;
  final List<Metadata> tags;

  LinkTestData({required this.link, required this.tags});
}

class LinkFactory {
  static Link create(String url) {
    return Link(
      id: cuidSecure(30),
      path: url,
      createdAt: DateTime.now(),
    );
  }
}

class MetadataFactory {
  static List<Metadata> createTags(List<String> tagValues,
      {Map<String, String>? ids, Map<String, String>? metadataIds}) {
    List<Metadata> tags = [];
    for (String value in tagValues) {
      if (ids != null) {
        tags.add(
            Metadata(id: ids[value], value: value, type: MetadataTypeEnum.tag));
      }
      if (metadataIds != null) {
        tags.add(Metadata(
            metadataId: metadataIds[value],
            value: value,
            type: MetadataTypeEnum.tag));
      }
      if (metadataIds == null && ids == null) {
        tags.add(Metadata(value: value, type: MetadataTypeEnum.tag));
      }
    }
    return tags;
  }
}

class LinkTestDataFactory {
  static LinkTestData create({
    required String url,
    required String content,
    required List<String> tagValues,
  }) {
    return LinkTestData(
      link: LinkFactory.create(url),
      tags: MetadataFactory.createTags(tagValues),
    );
  }
}
