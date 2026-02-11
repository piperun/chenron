import "package:database/database.dart";
import "package:database/main.dart";
import "package:flutter/material.dart";

import "package:chenron/features/folder_editor/item_picker/item_picker_service.dart";
import "package:chenron/features/folder_editor/item_picker/item_picker_sheet.dart";
import "package:chenron/locator.dart";
import "package:signals/signals.dart";

class DocumentPickerSheet extends StatelessWidget {
  final List<FolderItem> currentFolderItems;
  final VoidCallback? onCreateNew;

  const DocumentPickerSheet({
    super.key,
    required this.currentFolderItems,
    this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    final AppDatabase db =
        locator.get<Signal<AppDatabaseHandler>>().value.appDatabase;
    final service = ItemPickerService(db);

    return ItemPickerSheet<Document, FolderItem>(
      loadItems: () => service.getAvailableDocuments(
        currentFolderItems: currentFolderItems,
      ),
      itemId: (doc) => doc.id,
      itemTitle: (doc) => doc.title,
      itemSubtitle: (doc) => doc.filePath,
      toResults: (selected) =>
          selected.map((doc) => doc.toFolderItem(null)).toList(),
      headerIcon: Icons.description,
      headerTitle: "Add Existing Documents",
      itemIcon: Icons.description,
      searchHint: "Search documents by title...",
      emptyIcon: Icons.description_outlined,
      emptyMessage: "All documents are already in this folder",
      emptySearchMessage: "No documents match your search",
      createNewLabel: onCreateNew != null ? "Create New Document" : null,
      onCreateNew: onCreateNew,
    );
  }
}
