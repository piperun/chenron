import "package:chenron/models/folder.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";

class FolderTestData {
  final FolderInfo folder;
  final List<Metadata> tags;
  final List<FolderItem> items;

  FolderTestData(
      {required this.folder, required this.tags, required this.items});
}

class FolderInfoFactory {
  static FolderInfo create(String title, String description) {
    return FolderInfo(title: title, description: description);
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

class FolderItemFactory {
  static FolderItem createLink(String url) {
    return FolderItem(
        type: FolderItemType.link, content: StringContent(value: url));
  }

  static FolderItem createDocument(String title, String body) {
    return FolderItem(
        type: FolderItemType.document,
        content: MapContent(value: {"title": title, "body": body}));
  }

  static List<FolderItem> createItems(List<Map<String, dynamic>> itemsData) {
    return itemsData.map((item) {
      if (item["type"] == "link") {
        return createLink(item["content"]);
      } else if (item["type"] == "document") {
        return createDocument(
            item["content"]["title"], item["content"]["body"]);
      }
      throw ArgumentError("Invalid item type");
    }).toList();
  }
}

class FolderTestDataFactory {
  static FolderTestData create({
    required String title,
    required String description,
    required List<String> tagValues,
    required List<Map<String, dynamic>> itemsData,
  }) {
    return FolderTestData(
      folder: FolderInfoFactory.create(title, description),
      tags: MetadataFactory.createTags(tagValues),
      items: FolderItemFactory.createItems(itemsData),
    );
  }
}
