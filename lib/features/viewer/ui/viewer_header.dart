import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/models/item.dart";
import "package:flutter/material.dart";

const double _headerSpacing = 8.0;

class ViewerHeader extends StatelessWidget {
  const ViewerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = viewerViewModelSignal.value;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(
        children: [
          SegmentedButton<FolderItemType>(
            multiSelectionEnabled: true,
            segments: const [
              ButtonSegment(
                value: FolderItemType.folder,
                icon: Icon(Icons.folder),
                label: Text("Folders"),
                tooltip: "Show folders",
              ),
              ButtonSegment(
                value: FolderItemType.link,
                icon: Icon(Icons.link),
                label: Text("Links"),
                tooltip: "Show links",
              ),
              ButtonSegment(
                value: FolderItemType.document,
                icon: Icon(Icons.description),
                label: Text("Documents"),
                tooltip: "Show documents",
              ),
            ],
            selected: viewModel.selectedTypes,
            onSelectionChanged: viewModel.onTypesChanged,
          ),
          const SizedBox(height: _headerSpacing),
          SearchBar(
            hintText: "Search all items...",
            leading: const Icon(Icons.search),
            controller: viewModel.searchController,
            trailing: [
              if (viewModel.searchController.text.isNotEmpty)
                IconButton(
                  onPressed: () => viewModel.searchController.clear(),
                  icon: const Icon(Icons.clear),
                  tooltip: "Clear search",
                ),
            ],
          ),
        ],
      ),
    );
  }
}
