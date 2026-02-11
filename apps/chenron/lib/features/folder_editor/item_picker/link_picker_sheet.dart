import "package:database/database.dart";
import "package:database/main.dart";
import "package:flutter/material.dart";

import "package:chenron/features/folder_editor/item_picker/item_picker_service.dart";
import "package:chenron/features/folder_editor/item_picker/item_picker_sheet.dart";
import "package:chenron/locator.dart";
import "package:signals/signals.dart";

class LinkPickerSheet extends StatelessWidget {
  final List<FolderItem> currentFolderItems;
  final VoidCallback? onCreateNew;

  const LinkPickerSheet({
    super.key,
    required this.currentFolderItems,
    this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    final AppDatabase db =
        locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;
    final service = ItemPickerService(db);

    return ItemPickerSheet<LinkResult, FolderItem>(
      loadItems: () => service.getAvailableLinks(
        currentFolderItems: currentFolderItems,
      ),
      itemId: (link) => link.data.id,
      itemTitle: (link) => link.data.path,
      itemSubtitle: (link) {
        final tagLine = link.tags.map((Tag t) => t.name).join(", ");
        return tagLine.isNotEmpty ? tagLine : null;
      },
      toResults: (selected) => selected
          .map((link) => link.data.toFolderItem(null, tags: link.tags))
          .toList(),
      headerIcon: Icons.link,
      headerTitle: "Add Existing Links",
      itemIcon: Icons.link,
      searchHint: "Search links by URL...",
      emptyIcon: Icons.link_off,
      emptyMessage: "All links are already in this folder",
      emptySearchMessage: "No links match your search",
      createNewLabel: onCreateNew != null ? "Create New Link" : null,
      onCreateNew: onCreateNew,
    );
  }
}
