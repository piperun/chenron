import "dart:async";
import "dart:math";

import "package:cache_manager/cache_manager.dart";
import "package:catalog/catalog.dart";
import "package:flutter/material.dart";
import "package:chenron/features/bulk_tag/pages/bulk_tag_dialog.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/features/viewer/services/viewer_bulk_service.dart";
import "package:chenron/features/settings/coordinator/settings_coordinator.dart";
import "package:chenron/shared/item_detail/item_detail_dialog.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";
import "package:chenron/shared/viewer/item_deletion_service.dart";
import "package:chenron/shared/viewer/item_tagging_service.dart";
import "package:database/database.dart";
import "package:database/features.dart";
import "package:chenron/locator.dart";
import "package:chenron/services/activity_tracker.dart";
import "package:chenron/shared/errors/error_snack_bar.dart";
import "package:chenron/shared/navigation/activity_log_request.dart";
import "package:signals/signals.dart";
import "package:url_launcher/url_launcher.dart";

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

/// Opens a [FolderItem] according to the user's item-click preference.
///
/// This is deliberately stateless so folder pages can preserve the main
/// viewer's routing behaviour without constructing a viewer presenter.
void openFolderItem(BuildContext context, FolderItem item) {
  final action = ItemClickAction.values[locator
      .get<SettingsCoordinator>()
      .display
      .current
      .peek()
      .itemClickAction];
  if (action == ItemClickAction.showDetails) {
    showItemDetailDialog(context, itemId: item.id!, itemType: item.type);
    return;
  }
  switch (item.type) {
    case FolderItemType.folder:
      unawaited(Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => FolderViewerPage(
            folderId: item.id!,
            onItemTap: openFolderItem,
          ),
        ),
      ));
    case FolderItemType.link:
      final url = item.map(
        link: (link) => link.url,
        document: (_) => null,
        folder: (_) => null,
      );
      if (url != null && url.isNotEmpty) unawaited(openExternalUrl(url));
    case FolderItemType.document:
      break;
  }
}

Future<void> openExternalUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) await launchUrl(uri);
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

Future<void> handleViewerSelectionDeletion(
  BuildContext context,
  CatalogSelectionTarget<ViewerItemKey, ViewerQuery> target,
  ViewerBulkService service,
  VoidCallback onRefresh,
) async {
  if (target.selectedCount == 0 || !target.isCurrent) return;
  final confirmed = await showDeleteConfirmationDialog(
    context: context,
    itemCount: target.selectedCount,
  );
  if (!confirmed || !context.mounted || !target.isCurrent) return;

  try {
    final result = await service.delete(
      target.selection,
      expectedCount: target.selectedCount,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewerBulkMessage("Deleted", result)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
    onRefresh();
  } catch (error) {
    if (context.mounted) showErrorSnackBar(context, error);
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
      final addResult = await service.addTagToItems(items, result.tagsToAdd);
      messages.add(_buildTaggingMessage(addResult));
    }

    if (result.tagsToRemove.isNotEmpty) {
      final removeResult =
          await service.removeTagFromItems(items, result.tagsToRemove);
      messages.add(_buildRemovalMessage(removeResult));
    }

    if (result.colorChanges.isNotEmpty) {
      final db = locator.get<Signal<AppDatabaseLifecycle>>().value.appDatabase;
      for (final entry in result.colorChanges.entries) {
        await db.updateTagColor(tagName: entry.key, color: entry.value);
      }
      final n = result.colorChanges.length;
      messages.add("Recolored $n ${n == 1 ? 'tag' : 'tags'}");
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

Future<void> handleViewerSelectionTagging(
  BuildContext context,
  CatalogSelectionTarget<ViewerItemKey, ViewerQuery> target,
  ViewerBulkService service,
  VoidCallback onRefresh,
) async {
  if (target.selectedCount == 0 || !target.isCurrent) return;
  final tagResult = await showBulkTagDialog(
    context: context,
    itemCount: target.selectedCount,
  );
  if (tagResult == null ||
      tagResult.isEmpty ||
      !context.mounted ||
      !target.isCurrent) {
    return;
  }

  try {
    final result = await service.tag(
      target.selection,
      tagsToAdd: tagResult.tagsToAdd.toSet(),
      tagsToRemove: tagResult.tagsToRemove.toSet(),
      colorChanges: tagResult.colorChanges,
      expectedCount: target.selectedCount,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewerBulkMessage("Tagged", result)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
    onRefresh();
  } catch (error) {
    if (context.mounted) showErrorSnackBar(context, error);
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
/// progress via snackbars. Every card pointing at a refreshed URL is
/// bound to the shared [MetadataService] signal, so the new metadata
/// renders live without a separate dispatcher.
Future<void> handleItemMetadataRefresh(
  BuildContext context,
  List<FolderItem> items,
) async {
  final urls = items
      .whereType<LinkItem>()
      .where((l) => l.url.isNotEmpty)
      .map((link) => link.url)
      .toSet()
      .toList(growable: false);

  if (urls.isEmpty) return;

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Refreshing metadata for ${urls.length} links..."),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  final service = locator.get<MetadataService>();
  final summary = await refreshMetadataUrls(
    urls,
    refreshOne: service.forceFetch,
  );

  if (context.mounted) {
    final viewLogAction = summary.failed == 0
        ? null
        : _ViewLogSnackBarAction(
            textColor: Theme.of(context).colorScheme.onPrimary);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(metadataRefreshSummaryMessage(summary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: Duration(seconds: viewLogAction == null ? 3 : 6),
        action: viewLogAction,
      ),
    );
  }
}

/// "View Log" action for metadata-refresh summary toasts, attached only
/// when some fetches failed. Fetch results are recorded as background
/// jobs, so the Activity Log (failed filter pre-selected) shows exactly
/// these failures.
class _ViewLogSnackBarAction extends SnackBarAction {
  const _ViewLogSnackBarAction({required super.textColor})
      : super(label: "View Log", onPressed: requestActivityLogOpen);
}

Future<void> handleViewerSelectionMetadataRefresh(
  BuildContext context,
  CatalogSelectionTarget<ViewerItemKey, ViewerQuery> target,
  ViewerBulkService service,
) async {
  if (target.selectedCount == 0 || !target.isCurrent) return;
  try {
    final result = await service.refreshMetadata(
      target.selection,
      expectedCount: target.selectedCount,
    );
    if (!context.mounted) return;
    final viewLogAction = result.failed == 0
        ? null
        : _ViewLogSnackBarAction(
            textColor: Theme.of(context).colorScheme.onPrimary);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewerBulkMessage("Metadata refreshed for", result)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: Duration(seconds: viewLogAction == null ? 3 : 6),
        action: viewLogAction,
      ),
    );
  } catch (error) {
    if (context.mounted) {
      showErrorSnackBar(context, error, showActivityLogAction: true);
    }
  }
}

String _viewerBulkMessage(String action, ViewerBulkResult result) {
  final failureSuffix = result.failed == 0 ? "" : ", ${result.failed} failed";
  return "$action ${result.succeeded} of ${result.processed} items"
      "$failureSuffix";
}

/// Refresh unique metadata URLs with a fixed number of workers.
Future<MetadataRefreshSummary> refreshMetadataUrls(
  Iterable<String> urls, {
  required Future<MetadataRefreshResult> Function(String url) refreshOne,
  int maxConcurrent = 3,
}) async {
  if (maxConcurrent <= 0) {
    throw ArgumentError.value(
      maxConcurrent,
      "maxConcurrent",
      "must be greater than zero",
    );
  }

  final queue = urls.toSet().toList(growable: false);
  if (queue.isEmpty) return const MetadataRefreshSummary();

  var nextIndex = 0;
  var summary = const MetadataRefreshSummary();

  Future<void> worker() async {
    while (true) {
      final index = nextIndex;
      if (index >= queue.length) return;
      nextIndex = index + 1;

      try {
        final result = await refreshOne(queue[index]);
        summary = summary.add(result.outcome);
      } catch (_) {
        summary = summary.add(MetadataRefreshOutcome.failed);
      }
    }
  }

  final workerCount = min(maxConcurrent, queue.length);
  await Future.wait(List.generate(workerCount, (_) => worker()));
  return summary;
}

String metadataRefreshSummaryMessage(MetadataRefreshSummary summary) =>
    "Metadata: ${summary.updated} updated, "
    "${summary.unchanged} unchanged, "
    "${summary.skipped} skipped, "
    "${summary.rejected} rejected, "
    "${summary.failed} failed";
