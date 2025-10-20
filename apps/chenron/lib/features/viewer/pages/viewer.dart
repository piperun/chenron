import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/shared/item_display/filterable_item_display.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/models/item.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/tag_filter/tag_filter_state.dart";
import "package:chenron/shared/dialogs/delete_confirmation_dialog.dart";
import "package:chenron/database/database.dart" show AppDatabase;
import "package:chenron/database/extensions/folder/remove.dart";
import "package:chenron/database/extensions/link/remove.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/locator.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:signals/signals.dart";
import "package:url_launcher/url_launcher.dart";
import "package:chenron/utils/logger.dart";

class Viewer extends HookWidget {
  final SearchFilter? searchFilter;

  const Viewer({super.key, this.searchFilter});

  FolderItem _viewerItemToFolderItem(dynamic viewerItem) {
    // For folders, use title as the main content
    // For links, description contains the URL
    final contentValue = viewerItem.type == FolderItemType.folder
        ? viewerItem.title
        : viewerItem.description;

    return FolderItem(
      id: viewerItem.id,
      type: viewerItem.type,
      content: StringContent(value: contentValue),
      createdAt: viewerItem.createdAt,
      tags: viewerItem.tags,
    );
  }

  void _handleItemTap(BuildContext context, FolderItem item) {
    switch (item.type) {
      case FolderItemType.folder:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderViewerPage(folderId: item.id!),
          ),
        );
      case FolderItemType.link:
        final url = (item.path as StringContent).value;
        if (url.isNotEmpty) {
          final uri = Uri.parse(url);
          launchUrl(uri);
        }
      case FolderItemType.document:
        // TODO: Handle document tap
        break;
    }
  }

  Future<void> _handleDeleteRequested(
    BuildContext context,
    List<FolderItem> itemsToDelete,
  ) async {
    if (itemsToDelete.isEmpty) return;

    // Show confirmation dialog
    final confirmed = await showDeleteConfirmationDialog(
      context: context,
      items: itemsToDelete
          .map((item) {
            // Extract title from item content
            String title = '';
            if (item.path is StringContent) {
              title = (item.path as StringContent).value;
            } else if (item.path is MapContent) {
              title = (item.path as MapContent).value['title'] ?? '';
            }
            
            return DeletableItem(
              id: item.id!,
              title: title,
              subtitle: item.type.name,
            );
          })
          .toList(),
    );

    if (!confirmed || !context.mounted) return;

    // Delete items from database
    try {
      final db = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final appDb = db.appDatabase;

      int deletedCount = 0;
      for (final item in itemsToDelete) {
        if (item.id == null) continue;
        final success = await _deleteItem(appDb, item);
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
        final presenter = viewerViewModelSignal.value;
        presenter.init();
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

  Future<bool> _deleteItem(AppDatabase db, FolderItem item) async {
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

  @override
  Widget build(BuildContext context) {
    final presenter = viewerViewModelSignal.value;
    final snapshot = useStream(presenter.itemsStream);
    
    // Create tag filter state that persists for the lifetime of this widget
    final tagFilterState = useMemoized(() => TagFilterState());

    useEffect(() {
      presenter.init();
      
      // Set up search submission handler for tag parsing
      if (searchFilter != null) {
        searchFilter!.controller.onSubmitted = (query) {
          loggerGlobal.fine("VIEWER", 'Search submitted with query: "$query"');
          if (query.contains("#")) {
            final cleanQuery = tagFilterState.parseAndAddFromQuery(query);
            loggerGlobal.fine("VIEWER", 'Clean query after tag parse: "$cleanQuery"');
            loggerGlobal.fine("VIEWER", "Tags - included: ${tagFilterState.includedTagNames}, excluded: ${tagFilterState.excludedTagNames}");
            // Update the search filter to remove tag patterns
            searchFilter!.controller.value = cleanQuery;
          }
        };
      }
      
      return () {
        // Clear the submission handler when page is disposed
        if (searchFilter != null) {
          searchFilter!.controller.onSubmitted = null;
        }
        tagFilterState.dispose();
      };
    }, []);

    if (snapshot.hasError) {
      return Scaffold(
        body: Center(child: Text("Error: ${snapshot.error}")),
      );
    }

    if (!snapshot.hasData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final items = snapshot.data!;
    final folderItems = items.map(_viewerItemToFolderItem).toList();

    return Scaffold(
      body: ListenableBuilder(
        listenable: presenter,
        builder: (context, _) {
          return FilterableItemDisplay(
            items: folderItems,
            externalSearchFilter: searchFilter,
            tagFilterState: tagFilterState,
            enableTagFiltering: true,
            displayModeContext: "viewer",
            showSearch: false,
            onItemTap: (item) => _handleItemTap(context, item),
            onDeleteModeChanged: ({required bool isDeleteMode, required int selectedCount}) {
              // Optional: Track delete mode state if needed
            },
            onDeleteRequested: (items) => _handleDeleteRequested(context, items),
          );
        },
      ),
    );
  }
}
