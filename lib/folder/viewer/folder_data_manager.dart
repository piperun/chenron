import 'dart:async';
import 'package:chenron/database/database.dart';
import 'package:chenron/database/extensions/folder/read.dart';
import 'package:chenron/database/extensions/folder/remove.dart';

class FolderDataManager {
  final AppDatabase _database;
  late Stream<List<FolderResult>> _allFoldersStream;
  final _tagsController = StreamController<List<Tag>>.broadcast();
  final _foldersController = StreamController<List<FolderResult>>.broadcast();
  final Set<String> _selectedTags = {};

  FolderDataManager(this._database) {
    _initStreams();
  }

  void _initStreams() {
    _allFoldersStream = _database.watchAllFolders(mode: IncludeFolderData.tags);
    _allFoldersStream.listen(_processFolders);
  }

  void _processFolders(List<FolderResult> folders) {
    final allTags = _extractUniqueTags(folders);
    _tagsController.add(allTags);
    _filterAndAddFolders(folders);
  }

  List<Tag> _extractUniqueTags(List<FolderResult> folders) {
    return folders.expand((folder) => folder.tags).toSet().toList();
  }

  void _filterAndAddFolders(List<FolderResult> folders) {
    if (_selectedTags.isEmpty) {
      _foldersController.add(folders);
    } else {
      final filteredFolders = folders.where((folder) {
        return folder.tags.any((tag) => _selectedTags.contains(tag.name));
      }).toList();
      _foldersController.add(filteredFolders);
    }
  }

  void selectTag(String tagName) {
    _selectedTags.add(tagName);
    _allFoldersStream.first.then(_filterAndAddFolders);
  }

  void unselectTag(String tagName) {
    _selectedTags.remove(tagName);
    _allFoldersStream.first.then(_filterAndAddFolders);
  }

  Future<bool> removeFolder(String id) async {
    try {
      _database.removeFolder(id);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Tag>> get tagsStream => _tagsController.stream;
  Stream<List<FolderResult>> get foldersStream => _foldersController.stream;

  void dispose() {
    _tagsController.close();
    _foldersController.close();
  }
}
