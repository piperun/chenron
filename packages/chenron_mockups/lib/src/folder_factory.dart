import "package:database/models/folder.dart";
import "package:database/models/item.dart";
import "package:database/models/metadata.dart";

class FolderTestData {
  final FolderDraft folder;
  final List<Metadata> tags;
  final List<FolderItem> items;

  FolderTestData(
      {required this.folder, required this.tags, required this.items});
}

class FolderDraftFactory {
  static FolderDraft create(String title, String description) {
    return FolderDraft(title: title, description: description);
  }
}

class MetadataFactory {
  static List<Metadata> createTags(List<String> tagValues,
      {Map<String, String>? ids, Map<String, String>? metadataIds}) {
    final List<Metadata> tags = [];
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
        return createLink(item["content"] as String);
      } else if (item["type"] == "document") {
        return createDocument(item["content"]["title"] as String,
            item["content"]["body"] as String);
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
      folder: FolderDraftFactory.create(title, description),
      tags: MetadataFactory.createTags(tagValues),
      items: FolderItemFactory.createItems(itemsData),
    );
  }
}
