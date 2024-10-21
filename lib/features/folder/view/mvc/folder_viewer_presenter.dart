import "dart:async";

import "package:chenron/database/database.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/features/folder/edit/pages/editor.dart";
import "package:chenron/features/folder/view/pages/folder_detail_view.dart";
import "package:chenron/features/folder/view/mvc/folder_viewer_model.dart";
import "package:flutter/material.dart";

class FolderViewerPresenter extends ChangeNotifier {
  final Set<String> selectedFolders = {};
  final Set<String> selectedTags = {};

  final _tagsController = StreamController<List<Tag>>.broadcast();
  final _foldersController = StreamController<List<FolderResult>>.broadcast();
  final FolderViewerModel _model = FolderViewerModel();
  Stream<List<FolderResult>>? _allFoldersStream;

  Stream<List<Tag>> get tagsStream => _tagsController.stream;
  Stream<List<FolderResult>> get foldersStream => _foldersController.stream;

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

/*
    void toggleTag(String tagName) {
    _viewModel.toggleTag(tagName);
    if (_viewModel.selectedTags.contains(tagName)) {
      _dataManager.selectTag(tagName);
    } else {
      _dataManager.unselectTag(tagName);
    }
  }
*/
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

  void toggleFolderSelection(String folderId) {
    if (selectedFolders.contains(folderId)) {
      selectedFolders.remove(folderId);
    } else {
      selectedFolders.add(folderId);
    }
    notifyListeners();
  }

  void _filterFolderTags(List<FolderResult> folders) {
    final allTags = _extractUniqueTags(folders);
    _tagsController.add(allTags);
  }

  void _filterAndAddFolders(List<FolderResult> folders) {
    if (selectedTags.isEmpty) {
      _foldersController.add(folders);
    } else {
      final filteredFolders = folders.where((folder) {
        return folder.tags.any((tag) => selectedTags.contains(tag.name));
      }).toList();
      _foldersController.add(filteredFolders);
    }
  }

  void _processFolders(List<FolderResult> folders) {
    _filterFolderTags(folders);
    _filterAndAddFolders(folders);
  }

  List<Tag> _extractUniqueTags(List<FolderResult> folders) {
    return folders.expand((folder) => folder.tags).toSet().toList();
  }

  @override
  void dispose() {
    super.dispose();
    _tagsController.close();
    _foldersController.close();
  }
}
