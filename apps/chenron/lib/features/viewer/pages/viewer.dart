import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/shared/item_display/filterable_item_display.dart";
import "package:chenron/features/folder_viewer/pages/folder_viewer_page.dart";
import "package:chenron/models/item.dart";
import "package:chenron/shared/search/search_filter.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:url_launcher/url_launcher.dart";

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

    return Scaffold(
      body: ListenableBuilder(
        listenable: presenter,
        builder: (context, _) {
          return FilterableItemDisplay(
            items: folderItems,
            externalSearchFilter: searchFilter,
            enableTagFiltering: true,
            displayModeContext: "viewer",
            showSearch: false,
            onItemTap: (item) => _handleItemTap(context, item),
          );
        },
      ),
    );
  }
}
