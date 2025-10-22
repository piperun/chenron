import "package:flutter/foundation.dart";
import "package:chenron/components/forms/folder_form.dart";
import "package:chenron/database/extensions/folder/read.dart";
import "package:chenron/database/extensions/folder/update.dart";
import "package:chenron/database/extensions/operations/database_file_handler.dart";
import "package:chenron/models/item.dart";
import "package:chenron/models/metadata.dart";
import "package:chenron/models/cud.dart";
import "package:chenron/models/db_result.dart";
import "package:chenron/database/database.dart";
import "package:chenron/locator.dart";
import "package:signals/signals.dart";
import "package:collection/collection.dart";

enum FolderEditorState {
  loading,
  loaded,
  error,
  saving,
}

/// Manages state for the folder editor feature
class FolderEditorNotifier extends ChangeNotifier {
  FolderResult? _originalFolder;
  FolderFormData? _currentFormData;
  List<FolderItem> _currentItems = [];
  FolderEditorState _state = FolderEditorState.loading;
  String? _errorMessage;

  FolderEditorState get state => _state;
  String? get errorMessage => _errorMessage;
  FolderResult? get folder => _originalFolder;
  List<FolderItem> get items => _currentItems;

  bool get hasChanges {
    if (_originalFolder == null || _currentFormData == null) {
      return false;
    }

    final originalFolder = _originalFolder!.data;
    final originalTags = _originalFolder!.tags.map((t) => t.name).toSet();
    final currentTags = _currentFormData!.tags;

    // Check title change
    if (originalFolder.title != _currentFormData!.title) {
      return true;
    }

    // Check description change
    if (originalFolder.description != _currentFormData!.description) {
      return true;
    }

    // Check tags change
    if (!const SetEquality().equals(originalTags, currentTags)) {
      return true;
    }

    // Check parent folders change (comparing against empty list since we don't load original parent folders)
    if (_currentFormData!.parentFolderIds.isNotEmpty) {
      return true;
    }

    // Check items change
    final originalItems = _originalFolder!.items;
    if (originalItems.length != _currentItems.length) {
      return true;
    }

    // Compare items by ID
    final originalItemIds = originalItems.map((i) => i.id).toSet();
    final currentItemIds = _currentItems.map((i) => i.id).toSet();
    if (!const SetEquality().equals(originalItemIds, currentItemIds)) {
      return true;
    }

    return false;
  }

  Future<void> loadFolder(String folderId) async {
    _state = FolderEditorState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final dbHandler = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final folderResult = await dbHandler.appDatabase.getFolder(
        folderId: folderId,
        includeOptions: const IncludeOptions({
          AppDataInclude.items,
          AppDataInclude.tags,
        }),
      );

      if (folderResult == null) {
        _state = FolderEditorState.error;
        _errorMessage = "Folder not found";
        notifyListeners();
        return;
      }

      _originalFolder = folderResult;
      _currentItems = List.from(folderResult.items);

      // Initialize form data from loaded folder
      _currentFormData = FolderFormData(
        title: folderResult.data.title,
        description: folderResult.data.description,
        parentFolderIds: [],
        tags: folderResult.tags.map((t) => t.name).toSet(),
        items: _currentItems,
      );

      _state = FolderEditorState.loaded;
      notifyListeners();
    } catch (e) {
      _state = FolderEditorState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void updateFormData(FolderFormData formData) {
    _currentFormData = formData;
    notifyListeners();
  }

  void updateItems(List<FolderItem> items) {
    _currentItems = items;
    notifyListeners();
  }

  Future<bool> saveChanges(String folderId) async {
    if (_originalFolder == null || _currentFormData == null) {
      return false;
    }

    _state = FolderEditorState.saving;
    notifyListeners();

    try {
      final dbHandler = await locator.get<Signal<Future<AppDatabaseHandler>>>().value;
      final appDb = dbHandler.appDatabase;

      final tagUpdates = _buildTagUpdates();
      final itemUpdates = _buildItemUpdates();

      await appDb.updateFolder(
        folderId,
        title: _currentFormData!.title,
        description: _currentFormData!.description,
        tagUpdates: tagUpdates,
        itemUpdates: itemUpdates,
      );

      // Reload folder to get updated data
      await loadFolder(folderId);

      return true;
    } catch (e) {
      _state = FolderEditorState.error;
      _errorMessage = "Failed to save changes: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  CUD<Metadata> _buildTagUpdates() {
    if (_originalFolder == null || _currentFormData == null) {
      return CUD(create: [], update: [], remove: []);
    }

    final originalTags = _originalFolder!.tags;
    final currentTags = _currentFormData!.tags;

    // Tags to create: in current but not in original
    final tagsToCreate = currentTags
        .where((tag) => !originalTags.any((t) => t.name == tag))
        .map((tag) => Metadata(value: tag, type: MetadataTypeEnum.tag))
        .toList();

    // Tags to remove: in original but not in current
    final tagsToRemove = originalTags
        .where((tag) => !currentTags.contains(tag.name))
        .map((tag) => tag.id)
        .toList();

    return CUD(
      create: tagsToCreate,
      update: [],
      remove: tagsToRemove,
    );
  }

  CUD<FolderItem> _buildItemUpdates() {
    if (_originalFolder == null) {
      return CUD(create: [], update: [], remove: []);
    }

    final originalItems = _originalFolder!.items;
    final currentItems = _currentItems;

    // Items to create: new items with null ID
    final itemsToCreate = currentItems
        .where((item) => item.id == null)
        .toList();

    // Items to remove: in original but not in current
    final originalItemIds = originalItems.map((i) => i.id).toSet();
    final currentItemIds = currentItems.map((i) => i.id).toSet();
    final itemsToRemove = originalItemIds
        .where((id) => !currentItemIds.contains(id))
        .whereType<String>()
        .toList();

    return CUD(
      create: itemsToCreate,
      update: [],
      remove: itemsToRemove,
    );
  }
}
