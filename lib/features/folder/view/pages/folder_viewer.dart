import "package:chenron/components/buttons/small_button.dart";
import "package:chenron/components/item_list/item_list.dart";
import "package:chenron/database/actions/handlers/read_handler.dart"
    show Result;
import "package:chenron/database/database.dart";
import "package:chenron/components/item_list/layout/grid.dart";
import "package:chenron/components/item_list/layout/list.dart";
import "package:chenron/features/folder/view/mvc/folder_viewer_presenter.dart";
import "package:chenron/features/folder/view/ui/tag_search_bar.dart";
import "package:chenron/utils/logger.dart";
import "package:flutter/material.dart";
import "package:signals/signals.dart";
import "package:flutter_hooks/flutter_hooks.dart";

Signal<FolderViewerPresenter> _folderViewerViewModelSignal =
    Signal(FolderViewerPresenter(), autoDispose: true);

class FolderViewer extends StatefulWidget {
  const FolderViewer({super.key});

  @override
  State<FolderViewer> createState() => _FolderViewerState();
}

class _FolderViewerState extends State<FolderViewer> {
  bool hasSelectedFolders = false;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            HeaderBar(),
            Expanded(child: ContentBody()),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "Folders deleted successfully"
            : "Failed to delete folders"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}

class HeaderBar extends StatefulWidget {
  const HeaderBar({super.key});

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  final FolderViewerPresenter viewModel = _folderViewerViewModelSignal.value;
  @override
  void initState() {
    super.initState();
    viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Center(
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OverflowBar(
                    spacing: 5,
                    overflowSpacing: 10,
                    alignment: MainAxisAlignment.spaceBetween,
                    overflowAlignment: OverflowBarAlignment.center,
                    children: [
                      SearchBar(
                        controller: viewModel.searchController,
                        hintText: "Search folders or tags...",
                        onChanged: (value) => setState(() {}),
                      ),
                      const DeleteSelectedButton(),
                    ],
                  )),
              TagSearchBar(
                  tagsStream: viewModel.tagsStream,
                  onTagSelected: viewModel.toggleTag,
                  onTagUnselected: viewModel.toggleTag,
                  selectedTags: viewModel.selectedTags),
            ],
          ),
        );
      },
    );
  }
}

class ContentBody extends HookWidget {
  const ContentBody({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = _folderViewerViewModelSignal.value;

    final foldersStream =
        useMemoized(() => viewModel.foldersStream, [viewModel]);
    final foldersSnapshot = useStream(foldersStream);

    if (foldersSnapshot.hasError) {
      loggerGlobal.warning(
          "FolderViewer", "Error loading folders: ${foldersSnapshot.error}");
      return const Center(
          child: Column(
        children: [
          Icon(Icons.error),
          Text("Error loading folders"),
        ],
      ));
    }

    if (foldersSnapshot.hasData) {
      return ItemList<Result<Folder>>(
        items: foldersSnapshot.data!,
        listItemBuilder: (context, folder) => FolderListItem(
          folder: folder,
          viewModel: viewModel,
        ),
        gridItemBuilder: (context, folder) =>
            FolderGridItem(folder: folder, viewModel: viewModel),
        isItemSelected: (value) => false,
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}

class FolderListItem extends StatelessWidget {
  final Result<Folder> folder;
  final FolderViewerPresenter viewModel;

  const FolderListItem({
    super.key,
    required this.folder,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        final isSelected = viewModel.selectedFolders.contains(folder.data.id);
        return ListItem(
          onTap: () => viewModel.onFolderTap(context, folder),
          title: Text(folder.data.title),
          subtitle: Text(folder.data.description),
          trailing: OverflowBar(
            children: [
              SmallButton(
                onPressed: () => viewModel.onEditTap(context, folder),
                icon: Icons.edit,
                label: "Edit",
                iconSize: 16,
                fontSize: 12,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  viewModel.toggleFolderSelection(folder.data.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class FolderGridItem extends StatelessWidget {
  final Result<Folder> folder;
  final FolderViewerPresenter viewModel;

  const FolderGridItem({
    super.key,
    required this.folder,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        final isSelected = viewModel.selectedFolders.contains(folder.data.id);
        return GridItem(
          onTap: () => viewModel.onFolderTap(context, folder),
          header: GridHeader(
            leading: Text(folder.data.title),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (bool? value) {
                viewModel.toggleFolderSelection(folder.data.id);
              },
            ),
          ),
          body: Text(folder.data.description),
          footer: GridFooter(
            main: TagList(
              tags: folder.tags,
            ),
            trailing: SmallButton(
              onPressed: () => viewModel.onEditTap(context, folder),
              icon: Icons.edit,
              label: "Edit",
              iconSize: 16,
              fontSize: 12,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

class DeleteSelectedButton extends StatefulWidget {
  const DeleteSelectedButton({super.key});

  @override
  State<DeleteSelectedButton> createState() => _DeleteSelectedButtonState();
}

class _DeleteSelectedButtonState extends State<DeleteSelectedButton> {
  final FolderViewerPresenter viewModel = _folderViewerViewModelSignal.value;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return ElevatedButton.icon(
          onPressed: viewModel.selectedFolders.isNotEmpty ? _onTap : null,
          icon: const Icon(Icons.delete),
          label: const Text("Delete Selected"),
        );
      },
    );
  }

  void _onTap() async {
    final success = await viewModel.deleteSelectedFolders();
    _showSnackBar(success);
  }

  void _showSnackBar(bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "Folders deleted successfully"
            : "Failed to delete folders"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}

class TagList extends StatelessWidget {
  final Set<Tag> tags;

  const TagList({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags.map((tag) {
        final color =
            Colors.primaries[tag.name.hashCode % Colors.primaries.length];
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth / 3,
                minHeight: 20,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                tag.name,
                style: TextStyle(
                  color: color.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
