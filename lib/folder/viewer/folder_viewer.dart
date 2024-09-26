import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/folder/editor.dart';
import 'package:chenron/folder/viewer/folder_detail_view.dart';
import 'package:chenron/components/folder_layouts/grid.dart';
import 'package:chenron/components/folder_layouts/list.dart';
import 'package:chenron/responsible_design/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FolderViewSlug extends StatelessWidget {
  const FolderViewSlug({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FolderViewModel(),
      child: const _FolderViewSlugContent(),
    );
  }
}

class _FolderViewSlugContent extends StatefulWidget {
  const _FolderViewSlugContent({super.key});

  @override
  State<_FolderViewSlugContent> createState() => _FolderViewSlugContentState();
}

class _FolderViewSlugContentState extends State<_FolderViewSlugContent> {
  late final FolderController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        FolderController(Provider.of<FolderViewModel>(context, listen: false));
    _controller.initStream(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('All Folders'),
            actions: [
              IconButton(
                icon: Icon(viewModel.isGridView ? Icons.list : Icons.grid_view),
                onPressed: _controller.toggleViewMode,
              ),
            ],
          ),
          body: Column(
            children: [
              SearchBar(
                onChanged: _controller.updateSearchQuery,
              ),
              Expanded(
                child: FolderListView(
                  viewModel: viewModel,
                  controller: _controller,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const SearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: Breakpoints.responsiveWidth(context),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search folders or tags...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class FolderListView extends StatelessWidget {
  final FolderViewModel viewModel;
  final FolderController controller;

  const FolderListView({
    super.key,
    required this.viewModel,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FolderResult>>(
      stream: viewModel.streamFolders,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final folders = snapshot.data ?? [];
        final filteredFolders = controller.filterFolders(folders);

        return Column(
          children: [
            TagList(tags: controller.getUniqueTags(filteredFolders)),
            Expanded(
              child: viewModel.isGridView
                  ? GridFolderView(
                      folders: filteredFolders,
                      viewModel: viewModel,
                      controller: controller,
                    )
                  : ListFolderView(
                      folders: filteredFolders,
                      viewModel: viewModel,
                      controller: controller,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class TagList extends StatelessWidget {
  final List<Tag> tags;

  const TagList({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: tags.map((tag) => Chip(label: Text(tag.name))).toList(),
    );
  }
}

class GridFolderView extends StatelessWidget {
  final List<FolderResult> folders;
  final FolderViewModel viewModel;
  final FolderController controller;

  const GridFolderView({
    super.key,
    required this.folders,
    required this.viewModel,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GridLayout<FolderResult>(
      items: folders,
      isItemSelected: (folder) =>
          viewModel.selectedFolders.contains(folder.folder.id),
      onItemToggle: (folder) => controller.onFolderToggle(folder.folder.id),
      onTap: (folder) => controller.onFolderTap(context, folder),
      itemBuilder: (folder) => FolderGridItem(
        folder: folder,
        onEditTap: () => controller.onEditTap(context, folder),
      ),
    );
  }
}

class ListFolderView extends StatelessWidget {
  final List<FolderResult> folders;
  final FolderViewModel viewModel;
  final FolderController controller;

  const ListFolderView({
    super.key,
    required this.folders,
    required this.viewModel,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListLayout<FolderResult>(
      items: folders,
      isItemSelected: (folder) =>
          viewModel.selectedFolders.contains(folder.folder.id),
      onItemToggle: (folder) => controller.onFolderToggle(folder.folder.id),
      onTap: (folder) => controller.onFolderTap(context, folder),
      itemBuilder: (folder) => FolderListItem(
        folder: folder,
        onEditTap: () => controller.onEditTap(context, folder),
      ),
    );
  }
}

class FolderGridItem extends StatelessWidget {
  final FolderResult folder;
  final VoidCallback onEditTap;

  const FolderGridItem({
    super.key,
    required this.folder,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(folder.folder.title),
        if (folder.tags.isNotEmpty)
          Wrap(
            children:
                folder.tags.map((tag) => Chip(label: Text(tag.name))).toList(),
          ),
        TextButton.icon(
          onPressed: onEditTap,
          icon: const Icon(Icons.edit),
          label: const Text("Edit"),
        )
      ],
    );
  }
}

class FolderListItem extends StatelessWidget {
  final FolderResult folder;
  final VoidCallback onEditTap;

  const FolderListItem({
    super.key,
    required this.folder,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(folder.folder.title)),
        if (folder.tags.isNotEmpty)
          Wrap(
            children:
                folder.tags.map((tag) => Chip(label: Text(tag.name))).toList(),
          ),
        TextButton.icon(
          onPressed: onEditTap,
          icon: const Icon(Icons.edit),
          label: const Text("Edit"),
        )
      ],
    );
  }
}

class FolderViewModel extends ChangeNotifier {
  bool _isGridView = true;
  String _searchQuery = '';
  final Set<String> selectedFolders = {};
  late Stream<List<FolderResult>> streamFolders;

  bool get isGridView => _isGridView;
  String get searchQuery => _searchQuery;

  void setGridView(bool value) {
    _isGridView = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }
}

class FolderController {
  final FolderViewModel _viewModel;

  FolderController(this._viewModel);

  void initStream(BuildContext context) {
    _viewModel.streamFolders = Provider.of<AppDatabase>(context, listen: false)
        .watchAllFolders(mode: IncludeFolderData.tags);
  }

  void toggleViewMode() {
    _viewModel.setGridView(!_viewModel.isGridView);
  }

  void updateSearchQuery(String query) {
    _viewModel.setSearchQuery(query);
  }

  void onFolderToggle(String folderId) {
    if (_viewModel.selectedFolders.contains(folderId)) {
      _viewModel.selectedFolders.remove(folderId);
    } else {
      _viewModel.selectedFolders.add(folderId);
    }
  }

  void onFolderTap(BuildContext context, FolderResult folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderDetailView(folderId: folder.folder.id),
      ),
    );
  }

  void onEditTap(BuildContext context, FolderResult folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderEditor(
          folderId: folder.folder.id,
        ),
      ),
    );
  }

  List<FolderResult> filterFolders(List<FolderResult> folders) {
    final lowerQuery = _viewModel.searchQuery.toLowerCase();
    return folders.where((folder) {
      return folder.folder.title.toLowerCase().contains(lowerQuery) ||
          (folder.tags
              .any((tag) => tag.name.toLowerCase().contains(lowerQuery)));
    }).toList();
  }

  List<Tag> getUniqueTags(List<FolderResult> folders) {
    return folders
        .where((f) => f.tags.isNotEmpty)
        .expand((f) => f.tags)
        .toSet()
        .toList();
  }
}
