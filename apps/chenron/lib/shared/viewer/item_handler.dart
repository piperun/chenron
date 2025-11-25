import "package:flutter/material.dart";
import "package:database/models/item.dart";
import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";
import "package:database/database.dart" show AppDatabase;
import "package:database/extensions/folder/remove.dart";
import "package:database/extensions/link/remove.dart";
import "package:database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:signals/signals_flutter.dart";

/// Handles item tap by converting FolderItem to ViewerItem and delegating
/// to the presenter's configurable onItemTap method.
void handleItemTap(BuildContext context, FolderItem item) {
  final presenter = viewerViewModelSignal.value;

  // Convert FolderItem to ViewerItem format for presenter
  final viewerItem = ViewerItem(
    id: item.id ?? "",
    type: item.type,
    title: item.type == FolderItemType.folder
        ? (item.path as StringContent).value
        : "",
    description: item.type != FolderItemType.folder
        ? (item.path as StringContent).value
        : "",
    url: item.type == FolderItemType.link
        ? (item.path as StringContent).value
        : null,
    tags: item.tags,
    createdAt: item.createdAt ?? DateTime.now(),
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
      // Extract title from item content
      String title = "";
      if (item.path is StringContent) {
        title = (item.path as StringContent).value;
      } else if (item.path is MapContent) {
        title = (item.path as MapContent).value["title"] ?? "";
      }

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
    final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
    final appDb = db.appDatabase;

    int deletedCount = 0;
    for (final item in itemsToDelete) {
      if (item.id == null) continue;
      final success = await deleteItem(appDb, item);
      if (success) deletedCount++;
    }

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
          content: Text("Failed to delete items: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Deletes a single item from the database based on its type.
///
/// Returns true if deletion was successful, false otherwise.
Future<bool> deleteItem(AppDatabase db, FolderItem item) async {
  switch (item.type) {
    case FolderItemType.folder:
      return await db.removeFolder(item.id!);
    case FolderItemType.link:
      return await db.removeLink(item.id!);
    case FolderItemType.document:
      // TODO: Implement document deletion
      return false;
  }
}

