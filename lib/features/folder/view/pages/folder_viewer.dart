import "package:chenron/components/buttons/small_button.dart";
import "package:chenron/components/item_list/item_list.dart";
import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/components/item_list/layout/grid.dart";
import "package:chenron/components/item_list/layout/list.dart";
import "package:chenron/features/folder/view/mvc/folder_viewer_presenter.dart";
import "package:chenron/features/folder/view/ui/tag_search_bar.dart";
import "package:flutter/material.dart";
import "package:signals/signals.dart";

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
      body: FolderViewerBody(
        header: HeaderBar(),
        body: ContentBody(),
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

class FolderViewerBody extends StatelessWidget {
  final Widget? header;
  final Widget? body;
  final Widget? footer;
  const FolderViewerBody({this.header, this.body, this.footer, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header != null) header!,
            if (body != null) Expanded(child: body!),
            if (footer != null) footer!,
          ],
        ));
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
    // Initialize _futureMd5 with a default value or null if not needed
    viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Column(
          children: [
            const Padding(
                padding: EdgeInsets.all(8.0),
                child: OverflowBar(
                  spacing: 5,
                  overflowSpacing: 10,
                  alignment: MainAxisAlignment.spaceBetween,
                  overflowAlignment: OverflowBarAlignment.center,
                  children: [
                    SearchBar(
                      hintText: "Search folders or tags...",
                    ),
                    DeleteSelectedButton(),
                  ],
                )),
            TagSearchBar(
                tagsStream: viewModel.tagsStream,
                onTagSelected: viewModel.toggleTag,
                onTagUnselected: viewModel.toggleTag,
                selectedTags: viewModel.selectedTags)
          ],
        );
      },
    );
  }
}

class ContentBody extends StatefulWidget {
  const ContentBody({super.key});

  @override
  State<ContentBody> createState() => _ContentBodyState();
}

class _ContentBodyState extends State<ContentBody> {
  final FolderViewerPresenter viewModel = _folderViewerViewModelSignal.value;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FolderResult>>(
      stream: viewModel.foldersStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ItemList<FolderResult>(
            items: snapshot.data!,
            listItemBuilder: (context, folder) => FolderListItem(
              folder: folder,
              viewModel: viewModel,
            ),
            gridItemBuilder: (context, folder) =>
                FolderGridItem(folder: folder, viewModel: viewModel),
            isItemSelected: (value) => false,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class FolderListItem extends StatelessWidget {
  final FolderResult folder;
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
        final isSelected = viewModel.selectedFolders.contains(folder.folder.id);
        return ListItem(
          onTap: () => viewModel.onFolderTap(context, folder),
          title: Text(folder.folder.title),
          subtitle: Text(folder.folder.description),
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
                  viewModel.toggleFolderSelection(folder.folder.id);
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
  final FolderResult folder;
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
        final isSelected = viewModel.selectedFolders.contains(folder.folder.id);
        return GridItem(
          onTap: () => viewModel.onFolderTap(context, folder),
          header: GridHeader(
            leading: Text(folder.folder.title),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (bool? value) {
                viewModel.toggleFolderSelection(folder.folder.id);
              },
            ),
          ),
          body: Text(folder.folder.description),
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
  final List<Tag> tags;

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
