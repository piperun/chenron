import "package:flutter/material.dart";
import "package:chenron/components/metadata_factory.dart";
import "package:chenron/features/bulk_tag/pages/bulk_tag_dialog.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";
import "package:chenron/shared/viewer/item_deletion_service.dart";
import "package:chenron/shared/viewer/item_tagging_service.dart";
import "package:database/database.dart";
import "package:chenron/locator.dart";
import "package:chenron/services/activity_tracker.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";

/// Tracks the item view event and delegates the tap to [onTap].
///
/// The caller provides the concrete routing behaviour so this shared
/// utility has no dependency on the viewer feature's presenter or
/// global signals.
void handleItemTap(
  BuildContext context,
  FolderItem item,
  void Function(BuildContext, FolderItem) onTap,
) {
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

  onTap(context, item);
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

/// Handles bulk tag management (add + remove) for multiple items.
///
/// Shows the tag dialog, processes the result for both additions and
/// removals, and calls the refresh callback on success.
Future<void> handleItemTagging(
  BuildContext context,
  List<FolderItem> items,
  VoidCallback onRefresh,
) async {
  if (items.isEmpty) return;

  final result = await showBulkTagDialog(
    context: context,
    items: items,
  );
  if (result == null || result.isEmpty || !context.mounted) return;

  try {
    final service = ItemTaggingService();
    final messages = <String>[];

    if (result.tagsToAdd.isNotEmpty) {
      final addResult =
          await service.addTagToItems(items, result.tagsToAdd);
      messages.add(_buildTaggingMessage(addResult));
    }

    if (result.tagsToRemove.isNotEmpty) {
      final removeResult =
          await service.removeTagFromItems(items, result.tagsToRemove);
      messages.add(_buildRemovalMessage(removeResult));
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messages.join(" | ")),
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

String _buildTaggingMessage(TaggingResult result) {
  final items = result.itemCount;
  final itemWord = items == 1 ? "item" : "items";

  if (result.totalNew == 0) {
    return "+${result.newCountPerTag.keys.join(", +")} ($items $itemWord, all had them)";
  }

  final parts = result.newCountPerTag.entries
      .map((e) => "+${e.key} (${e.value} new)")
      .join(", ");
  return parts;
}

String _buildRemovalMessage(TagRemovalResult result) {
  if (result.totalRemoved == 0) {
    return "Removed 0 tags";
  }

  return result.removedCountPerTag.entries
      .where((e) => e.value > 0)
      .map((e) => "-${e.key} (${e.value})")
      .join(", ");
}

/// Handles bulk metadata refresh for selected link items.
///
/// Filters to link items, force-fetches metadata for each, and shows
/// progress via snackbars. The UI updates live via MetadataFactory's
/// lastRefreshedUrl signal.
Future<void> handleItemMetadataRefresh(
  BuildContext context,
  List<FolderItem> items,
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

  final results = await Future.wait(
    links.map((link) => MetadataFactory.forceFetch(link.url)),
  );
  final successCount = results.where((r) => r != null).length;

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
