import "dart:async";
import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/shared/item_display/filterable_item_display.dart";
import "package:database/models/item.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:chenron/shared/tag_filter/tag_filter_state.dart";
import "package:flutter/material.dart";
import "package:signals/signals_flutter.dart";
import "package:logger/logger.dart";
import "package:chenron/shared/viewer/item_handler.dart";
import "package:chenron/features/viewer/ui/viewer_base_item.dart";

class Viewer extends StatefulWidget {
  final SearchFilter? searchFilter;

  const Viewer({super.key, this.searchFilter});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  late final TagFilterState _tagFilterState;

  FolderItem _viewerItemToFolderItem(ViewerItem viewerItem) {
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

  @override
  void initState() {
    super.initState();
    _tagFilterState = TagFilterState();
    final presenter = viewerViewModelSignal.value;
    unawaited(presenter.init());

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
                    onItemTap: (item) => handleItemTap(context, item),
                    onDeleteModeChanged: (
                        {required bool isDeleteMode,
                        required int selectedCount}) {
                      // Optional: Track delete mode state if needed
                    },
                    onDeleteRequested: (items) => handleItemDeletion(
                      context,
                      items,
                      () => viewerViewModelSignal.value.init(),
                    ),
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

