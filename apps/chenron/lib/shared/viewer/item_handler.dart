import "package:flutter/material.dart";
import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";
import "package:chenron/shared/viewer/item_deletion_service.dart";
import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:chenron/services/activity_tracker.dart";

/// Handles item tap by converting FolderItem to ViewerItem and delegating
/// to the presenter's configurable onItemTap method.
void handleItemTap(BuildContext context, FolderItem item) {
  final presenter = viewerViewModelSignal.value;
  final tracker = locator.get<ActivityTracker>();

  // Track the view event
  final itemId = item.map(
    link: (l) => l.id ?? "",
    document: (d) => d.id ?? "",
    folder: (f) => f.id ?? "",
  );
  if (itemId.isNotEmpty) {
    switch (item.type) {
      case FolderItemType.link:
        tracker.trackLinkViewed(itemId);
      case FolderItemType.document:
        tracker.trackDocumentViewed(itemId);
      case FolderItemType.folder:
        tracker.trackFolderViewed(itemId);
    }
  }

  // Convert FolderItem to ViewerItem format for presenter
  final viewerItem = item.map(
    link: (linkItem) => ViewerItem(
      id: linkItem.id ?? "",
      type: FolderItemType.link,
      title: "",
      description: linkItem.url,
      url: linkItem.url,
      tags: linkItem.tags,
      createdAt: linkItem.createdAt ?? DateTime.now(),
    ),
    document: (docItem) => ViewerItem(
      id: docItem.id ?? "",
      type: FolderItemType.document,
      title: docItem.title,
      description: docItem.filePath,
      url: null,
      tags: docItem.tags,
      createdAt: docItem.createdAt ?? DateTime.now(),
    ),
    folder: (folderItem) => ViewerItem(
      id: folderItem.id ?? "",
      type: FolderItemType.folder,
      title: folderItem.folderId,
      description: "",
      url: null,
      tags: folderItem.tags,
      createdAt: DateTime.now(), // Folders don't have createdAt
    ),
  );

  presenter.onItemTap(context, viewerItem);
}

/// Handles deletion of multiple items with confirmation dialog.
///
/// Shows a confirmation dialog, performs deletion, displays success/error
/// messages, and calls the refresh callback on success.
///
/// [context] - BuildContext for showing dialogs and snackbars
/// [itemsToDelete] - List of items to delete
/// [onRefresh] - Callback to refresh the view after successful deletion
Future<void> handleItemDeletion(
  BuildContext context,
  List<FolderItem> itemsToDelete,
  VoidCallback onRefresh,
) async {
  if (itemsToDelete.isEmpty) return;

  // Show confirmation dialog
  final confirmed = await showDeleteConfirmationDialog(
    context: context,
    items: itemsToDelete.map((item) {
      // Extract title from item
      final title = item.map(
        link: (linkItem) => linkItem.url,
        document: (docItem) => docItem.title,
        folder: (folderItem) => folderItem.folderId,
      );

      return DeletableItem(
        id: item.id!,
        title: title,
        subtitle: item.type.name,
      );
    }).toList(),
  );

  if (!confirmed || !context.mounted) return;

  // Delete items from database
  try {
    final deletedCount = await ItemDeletionService().deleteItems(itemsToDelete);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Successfully deleted $deletedCount ${deletedCount == 1 ? 'item' : 'items'}",
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the view
      onRefresh();
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete items: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
