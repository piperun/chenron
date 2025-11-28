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
  static FolderDraft create(String title, String description, {int? color}) {
    return FolderDraft(title: title, description: description, color: color);
  }

  /// Creates a folder with a random color
  static FolderDraft createWithRandomColor(String title, String description) {
    final random = DateTime.now().millisecondsSinceEpoch % 0xFFFFFF;
    final color = 0xFF000000 | random; // Full opacity + random RGB
    return FolderDraft(title: title, description: description, color: color);
  }
}

class MetadataFactory {
  static List<Metadata> createTags(List<String> tagValues,
      {Map<String, String>? ids,
      Map<String, String>? metadataIds,
      Map<String, int>? colors}) {
    final List<Metadata> tags = [];
    for (String value in tagValues) {
      final color = colors?[value];
      if (ids != null) {
        tags.add(Metadata(
            id: ids[value],
            value: value,
            type: MetadataTypeEnum.tag,
            color: color));
      }
      if (metadataIds != null) {
        tags.add(Metadata(
            metadataId: metadataIds[value],
            value: value,
            type: MetadataTypeEnum.tag,
            color: color));
      }
      if (metadataIds == null && ids == null) {
        tags.add(
            Metadata(value: value, type: MetadataTypeEnum.tag, color: color));
      }
    }
    return tags;
  }

  /// Creates tags with random colors
  static List<Metadata> createTagsWithRandomColors(List<String> tagValues) {
    final colors = <String, int>{};
    for (var value in tagValues) {
      final random =
          (DateTime.now().millisecondsSinceEpoch + value.hashCode) % 0xFFFFFF;
      colors[value] = 0xFF000000 | random; // Full opacity + random RGB
    }
    return createTags(tagValues, colors: colors);
  }
}

class FolderItemFactory {
  static FolderItem createLink(String url) {
    return FolderItem.link(url: url);
  }

  static FolderItem createDocument(String title, String body) {
    return FolderItem.document(
      title: title,
      filePath: body,
    );
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
    int? color,
  }) {
    return FolderTestData(
      folder: FolderDraftFactory.create(title, description, color: color),
      tags: MetadataFactory.createTags(tagValues),
      items: FolderItemFactory.createItems(itemsData),
    );
  }

  /// Creates test data with random colors for folder and tags
  static FolderTestData createWithRandomColors({
    required String title,
    required String description,
    required List<String> tagValues,
    required List<Map<String, dynamic>> itemsData,
  }) {
    return FolderTestData(
      folder: FolderDraftFactory.createWithRandomColor(title, description),
      tags: MetadataFactory.createTagsWithRandomColors(tagValues),
      items: FolderItemFactory.createItems(itemsData),
    );
  }
}
