import "package:flutter/material.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";
import "package:chenron/shared/dialogs/bulk_tag_dialog.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";
import "package:chenron/shared/viewer/item_deletion_service.dart";
import "package:chenron/shared/viewer/item_tagging_service.dart";
import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:chenron/services/activity_tracker.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";

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
            "Deleted $deletedCount ${deletedCount == 1 ? 'item' : 'items'}",
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );

      // Refresh the view
      onRefresh();
    }
  } catch (e) {
    if (context.mounted) {
      showErrorSnackBar(context, e);
    }
  }
}

/// Handles bulk tagging of multiple items.
///
/// Shows a dialog to enter tag names, applies them to all items,
/// and calls the refresh callback on success.
Future<void> handleItemTagging(
  BuildContext context,
  List<FolderItem> items,
  VoidCallback onRefresh,
) async {
  if (items.isEmpty) return;

  final tagNames = await showBulkTagDialog(
    context: context,
    items: items,
  );
  if (tagNames == null || tagNames.isEmpty || !context.mounted) return;

  try {
    final result =
        await ItemTaggingService().addTagToItems(items, tagNames);

    if (context.mounted) {
      final message = _buildTaggingMessage(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 3),
        ),
      );
      onRefresh();
    }
  } catch (e) {
    if (context.mounted) {
      showErrorSnackBar(context, e);
    }
  }
}

/// Builds a human-readable snackbar message from a [TaggingResult].
///
/// Examples:
///   "Tagged 4 items: +flutter (2 new), +mobile (4 new)"
///   "Tagged 3 items (all already had selected tags)"
String _buildTaggingMessage(TaggingResult result) {
  final items = result.itemCount;
  final itemWord = items == 1 ? "item" : "items";

  if (result.totalNew == 0) {
    return "Tagged $items $itemWord (all already had selected tags)";
  }

  final parts = result.newCountPerTag.entries
      .map((e) => "+${e.key} (${e.value} new)")
      .join(", ");
  return "Tagged $items $itemWord: $parts";
}

/// Handles bulk metadata refresh for selected link items.
///
/// Filters to link items, force-fetches metadata for each, and shows
/// progress via snackbars. The UI updates live via MetadataFactory's
/// lastRefreshedUrl signal.
Future<void> handleItemMetadataRefresh(
  BuildContext context,
  List<FolderItem> items,
  VoidCallback onRefresh,
) async {
  final links = items
      .whereType<LinkItem>()
      .where((l) => l.url.isNotEmpty)
      .toList();

  if (links.isEmpty) return;

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Refreshing metadata for ${links.length} links..."),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int successCount = 0;
  for (final link in links) {
    final result = await MetadataFactory.forceFetch(link.url);
    if (result != null) successCount++;
  }

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Refreshed $successCount of ${links.length} links",
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
