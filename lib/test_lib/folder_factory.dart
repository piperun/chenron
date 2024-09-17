import 'package:chenron/data_struct/folder.dart';
import 'package:chenron/data_struct/item.dart';
import 'package:chenron/data_struct/metadata.dart';

class FolderTestData {
  final FolderInfo folder;
  final List<Metadata> tags;
  final List<FolderItem> items;

  FolderTestData(
      {required this.folder, required this.tags, required this.items});
}

class FolderTestDataFactory {
  static FolderTestData createActiveFolder() {
    return FolderTestData(
      folder: FolderInfo(
        title: "Test Read Folder 1",
        description: "This folder is for testing read operations",
      ),
      tags: [
        Metadata(value: 'ActiveTag1', type: MetadataTypeEnum.tag),
        Metadata(value: 'ActiveTag2', type: MetadataTypeEnum.tag),
      ],
      items: [
        FolderItem(
            type: FolderItemType.link,
            content: StringContent('https://example.com')),
        FolderItem(
            type: FolderItemType.document,
            content:
                MapContent({'title': 'Active Doc', 'body': 'Active content'})),
      ],
    );
  }

  static FolderTestData createInactiveFolder() {
    return FolderTestData(
      folder: FolderInfo(
        title: "Inactive Test Folder",
        description: "This folder is inactive for testing purposes",
      ),
      tags: [
        Metadata(value: 'InactiveTag1', type: MetadataTypeEnum.tag),
        Metadata(value: 'InactiveTag2', type: MetadataTypeEnum.tag),
      ],
      items: [
        FolderItem(
            type: FolderItemType.link,
            content: StringContent('https://inactive.com')),
        FolderItem(
            type: FolderItemType.document,
            content: MapContent(
                {'title': 'Inactive Doc', 'body': 'Inactive content'})),
      ],
    );
  }
}
