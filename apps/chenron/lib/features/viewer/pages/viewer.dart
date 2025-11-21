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
import "package:signals/signals_flutter.dart";
import "package:url_launcher/url_launcher.dart";
import "package:chenron/utils/logger.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";

class Viewer extends StatefulWidget {
  final SearchFilter? searchFilter;

  const Viewer({super.key, this.searchFilter});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  late final TagFilterState _tagFilterState;

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

  void _handleItemTapWithPresenter(BuildContext context, FolderItem item) {
    final presenter = viewerViewModelSignal.value;

    // Convert FolderItem to ViewerItem format for presenter
    final viewerItem = ViewerItem(
      id: item.id ?? '',
      type: item.type,
      title: item.type == FolderItemType.folder
          ? (item.path as StringContent).value
          : '',
      description: item.type != FolderItemType.folder
          ? (item.path as StringContent).value
          : '',
      url: item.type == FolderItemType.link
          ? (item.path as StringContent).value
          : null,
      tags: item.tags,
      createdAt: item.createdAt ?? DateTime.now(),
    );

    presenter.onItemTap(context, viewerItem);
  }

  Future<void> _handleDeleteRequested(
    BuildContext context,
    List<FolderItem> itemsToDelete,
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
  void initState() {
    super.initState();
    _tagFilterState = TagFilterState();
    final presenter = viewerViewModelSignal.value;
    presenter.init();

    // Set up search submission handler for tag parsing
    if (widget.searchFilter != null) {
      widget.searchFilter!.controller.onSubmitted = (query) {
        loggerGlobal.fine("VIEWER", 'Search submitted with query: "$query"');
        if (query.contains("#")) {
          final cleanQuery = _tagFilterState.parseAndAddFromQuery(query);
          loggerGlobal.fine(
              "VIEWER", 'Clean query after tag parse: "$cleanQuery"');
          loggerGlobal.fine("VIEWER",
              "Tags - included: ${_tagFilterState.includedTagNames}, excluded: ${_tagFilterState.excludedTagNames}");
          // Update the search filter to remove tag patterns
          widget.searchFilter!.controller.value = cleanQuery;
        }
      };
    }
  }

  @override
  void dispose() {
    // Clear the submission handler when page is disposed
    if (widget.searchFilter != null) {
      widget.searchFilter!.controller.onSubmitted = null;
    }
    _tagFilterState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presenter = viewerViewModelSignal.value;

    return Scaffold(
      body: Watch.builder(
        builder: (context) {
          final snapshot = presenter.itemsSignal.value;

          return snapshot.map(
            data: (data) {
              final folderItems = data.map(_viewerItemToFolderItem).toList();

              return ListenableBuilder(
                listenable: presenter,
                builder: (context, _) {
                  return FilterableItemDisplay(
                    items: folderItems,
                    externalSearchFilter: widget.searchFilter,
                    tagFilterState: _tagFilterState,
                    enableTagFiltering: true,
                    displayModeContext: "viewer",
                    showSearch: false,
                    onItemTap: (item) =>
                        _handleItemTapWithPresenter(context, item),
                    onDeleteModeChanged: (
                        {required bool isDeleteMode,
                        required int selectedCount}) {
                      // Optional: Track delete mode state if needed
                    },
                    onDeleteRequested: (items) =>
                        _handleDeleteRequested(context, items),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) {
              return Center(child: Text("Error: $error"));
            },
          );
        },
      ),
    );
  }
}
