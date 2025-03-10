import "dart:async";

import "package:chenron/database/actions/handlers/read_handler.dart"
    show Result;
import "package:chenron/database/database.dart";
import "package:chenron/features/editor/pages/editor.dart";
import "package:chenron/features/show_folder/pages/show_folder.dart";
import "package:chenron/features/folder/view/mvc/folder_viewer_model.dart";
import "package:flutter/material.dart";

class FolderViewerPresenter extends ChangeNotifier {
  List<Result<Folder>> _currentFolders = [];
  final Set<String> selectedFolders = {};
  final Set<String> selectedTags = {};
  final SearchController searchController = SearchController();

  final _tagsController = StreamController<List<Tag>>.broadcast();
  final _foldersController = StreamController<List<Result<Folder>>>.broadcast();

  final FolderViewerModel _model = FolderViewerModel();
  Stream<List<Result<Folder>>>? _allFoldersStream;

  Stream<List<Tag>> get tagsStream => _tagsController.stream;
  Stream<List<Result<Folder>>> get foldersStream => _foldersController.stream;

  FolderViewerPresenter() {
    searchController.addListener(_onSearchChanged);
  }

  Future<void> init() async {
    _allFoldersStream = _model.watchAllFolders();
    _allFoldersStream!.listen(_processFolders);
    notifyListeners();
  }

  Future<bool> deleteSelectedFolders() async {
    bool success = true;
    for (final folder in selectedFolders) {
      if (success) success = await _model.removeFolder(folder);
    }
    clearSelectedFolders();
    return success;
  }

  void clearSelectedFolders() {
    selectedFolders.clear();
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

  void onFolderTap(BuildContext context, Result<Folder> folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowFolder(folderId: folder.data.id),
      ),
    );
  }

  void onEditTap(BuildContext context, Result<Folder> folder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderEditor(
          folderId: folder.data.id,
        ),
      ),
    );
  }

  void toggleFolderSelection(String folderId) {
    if (selectedFolders.contains(folderId)) {
      selectedFolders.remove(folderId);
    } else {
      selectedFolders.add(folderId);
    }
    notifyListeners();
  }

  void _filterFolderTags(List<Result<Folder>> folders) {
    final allTags = _extractUniqueTags(folders);
    _tagsController.add(allTags);
  }

  void _onSearchChanged() {
    _filterAndAddFolders(_currentFolders);
  }

  void _filterAndAddFolders(List<Result<Folder>> folders) {
    _currentFolders = folders;
    final searchQuery = searchController.text.toLowerCase();

    var filteredFolders = folders;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filteredFolders = folders.where((folder) {
        return folder.data.title.toLowerCase().contains(searchQuery) ||
            folder.tags
                .any((tag) => tag.name.toLowerCase().contains(searchQuery));
      }).toList();
    }

    // Apply tag filter
    if (selectedTags.isNotEmpty) {
      filteredFolders = filteredFolders.where((folder) {
        return folder.tags.any((tag) => selectedTags.contains(tag.name));
      }).toList();
    }

    _foldersController.add(filteredFolders);
  }

  void _processFolders(List<Result<Folder>> folders) {
    _filterFolderTags(folders);
    _filterAndAddFolders(folders);
  }

  List<Tag> _extractUniqueTags(List<Result<Folder>> folders) {
    return folders.expand((folder) => folder.tags).toSet().toList();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _tagsController.close();
    _foldersController.close();
    super.dispose();
  }
}
