import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/shared/item_display/item_toolbar.dart";
import "package:chenron/shared/item_display/item_stats_bar.dart";
import "package:chenron/shared/item_display/item_grid_view.dart";
import "package:chenron/shared/item_display/item_list_view.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/models/item.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:url_launcher/url_launcher.dart";

class Viewer extends HookWidget {
  const Viewer({super.key});

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

  Map<FolderItemType, int> _getItemCounts(List items) {
    final counts = <FolderItemType, int>{
      FolderItemType.link: 0,
      FolderItemType.document: 0,
      FolderItemType.folder: 0,
    };
    for (final item in items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }
    return counts;
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

  @override
  Widget build(BuildContext context) {
    final presenter = viewerViewModelSignal.value;
    final snapshot = useStream(presenter.itemsStream);

    useEffect(() {
      presenter.init();
      return null;
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
    final itemCounts = _getItemCounts(items);

    return Scaffold(
      body: ListenableBuilder(
        listenable: presenter,
        builder: (context, _) {
          return Column(
            children: [
              ItemToolbar(
                searchQuery: "",
                onSearchChanged: (_) {},
                selectedTypes: presenter.selectedTypes,
                onFilterChanged: presenter.onTypesChanged,
                sortMode: presenter.sortMode,
                onSortChanged: presenter.onSortChanged,
                viewMode: presenter.viewMode,
                onViewModeChanged: presenter.onViewModeChanged,
                showSearch: false,
              ),
              ItemStatsBar(
                linkCount: itemCounts[FolderItemType.link] ?? 0,
                documentCount: itemCounts[FolderItemType.document] ?? 0,
                folderCount: itemCounts[FolderItemType.folder] ?? 0,
                selectedTypes: presenter.selectedTypes,
                onFilterChanged: presenter.onTypesChanged,
              ),
              Expanded(
                child: presenter.viewMode == ViewMode.grid
                    ? ItemGridView(
                        items: folderItems,
                        aspectRatio: 1.2,
                        maxCrossAxisExtent: 280,
                        showImages: false,
                        onItemTap: (item) => _handleItemTap(context, item),
                      )
                    : ItemListView(
                        items: folderItems,
                        showImages: false,
                        onItemTap: (item) => _handleItemTap(context, item),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
