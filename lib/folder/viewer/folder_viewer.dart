import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/folder/editor.dart';
import 'package:chenron/folder/viewer/folder_data_manager.dart';
import 'package:chenron/folder/viewer/folder_detail_view.dart';
import 'package:chenron/components/folder_layouts/grid.dart';
import 'package:chenron/components/folder_layouts/list.dart';
import 'package:chenron/folder/viewer/tag_search_bar.dart';
import 'package:chenron/responsible_design/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FolderViewSlug extends StatefulWidget {
  const FolderViewSlug({super.key});

  @override
  State<FolderViewSlug> createState() => _FolderViewSlugState();
}

class _FolderViewSlugState extends State<FolderViewSlug> {
  late final FolderViewModel _viewModel;
  late final FolderDataManager _dataManager;
  late final FolderController _controller;

  @override
  void initState() {
    super.initState();
    _viewModel = FolderViewModel();
    _dataManager =
        FolderDataManager(Provider.of<AppDatabase>(context, listen: false));
    _controller = FolderController(_viewModel, _dataManager);
  }

  void _handleDeleteSelected() async {
    final success = await _controller.deleteSelectedFolders();
    if (mounted) {
      _showSnackBar(success);
    }
  }

  void _showSnackBar(bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Folders deleted successfully'
            : 'Failed to delete folders'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<FolderViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('All Folders'),
              actions: [
                IconButton(
                  icon:
                      Icon(viewModel.isGridView ? Icons.list : Icons.grid_view),
                  onPressed: _controller.toggleViewMode,
                ),
              ],
            ),
            body: Column(
              children: [
                SearchBar(
                  onChanged: _controller.updateSearchQuery,
                  onDeleteSelected: _handleDeleteSelected,
                  hasSelectedFolders: viewModel.hasSelectedFolders,
                ),
                TagSearchBar(
                  tagsStream: _dataManager.tagsStream,
                  onTagSelected: _controller.toggleTag,
                  onTagUnselected: _controller.toggleTag,
                  selectedTags: viewModel.selectedTags,
                ),
                Expanded(
                  child: FolderListView(
                    foldersStream: _dataManager.foldersStream,
                    viewModel: viewModel,
                    controller: _controller,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _dataManager.dispose();
    super.dispose();
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final VoidCallback onDeleteSelected;
  final bool hasSelectedFolders;

  const SearchBar({
    super.key,
    required this.onChanged,
    required this.onDeleteSelected,
    required this.hasSelectedFolders,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
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
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: hasSelectedFolders ? onDeleteSelected : null,
            child: const Text('Delete Selected'),
          ),
        ],
      ),
    );
  }
}

class FolderListView extends StatelessWidget {
  final Stream<List<FolderResult>> foldersStream;
  final FolderViewModel viewModel;
  final FolderController controller;

  const FolderListView({
    super.key,
    required this.foldersStream,
    required this.viewModel,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FolderResult>>(
      stream: foldersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final folders = snapshot.data ?? [];
        final filteredFolders = viewModel.filterFolders(folders);

        return viewModel.isGridView
            ? GridFolderView(
                folders: filteredFolders,
                viewModel: viewModel,
                controller: controller,
              )
            : ListFolderView(
                folders: filteredFolders,
                viewModel: viewModel,
                controller: controller,
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
  final Set<String> selectedTags = {};
  final Set<String> selectedFolders = {};

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

  void toggleTag(String tagName) {
    if (selectedTags.contains(tagName)) {
      selectedTags.remove(tagName);
    } else {
      selectedTags.add(tagName);
    }
    notifyListeners();
  }

  void toggleFolderSelection(String folderId) {
    if (selectedFolders.contains(folderId)) {
      selectedFolders.remove(folderId);
    } else {
      selectedFolders.add(folderId);
    }
    notifyListeners();
  }

  void clearSelectedFolders() {
    selectedFolders.clear();
    notifyListeners();
  }

  bool get hasSelectedFolders => selectedFolders.isNotEmpty;

  List<FolderResult> filterFolders(List<FolderResult> folders) {
    final lowerQuery = searchQuery.toLowerCase();
    return folders.where((folder) {
      return folder.folder.title.toLowerCase().contains(lowerQuery) ||
          (folder.tags
              .any((tag) => tag.name.toLowerCase().contains(lowerQuery)));
    }).toList();
  }
}

class FolderController {
  final FolderViewModel _viewModel;
  final FolderDataManager _dataManager;

  FolderController(this._viewModel, this._dataManager);

  void toggleViewMode() {
    _viewModel.setGridView(!_viewModel.isGridView);
  }

  void updateSearchQuery(String query) {
    _viewModel.setSearchQuery(query);
  }

  void toggleTag(String tagName) {
    _viewModel.toggleTag(tagName);
    if (_viewModel.selectedTags.contains(tagName)) {
      _dataManager.selectTag(tagName);
    } else {
      _dataManager.unselectTag(tagName);
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

  void onFolderToggle(String folderId) {
    _viewModel.toggleFolderSelection(folderId);
  }

  Future<bool> deleteSelectedFolders() async {
    bool success = true;
    for (final folder in _viewModel.selectedFolders) {
      if (success) success = await _dataManager.removeFolder(folder);
    }
    _viewModel.clearSelectedFolders();
    return success;
  }
}
